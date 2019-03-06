clear; clc;

load('nutrients/crop_and_RDI_nutrients');
load('data/Crop_impacts.mat');

crops = string(Crop_nutrients.Properties.VariableNames(3:end))';


A1 = table2array(Crop_nutrients(:,3:end));
b1 = -RDI_nutrients.RDI_min;
b2 = RDI_nutrients.RDI_max;
b2(b2 == Inf) = 1e4;
A = [-A1; A1];
lower_deviation = 0;
upper_deviation = 10;
b = [b1 * (1 - lower_deviation) ; b2  * (1 + upper_deviation)];

lb = zeros(length(crops),1);
f = 1 ./ Crop_impacts.EdibleUnits_per_Impact; %crop-specific impact

x = linprog(f,A,b,[],[],lb,[]);

x_nutrients = A1*x;

T = table(RDI_nutrients.nutrient, RDI_nutrients.RDI_min, x_nutrients, RDI_nutrients.RDI_max)

T = table(crops, x)

