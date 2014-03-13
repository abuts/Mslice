function this=add(this,gui_element,visible)
 % add collection of graphic elements to users menu
%
%   $Rev$ ($Date$)
%
if any(ismember(this.elements_names,gui_element.name)) % already there
       return;
end
n_elements = numel(this.element_list);  
this.elements_names{n_elements+1} = gui_element.name;
this.element_list{n_elements+1}   = gui_element;
set(this.h_menu,'UserData',this); 
   
% default -- make gui element visible after adding it to collection;
if ~exist('visible','var')||(~strcmpi(visible,'no'))
       make_visible(gui_element);
end

