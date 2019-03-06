clear; clc;

addpath('helpers/');

load('nutrients/crop_and_RDI_nutrients');
crops = string(Crop_nutrients.Properties.VariableNames(3:end))';
crops = crops(crops ~= "salt");
clearvars -except crops;

% samples = NaN(length(crops),1);
wmedian_yields_per_impact = NaN(length(crops),1);

load('vegetation_carbon.mat');

for cropID = 1:length(crops)
    
    crop = char(crops(cropID));
    
    if ~exist(['crop_maps/' crop '.mat'],'file')
        error([crop ' map not found.'])
    else
        disp(crop);
        load(['crop_maps/' crop '.mat']);
        
        impact = vegetation_carbon .* harvested_area;
        
        yields_per_impact = production(:) ./ impact(:);
        weights = harvested_area(:);
%         weights(~(impact > 0)) = 0;
        
        yields_per_impact = yields_per_impact(weights > 0); 
        weights = weights(weights > 0);
        
        wmedian_yields_per_impact(cropID) = weightedMedian(yields_per_impact, weights);
        wmedian_yields_per_impact(cropID)
%         samples(cropID) = k0;
        
    end
    
end