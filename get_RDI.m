clear; clc;

load('nutrients/crop_and_RDI_nutrients');

crops = string(Crop_nutrients.Properties.VariableNames(3:end))';


A = table2array(Crop_nutrients(:,3:end));
b = RDI_nutrients.RDI;

lb = zeros(length(crops),1);
f = ones(length(crops),1); %crop-specific impact

x = linprog(f,-A,-b,[],[],lb,[]);

x_nutrients = A*x;

T = table(RDI_nutrients.nutrient, RDI_nutrients.RDI, x_nutrients)

T = table(crops, x)