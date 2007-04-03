function old_mslice(arg)
% switch old mslice on - i.e. add paths... or switch old mslice off i.e.
% remove paths. 
%
% >> old_mslice(arg)
%
% inputs: arg - can be 'on' or 'off' 
%
% outputs: none
%
% >> old_mslice('on')


init_file = 'old_mslice';
    find_init = feval('which',init_file);
    ind = strfind(find_init,init_file);
    path_string = find_init(1:ind-1);

switch arg
    case 'on'
        addpath([path_string, '\original_mslice\mslice_extras']);
        addpath([path_string, '\original_mslice\mslice']);
        addpath([path_string, '\original_mslice\mslice_corrections']);
        addpath([path_string, '\original_mslice\mslice_extras\sliceomatic_ibon'])
        addpath([path_string, '\original_mslice\mslice_extras\multires2d'])
        addpath([path_string, '\original_mslice\mslice_extras\multires3d'])
        addpath([path_string, '\original_mslice\mslice_extras\multirespow'])
        
        warning off
            new_mslice('off')
        warning on 
        
    case 'off'
        rmpath([path_string, '\original_mslice\mslice_extras']);
        rmpath([path_string, '\original_mslice\mslice']);
        rmpath([path_string, '\original_mslice\mslice_corrections']);
        rmpath([path_string, '\original_mslice\mslice_extras\sliceomatic_ibon'])
        rmpath([path_string, '\original_mslice\mslice_extras\multires2d'])
        rmpath([path_string, '\original_mslice\mslice_extras\multires3d'])
        rmpath([path_string, '\original_mslice\mslice_extras\multirespow'])
    otherwise
        error('require ''on'' or ''off'' as input argument');
end

