clear; clc;

load('data/Crop_impacts.mat');
load('nutrients/crop_and_RDI_nutrients','Crop_nutrients');
load('nutrients/crop_and_RDI_nutrients','Crop_data');

n_crops = height(Crop_impacts);
n_nutrients = height(Crop_nutrients);

P25_Nutrients_per_Impact = zeros(n_crops, n_nutrients);
P50_Nutrients_per_Impact = zeros(n_crops, n_nutrients);
P75_Nutrients_per_Impact = zeros(n_crops, n_nutrients);

assert(isequal(Crop_impacts.crop, Crop_nutrients.Properties.VariableNames(3:end)'));

for cropID = 1:n_crops
    P25_Nutrients_per_Impact(cropID, :) = Crop_impacts.EdibleUnits_per_Impact(cropID,Percentiles==25) * table2array(Crop_nutrients(:,2+cropID));
    P50_Nutrients_per_Impact(cropID, :) = Crop_impacts.EdibleUnits_per_Impact(cropID,Percentiles==50) * table2array(Crop_nutrients(:,2+cropID));
    P75_Nutrients_per_Impact(cropID, :) = Crop_impacts.EdibleUnits_per_Impact(cropID,Percentiles==75) * table2array(Crop_nutrients(:,2+cropID));
end

Nutrients = ["Energy","Protein", "Total lipid (fat)", "Carbohydrate, by difference", ...
    "Vitamin A, RAE", "Vitamin C, total ascorbic acid", "Iron, Fe","Calcium, Ca"];
Relevant_Crop_Types = {{'NUTS','OIL CROPS','CEREALS','PULSES','ROOTS AND TUBERS'}, ...
    {'NUTS','OIL CROPS','CEREALS','PULSES','ROOTS AND TUBERS'}, ...
    {'NUTS','OIL CROPS','CEREALS','VEGETABLES','FRUITS'}, ...
    {'NUTS','OIL CROPS','CEREALS','PULSES','ROOTS AND TUBERS'}, ...
    {'FRUITS','VEGETABLES','CEREALS','NUTS','ROOTS AND TUBERS'}, ...
    {'FRUITS','VEGETABLES','CEREALS','NUTS','PULSES'}, ...    
    {'FRUITS','VEGETABLES','CEREALS','NUTS','OIL CROPS'}, ...
    {'FRUITS','VEGETABLES','ROOTS AND TUBERS','NUTS','PULSES'}};

cols = lines(5);
figure(2); clf;

for nutrientID = 1:length(Nutrients)
    
    relevant_nutrientIDs = zeros(n_crops,1);
    for i = 1:length(Relevant_Crop_Types{nutrientID})
        relevant_nutrientIDs = relevant_nutrientIDs + i*strcmp(Crop_data.group_fao, Relevant_Crop_Types{nutrientID}{i});
    end
    relevant_nutrientIDs_short = find(relevant_nutrientIDs);
    relevant_nutrientIDs = relevant_nutrientIDs(relevant_nutrientIDs_short);
    
    nutrientID2 = find(Crop_nutrients.nutrient == Nutrients(nutrientID));
    
    impacts_per_nutrient = P50_Nutrients_per_Impact(relevant_nutrientIDs_short,nutrientID2);
    [~,idx] = sort(impacts_per_nutrient, 'descend');
%     disp(Crop_nutrients.nutrient(nutrientID));
%     disp(table(Crop_impacts.crop(idx(1:5)),impacts_per_nutrient(idx(1:5))));

    best = 1:7;

    subplot(3,4,nutrientID); hold on;
    widths = table2array(Crop_nutrients(nutrientID2, 2 + relevant_nutrientIDs_short(idx(best))));
    for i = 1:length(best)
        x = max(widths);
        rectangle('position',[i-0.5*widths(i)/x 0 widths(i)/x impacts_per_nutrient(idx(i))],'FaceColor',cols(relevant_nutrientIDs(idx(i)),:));
    end
    
    this_P50 = P50_Nutrients_per_Impact(relevant_nutrientIDs_short(idx(best)), nutrientID2);
    this_P75 = P75_Nutrients_per_Impact(relevant_nutrientIDs_short(idx(best)), nutrientID2);
    this_P25 = P25_Nutrients_per_Impact(relevant_nutrientIDs_short(idx(best)), nutrientID2);
    
%     bar(impacts_per_nutrient(idx(best)),'BarWidth',rand(10,1));
    errorbar(best,this_P50, ...
        this_P50-this_P25, ...
        this_P75-this_P50,'.k')
    xticks(best);
    xticklabels(Crop_impacts.crop(relevant_nutrientIDs_short(idx(best))));
    xtickangle(90);
    xlim([best(1)-0.75 best(end)+0.75]);
    title(Crop_nutrients.nutrient(nutrientID2));
    drawnow;
end
    
