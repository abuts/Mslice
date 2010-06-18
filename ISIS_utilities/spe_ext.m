function ext=spe_ext(varargin)
% function returns the list of possible exitensions for spe and hdf5-spe
% files
%
% function is to provide compartibility between libisis and mslice but to
% allow mslice running without libisis initiated;
% the function has to returns the same result as the libisis spe class
% method spe_ext(spe) and have to be changed manualy if this method
% returns different results
%
% if the parameter is present,
% the result of the function is formatted as needed to use in a
% filter for uigetfile
%
% $Revision$ ($Date$)
%
spe_hdf_ext=['*',spe_hdf_filestructure('spe_hdf_file_ext')];
if nargin>0
    ext={['*.spe;' spe_hdf_ext],['ASCII and HDF spe files (*.spe, ' spe_hdf_ext ')'];...
        '*.spe','ASCII spe files (*.spe)';...
        spe_hdf_ext,['HDF spe files' spe_hdf_ext]};    
else
    ext={'*.spe';spe_hdf_ext};
end