clear; clc;

load('data/Crop_impacts.mat');
load('nutrients/crop_and_RDI_nutrients','Crop_nutrients');

n_crops = height(Crop_impacts);
n_nutrients = height(Crop_nutrients);

Nutrients_per_Impact = zeros(n_crops, n_nutrients);

assert(isequal(Crop_impacts.crop, Crop_nutrients.Properties.VariableNames(3:end)'));

for cropID = 1:n_crops
    Nutrients_per_Impact(cropID, :) = Crop_impacts.EdibleUnits_per_Impact(cropID) * table2array(Crop_nutrients(:,2+cropID));
end


for nutrientID = 1:n_nutrients
    
    impacts_per_nutrient = Nutrients_per_Impact(:,nutrientID);
    [~,idx] = sort(impacts_per_nutrient, 'descend');
    disp(Crop_nutrients.nutrient(nutrientID));
    disp(table(Crop_impacts.crop(idx(1:5)),impacts_per_nutrient(idx(1:5))));
    
%     subplot(4,6,nutrientID);    
%     bar(impacts_per_nutrient(idx(1:5)));
%     xticks(1:5);
%     xticklabels(Crop_impacts.crop(idx(1:5)));
%     xtickangle(90);
%     title(Crop_nutrients.nutrient(nutrientID));
%     drawnow;
end
    
