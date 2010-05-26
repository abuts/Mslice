function rez=get_all(this)
% returns the structure with all configurations currently located in
% memory;
global configurations;
global class_names;

for i=1:this.nInstances
    if ~isempty(class_names{i})
        rez.(class_names{i})=struct(configurations{i});
    end
end