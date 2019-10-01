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

nutrient_impacts = NaN(n_nutrients,1);

for nutrientID = 1:n_nutrients
    
    this_b1 = b1;
    this_b2 = b2;
    this_b1(nutrientID) = 0;
    this_b2(nutrientID) = Inf;
    
    minimal_impact = 142.4377;

    this_b2(this_b2 == Inf) = 1e4;
    A = [-A1; A1];
    b = [this_b1; this_b2];
    
    [x,fval,exitflag,~] = linprog(f,A,b,[],[],lb,ub,optimoptions('linprog','Display','off'));

    if exitflag ~= 1
        error("no solution found");
    else
        x_nutrients = A1*x;
%         T = table(RDI_nutrients.nutrient, RDI_nutrients.RDI_min, x_nutrients, RDI_nutrients.RDI_max)
%         T = table(crops(x>0), 100*x(x>0));
%         total_weight_in_kg = sum(x/10);
        total_impact = fval;
        nutrient_impacts(nutrientID) = total_impact / minimal_impact;
    end
end

table(RDI_nutrients.nutrient, nutrient_impacts)