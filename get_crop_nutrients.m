clear; clc;

filecontents = dir('nutrients/USDA');
crops = strings(length(filecontents)-2,1);
for i = 1:length(crops)
    this_crop = filecontents(i+2).name;
    crops(i) = string(this_crop(1:end-4));
end

clearvars -except crops


nutrient = strings(0,1);
unit = strings(0,1);

for iteration = 1:2

    if iteration == 2
        values = zeros(length(nutrient),length(crops));
    end
    
    for cropID = 1:length(crops)

        file = fileread(['nutrients\USDA\' char(crops(cropID)) '.csv']);
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


T = array2table(values,'VariableNames',cellstr(crops));
Crop_nutrients = [array2table(nutrient), array2table(unit), T];

disp(Crop_nutrients);

% clearvars -except Crop_nutrients
% 
% RDI_nutrients = readtable('requirements.xlsx','Sheet','matching','Range','A1:E33');
% RDI_nutrients = RDI_nutrients(:,[1 4 5]);
% RDI_nutrients.nutrient = string(RDI_nutrients.nutrient);
% RDI_nutrients.unit = string(RDI_nutrients.unit);
% RDI_nutrients.RDI = str2double(RDI_nutrients.RDI);
% 
% remove_nutrients = isnan(RDI_nutrients.RDI) | ...
%     (RDI_nutrients.nutrient == "Vitamin B-12") | ...
%     (RDI_nutrients.nutrient == "Vitamin D (D2 + D3)") | ...
%     (RDI_nutrients.nutrient == "Cholesterol");
% warning("Removing Vitamins B12 and D, and Cholesterol.")
% 
% Crop_nutrients = Crop_nutrients(~remove_nutrients,:);
% RDI_nutrients  = RDI_nutrients(~remove_nutrients,:);
% 
% assert(isequal(Crop_nutrients.nutrient, RDI_nutrients.nutrient));
% % assert(isequal(Crop_nutrients.unit, RDI_nutrients.unit));
% 
% clearvars -except Crop_nutrients RDI_nutrients;
% 
% Crop_nutrients.sugarcane = [];
% warning("Removing sugarcane.")
% 
% save('nutrients/crop_and_RDI_nutrients');