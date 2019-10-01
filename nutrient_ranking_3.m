clear; clc;

load('nutrients/crop_and_RDI_nutrients');
load('data/Crop_impacts.mat');
n_nutrients = height(RDI_nutrients);

crops = string(Crop_nutrients.Properties.VariableNames(3:end))';
n_crops = length(crops);

A1 = table2array(Crop_nutrients(:,3:end));
b1 = -RDI_nutrients.RDI_min;
b2 = RDI_nutrients.RDI_max;
lb = zeros(length(crops),1);
ub = 1e4*ones(length(crops),1);
f = 1 ./ Crop_impacts.EdibleUnits_per_Impact(:,Percentiles == 50);

b2(b2 == Inf) = 1e4;
A = [-A1; A1];
b = [b1; b2];

bestcrop = [" "];
bestimpact = [];

for iteration = 0:5

    crop_reduction = NaN(n_crops,1);

    for cropID = 1:n_crops

        this_ub = ub;
        for i = 1:length(bestcrop)
            %remove best crop
           this_ub(crops == bestcrop(i)) = 0;
        end
        if iteration > 0
            this_ub(cropID) = 0;
        end       

        [x,fval,exitflag,~] = linprog(f,A,b,[],[],lb,this_ub,optimoptions('linprog','Display','off'));

        if exitflag ~= 1
            error("no solution found");
        else
%             x_nutrients = A1*x;
%             T = table(RDI_nutrients.nutrient, RDI_nutrients.RDI_min, x_nutrients, RDI_nutrients.RDI_max);
%             T = table(crops(x>0), 100*x(x>0));
%             total_weight_in_kg = sum(x/10);
            if iteration == 0
                minimal_impact = fval;
            end
            total_impact = fval;
            crop_reduction(cropID) = total_impact;
        end
    end
    
    crop_reduction(crops == "garlic") = NaN;
    crop_reduction(crops == "mushroom") = NaN;
    crop_reduction(crops == "date") = NaN;
    crop_reduction(crops == "oilpalm") = NaN;
    crop_reduction(crops == "sunflower") = NaN;
    crop_reduction(crops == "carrot") = NaN;
    
    [impact_without_crop,bestcropID] = max(crop_reduction);
    if iteration > 0
        bestcrop = [bestcrop; crops(bestcropID)];
    end
    bestimpact = [bestimpact; impact_without_crop];
    table(bestcrop,bestimpact)
end

