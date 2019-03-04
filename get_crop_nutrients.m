clear; clc;

file = fileread('nutrients\USDA\almond.csv');
lines = regexp(file, '\n', 'split');
assert(isequal(lines{5}(1:30),'Nutrient,Unit,1Value per 100 g'));
relevant_lines = [7:13 15:21 23:35 37:41];
lines = lines(relevant_lines);
nutrients = strings(length(lines),1);
units = strings(length(lines),1);
values = NaN(length(lines),1);
for i = 1:length(lines)
    id = strfind(lines{i},'"');
    assert(length(id)==2); assert(id(1) == 1);
    nutrients(i) = string(lines{i}(id(1)+1:id(2)-1));    
    lines{i} = lines{i}(id(2)+2:end-1);
    id = strfind(lines{i},',');
    assert(length(id) == 7);
    units(i) = string(lines{i}(1:id(1)-1));
    values(i) = str2num(lines{i}(id(1)+1:id(2)-1));
end

filecontents = dir('nutrients/USDA');
crops = strings(length(filecontents)-2,1);
for i = 1:length(crops)
    this_crop = filecontents(i+2).name;
    crops(i) = string(this_crop(1:end-4));
end

clearvars -except crops nutrients units relevant_lines

disp("Sample nutrients, and crops created")

values = NaN(length(crops), length(nutrients));

for i = 1:length(crops)
    
    file = fileread(['nutrients\USDA\' char(crops(i)) '.csv']);
    lines = regexp(file, '\n', 'split');
    assert(isequal(lines{5}(1:30),'Nutrient,Unit,1Value per 100 g'));
    lines = lines(relevant_lines);
        
%     for j = 1:length(lines)
%         id = strfind(lines{j},'"');
%         assert(length(id)==2); assert(id(1) == 1);
%         assert(isequal(nutrients(j),string(lines{j}(id(1)+1:id(2)-1))));    
%         lines{j} = lines{j}(id(2)+2:end-1);
%         id = strfind(lines{j},',');
%         assert(length(id) == 7);
%         assert(isequal(units(j), string(lines{j}(1:id(1)-1))));
%         
%         values(i,j) = str2num(lines{j}(id(1)+1:id(2)-1));
%     end
end
    