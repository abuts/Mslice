function this=delete(this,element_names)
% delete collection of the graphic elements, specified by their names
% from the users menu
%
%   $Rev$ ($Date$)
%

to_keep  = ~ismember(this.elements_names,element_names);
if isempty(to_keep)||all(to_keep)
      return;
end
this.elements_names = this.elements_names(to_keep); 
for i=1:numel(this.element_list)
      if ~to_keep(i)
          delete(this.element_list{i});
      end
end
this.element_list      =  this.element_list(to_keep);   
set(this.h_menu,'UserData',this);

