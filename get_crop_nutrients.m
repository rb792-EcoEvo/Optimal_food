clear; clc;

%% load table of used crops, groups and conversion factors

T = readtable('nutrients/Crop_Nutrients_WithSources.xlsx','Sheet','all_crops','Range','A:G');
T = T(:,[1 2 4 6 7]);
warning("range in crop speadsheet is hardcoded.");
T = T(~cellfun(@isempty,T.group_fao),:);
n_crops = height(T);
assert(isempty(find(isnan(T.conversion) + isnan(T.conversion2) ~= ones(n_crops,1),1)));
T.conversion(isnan(T.conversion)) = T.conversion2(~isnan(T.conversion2));
Crop_data = T(:,1:4);

n_oilcrops   = sum(contains(T.group_fao,'OIL CROPS'));
n_cereals    = sum(contains(T.group_fao,'CEREALS'));
n_nuts       = sum(contains(T.group_fao,'NUTS'));
n_fruits     = sum(contains(T.group_fao,'FRUITS'));
n_vegetables = sum(contains(T.group_fao,'VEGETABLES'));
n_pulses     = sum(contains(T.group_fao,'PULSES'));
n_roots      = sum(contains(T.group_fao,'ROOTS AND TUBERS'));
n_sugars     = sum(contains(T.group_fao,'SUGAR CROPS'));
n_other      = sum(contains(T.group_fao,'OTHER')); %currently only salt

assert(n_crops == n_cereals + n_oilcrops + n_nuts + n_fruits + n_vegetables + n_pulses + n_roots + n_sugars + n_other);

clearvars -except Crop_data;

crops = Crop_data.crop;

nutrient = strings(0,1);
unit = strings(0,1);


for iteration = 1:2

    if iteration == 2
        values = zeros(length(nutrient),length(crops));
    end
    
    for cropID = 1:length(crops)

        if ~exist(['nutrients\USDA\' crops{cropID} '.csv'],'file')
            error(['nutrients of ' crops{cropID} ' not found.']);
        else
            file = fileread(['nutrients\USDA\' crops{cropID} '.csv']);
            lines = regexp(file, '\n', 'split');
            assert(isequal(lines{5}(1:30),'Nutrient,Unit,1Value per 100 g'));
            remove_lines = false(length(lines),1);
            for i = 1:length(lines)
                if isempty(lines{i}) || ...
                        isequal(lines{i}(1:min(6,length(lines{i}))),'Source') || ...
                        isequal(lines{i}(1:min(5,length(lines{i}))),'Basic') || ...
                        isequal(lines{i}(1:min(6,length(lines{i}))),'Report') || ...
                        isequal(lines{i}(2:min(9,length(lines{i}))),'Nutrient') || ...
                        isequal(lines{i}(1:min(8,length(lines{i}))),'Nutrient') || ...
                        isequal(lines{i}(1:min(10,length(lines{i}))),'Proximates') || ...
                        isequal(lines{i}(1:min(8,length(lines{i}))),'Minerals') || ...
                        isequal(lines{i}(1:min(8,length(lines{i}))),'Vitamins') || ...
                        isequal(lines{i}(1:min(6,length(lines{i}))),'Lipids') || ...
                        isequal(lines{i}(1:min(11,length(lines{i}))),'Amino Acids') || ...
                        isequal(lines{i}(1:min(5,length(lines{i}))),'Other') || ...
                        isequal(lines{i}(1:min(8,length(lines{i}))),'Caffeine') || ...
                        isequal(lines{i}(1:min(9,length(lines{i}))),'"Caffeine') || ...
                        isequal(lines{i}(1:min(9,length(lines{i}))),'Footnotes') || ...
                        isequal(lines{i}(1:min(1,length(lines{i}))),'(')
                    remove_lines(i) = true;
                end
            end

            lines = lines(~remove_lines);
            for i = 1:length(lines)
                id = strfind(lines{i},'"');
                assert(length(id)==2); assert(id(1) == 1);
                this_nutrient = string(lines{i}(id(1)+1:id(2)-1));

                line_wo_nutrients = lines{i}(id(2)+2:end-1);
                id = strfind(line_wo_nutrients,',');

                if iteration == 1
                    this_unit = string(line_wo_nutrients(1:id(1)-1));
                    if ~ismember(this_nutrient, nutrient)
                        nutrient = [nutrient; this_nutrient];
                        unit = [unit; this_unit];
                    else
                        [~,existing_nutrient_ID] = ismember(this_nutrient, nutrient);
                        assert(isequal(this_unit,unit(existing_nutrient_ID)));            
                    end
                else
                    [~,nutrient_ID] = ismember(this_nutrient, nutrient);
                    values(nutrient_ID,cropID) = str2double(line_wo_nutrients(id(1)+1:id(2)-1));
                end
            end
        end
    end
end

T = array2table(values,'VariableNames',cellstr(crops));
Crop_nutrients = [array2table(nutrient), array2table(unit), T];

clearvars -except Crop_nutrients Crop_data

RDI_nutrients = readtable('requirements.xlsx','Sheet','matching','Range','A1:F33');
warning("range in RDI nutrient spreadsheet hardcoded.");
RDI_nutrients = RDI_nutrients(:,[1 4:6]);
RDI_nutrients.nutrient = string(RDI_nutrients.nutrient);
RDI_nutrients.unit = string(RDI_nutrients.unit);
if ~isa(RDI_nutrients.RDI_min,'double')
    RDI_nutrients.RDI_min = str2double(RDI_nutrients.RDI_min);
end
if ~isa(RDI_nutrients.RDI_max,'double')
    RDI_nutrients.RDI_max = str2double(RDI_nutrients.RDI_max);
end

remove_nutrients = isnan(RDI_nutrients.RDI_min) | ...
    (RDI_nutrients.nutrient == "Vitamin B-12") | ...
    (RDI_nutrients.nutrient == "Vitamin D (D2 + D3)") | ...
    (RDI_nutrients.nutrient == "Fatty acids, total saturated") | ...
    (RDI_nutrients.nutrient == "Sodium, Na") | ...
    (RDI_nutrients.nutrient == "Cholesterol");
warning("Removing Vitamins B12, D, Cholesterol and total saturated Fatty acids.")
Crop_nutrients = Crop_nutrients(~remove_nutrients,:);
RDI_nutrients  = RDI_nutrients(~remove_nutrients,:);

assert(isequal(Crop_nutrients.nutrient, RDI_nutrients.nutrient));

clearvars -except Crop_nutrients RDI_nutrients Crop_data;

% Crop_nutrients.sugarcane = [];
% Crop_data(contains(Crop_data.crop,'sugarcane'),:) = [];
% warning("Removing sugarcane.")
% 
save('nutrients/crop_and_RDI_nutrients');