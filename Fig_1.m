clear; clc;

addpath('helpers/');
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

figure(1); clf; hold on;

b2(b2 == Inf) = 1e4;
A = [-A1; A1];
b = [b1; b2];
f = 1 ./ Crop_impacts.EdibleUnits_per_Impact(:,Percentiles == 25);

Scenarios = ["Lowest impact";
    "Lowest impact without 'best' crop";
    "Lowest impact without 'best' two crops";
    "Lowest impact with max. 70g of each crop";
    "Highest impact without 'worst' crop";    
    "Highest impact"];

for i = 1:length(Scenarios)

    best = true;
    this_ub = ub;
    
    if Scenarios(i) == "Lowest impact"        
    elseif Scenarios(i) == "Lowest impact without 'best' crop"
        this_ub(crops == "garlic") = 0;
    elseif Scenarios(i) == "Lowest impact without 'best' two crops"
        this_ub(crops == "garlic") = 0;
        this_ub(crops == "mushroom") = 0;
    elseif Scenarios(i) == "Highest impact"
        best = false;
    elseif Scenarios(i) == "Highest impact without 'worst' crop"
        this_ub(crops == "asparagus") = 0;
        best = false;
    elseif Scenarios(i) == "Lowest impact with max. 70g of each crop"
        this_ub = 0.7*ones(n_crops,1);
    end
    
    if best
        this_f = f;
    else
        this_f = -f;
    end
    
    [x,fval,exitflag,~] = linprog(this_f,A,b,[],[],lb,this_ub,optimoptions('linprog','Display','off'));

    if exitflag ~= 1
        error("no solution found");
    else
        x_nutrients = A1*x;
    %         T = table(RDI_nutrients.nutrient, RDI_nutrients.RDI_min, x_nutrients, RDI_nutrients.RDI_max)
        this_crops = crops(x>0);
        this_portions = 100*x(x>0);
        total_impact = abs(fval);
    end
    
    this_portions = this_portions / sum(this_portions) * total_impact;
    
    plot_bar(this_portions,this_crops, find(Scenarios(i) == Scenarios), 0.5);
    xlabel("Carbon impact");
    yticks(1:length(Scenarios));
    yticklabels(Scenarios);
end




