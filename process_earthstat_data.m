clear; clc;

load('nutrients/crop_and_RDI_nutrients');
crops = string(Crop_nutrients.Properties.VariableNames(3:end))';
clearvars -except crops;
crops = crops(crops ~= "salt");

load('vegetation_carbon.mat');
land = ~isnan(vegetation_carbon);
clearvars -except crops land;

for cropID = 1:length(crops)
    
    crop = char(crops(cropID));
    
    if exist(['crop_maps/' crop '.mat'],'file')
%         disp([crop ' maps already exist.']);
    else
        disp(crop);
        if ~exist(['crop_maps/raw/' crop '_HarvAreaYield_Geotiff.zip'],'file')
            warning([crop ' not found!']);
        else
            unzip(['crop_maps/raw/' crop '_HarvAreaYield_Geotiff.zip']);
            
            harvested_area = imread([crop '_HarvAreaYield_Geotiff/' crop '_HarvestedAreaHectares.tif']);
            production     = imread([crop '_HarvAreaYield_Geotiff/' crop '_Production.tif']);
            
            harvested_area(~land) = NaN;
            production(~land)     = NaN;
            
            save(['crop_maps/' crop '.mat'],'harvested_area','production');
            
            rmdir([crop '_HarvAreaYield_Geotiff'], 's');
        end
    end
end



