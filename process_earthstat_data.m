clear; clc;

load('nutrients/crop_and_RDI_nutrients');
crops = Crop_data.crop;
clearvars -except crops;

load('data/vegetation_carbon.mat');
land = ~isnan(vegetation_carbon);
clearvars -except crops land Impact_per_EdibleUnit;

for cropID = 1:length(crops)
    
    crop = crops{cropID};
    
    if ~isequal(crop,'salt')

        if exist(['data/crop_maps/' crop '.mat'],'file')
        else
            disp(crop);
            if ~exist(['data/crop_maps/raw/' crop '_HarvAreaYield_Geotiff.zip'],'file')
                warning([crop ' not found!']);
            else
                unzip(['data/crop_maps/raw/' crop '_HarvAreaYield_Geotiff.zip']);

                harvested_area = imread([crop '_HarvAreaYield_Geotiff/' crop '_HarvestedAreaHectares.tif']);
                production     = imread([crop '_HarvAreaYield_Geotiff/' crop '_Production.tif']);

                harvested_area(~land) = NaN;
                production(~land)     = NaN;

                save(['data/crop_maps/' crop '.mat'],'harvested_area','production');

                rmdir([crop '_HarvAreaYield_Geotiff'], 's');
            end
        end
    end
end

clear;
