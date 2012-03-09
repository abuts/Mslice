function data_fiedls = what_fields_are_needed(this)
% the function returns the list data fields, which have to be defined by the run 
% for cases of  crystal or powder experiments
% 
%
% if isempty(this.is_crystal) <-- all constructors (including default one
%                                 are currently defining this
% end
if this.is_crystal
    data_fiedls = {'efix','en','S','ERR','det_par','alatt','angldeg','psi','omega','dpsi','gl','gs','u','v'};
else
    data_fiedls = {'efix','en','S','ERR','det_par'};    
end

