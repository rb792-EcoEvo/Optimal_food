clear; clc;

addpath('helpers/');

load('nutrients/crop_and_RDI_nutrients');
crops = Crop_data.crop;
conversion = Crop_data.conversion;
clearvars -except crops conversion;

Percentiles = [5 10 25 50 75 90 95];
EdibleUnits_per_Impact = NaN(length(crops), length(Percentiles));

load('data/vegetation_carbon.mat');

for cropID = 1:length(crops)
    
    crop = char(crops(cropID));
    
    if ~exist(['data/crop_maps/' crop '.mat'],'file')
        error([crop ' map not found.'])
    else
        disp(crop);
        load(['data/crop_maps/' crop '.mat']);

        impact = vegetation_carbon(:) .* harvested_area(:);
        edible_production = conversion(cropID) * production(:);
        weights = harvested_area(:);

        k = weights(:) > 0 & impact(:) > 0 & edible_production(:) >= 0;

        impact = impact(k);
        edible_production = edible_production(k);
        weights = weights(k);

        EdibleUnits_per_Impact(cropID,:) = wprctile(edible_production ./ impact, Percentiles, weights, 4);

%             Mean_Yield(cropID) = total_edible_production / total_area;
%             Mean_Impact(cropID) = total_impact / total_area;
%             EdibleUnits_per_Impact(cropID) = total_edible_production / total_impact;
    end
end

crop = crops;
Crop_impacts = table(crop, EdibleUnits_per_Impact);
% 
clearvars -except Crop_impacts Percentiles;

save('data/Crop_impacts.mat');