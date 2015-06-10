function [det_par,n_det,file_name] = check_det_par(value)
% method checks if value can represent par file and detectors coordinates
% and converts this value into format, used in det_par field
%
% $Revision: 323 $ ($Date: 2014-01-10 19:52:56 +0000 (Fri, 10 Jan 2014) $)
%
file_name='';
if isempty(value)
    det_par = [];
    n_det=[];
    return;
end
if isstruct(value)
    flds = fields(value);
    if ~all(ismember({'group','x2','phi','azim','width','height'},flds))
        error('A_LOADER:set_det_par',' attempt to set invalid detectors structure')
    end
    n_det = numel(value.group);
    file_name   = fullfile(value.filepath,value.filename);
else
    [n_col,n_det] = size(value);
    if n_col ~= 6
        error('A_LOADER:set_det_par',' attempt to set invalid detectors parameters')
    end
    value = get_hor_format(value,'');
end
det_par = value;


