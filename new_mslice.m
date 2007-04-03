function new_mslice(arg)
% switch new mslice on - i.e. add paths... or switch new mslice off i.e.
% remove paths. 
%
% >> new_mslice(arg)
%
% inputs: arg - can be 'on' or 'off' 
%
% outputs: none
%
% NOTE: This will also switch "old mslice" off so that you can be sure only
% the new mslice is on
%
% >> new_mslice('on')


init_file = 'new_mslice';
    find_init = feval('which',init_file);
    ind = strfind(find_init,init_file);
    path_string = find_init(1:ind-1);

switch arg
    case 'on'
        addpath([path_string, '\matlab']);
        addpath([path_string,'\matlab\classes']);
        addpath([path_string,'\matlab\userfunctions']);
        
        warning off
         old_mslice('off')
        warning on 
        
    case 'off'
        rmpath([path_string,'\matlab']);
        rmpath([path_string,'\matlab\classes']);
        rmpath([path_string,'\matlab\userfunctions']);
    otherwise
        error('require ''on'' or ''off'' as input argument');
end

