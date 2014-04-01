function [s_empty,err_empty,dat_empty,det_empty] = data_empty(this)
% helper method checks which data fields are empty
%
%
% $Revision: 326 $ ($Date: 2014-01-11 20:51:50 +0000 (Sat, 11 Jan 2014) $)
%
if isempty(this.S_stor)
    s_empty=true;
else
    s_empty=false;
end

if isempty(this.ERR_stor)
    err_empty = true;
else
    err_empty = false;
end

dat_empty = s_empty||err_empty;

if isempty(this.det_par_stor)
    det_empty=true;
else
    det_empty=false;
end

