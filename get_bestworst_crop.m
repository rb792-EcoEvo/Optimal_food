clear; clc;

load('nutrients/crop_and_RDI_nutrients');
load('data/Crop_impacts.mat');
n_nutrients = height(RDI_nutrients);

crops = string(Crop_nutrients.Properties.VariableNames(3:end))';
n_crops = length(crops);

A1 = table2array(Crop_nutrients(:,3:end));
b1 = -RDI_nutrients.RDI_min;
b2 = RDI_nutrients.RDI_max;
b2(b2 == Inf) = 1e4;
lb = zeros(length(crops),1);
ub = 1e4*ones(length(crops),1);
f = -1 ./ Crop_impacts.EdibleUnits_per_Impact(:,Percentiles == 50);
A = [-A1; A1];
b = [b1; b2];

crop_impacts = NaN(n_crops,1);

for cropID = 1:n_crops
    
    this_ub = ub;
    this_ub(cropID) = 0;
        
    [x,fval,exitflag,~] = linprog(f,A,b,[],[],lb,this_ub,optimoptions('linprog','Display','off'));

    if exitflag ~= 1
        error("no solution found");
    else
        crop_impacts(cropID) = abs(fval);
    end
end

[~,idx] = sort(crop_impacts,'descend');
crops(idx)