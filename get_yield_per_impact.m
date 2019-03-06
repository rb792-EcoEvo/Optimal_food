clear; clc;

addpath('helpers/');

load('nutrients/crop_and_RDI_nutrients');
crops = Crop_data.crop;
conversion = Crop_data.conversion;
clearvars -except crops conversion;

EdibleUnits_per_Impact = NaN(length(crops),1);
Mean_Yield = NaN(length(crops),1);
Mean_Impact = NaN(length(crops),1);

load('data/vegetation_carbon.mat');

for cropID = 1:length(crops)
    
    crop = char(crops(cropID));
    
    if isequal(crop,'salt')
        EdibleUnits_per_Impact(cropID) = 0.01;
    else
        if ~exist(['data/crop_maps/' crop '.mat'],'file')
            error([crop ' map not found.'])
        else
            disp(crop);
            load(['data/crop_maps/' crop '.mat']);
            
            total_area = nansum(harvested_area(:));
            total_impact = nansum(vegetation_carbon(:) .* harvested_area(:));
            total_edible_production = conversion(cropID) * nansum(production(:));
            
            Mean_Yield(cropID) = total_edible_production / total_area;
            Mean_Impact(cropID) = total_impact / total_area;
            EdibleUnits_per_Impact(cropID) = total_edible_production / total_impact;

    %         impact = vegetation_carbon .* harvested_area;        
    %         yields_per_impact = production(:) ./ impact(:);
    %         weights = harvested_area(:);
    %         weights(~(impact > 0)) = 0;
    %         yields_per_impact = yields_per_impact(weights > 0); 
    %         weights = weights(weights > 0);
    %         wmedian_yields_per_impact(cropID) = weightedMedian(yields_per_impact, weights);

        end
    end
end

crop = crops;
Crop_impacts = table(crop, EdibleUnits_per_Impact, Mean_Yield, Mean_Impact);

clearvars -except Crop_impacts;

save('data/Crop_impacts.mat');