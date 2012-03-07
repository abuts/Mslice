function ext=spe_ext(varargin)
% function returns the list of possible exitensions for spe, hdf5-spe
% and nxspe files
%
% function created here to provide compartibility between libisis and 
% mslice but to allow mslice running without libisis initiated;
% the function has to returns the same result as the libisis spe class
% method spe_ext(spe) and have to be changed manualy if this method
% returns different results
%
% if the parameter is present,
% the result of the function is formatted as needed to use in a
% filter for uigetfile
%
% $Revision: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%
spe_hdf_ext=spe_hdf_filestructure('spe_hdf_file_ext');
%if ~ispc
    spe_hdf_ext0 = strcat({'*'},lower(spe_hdf_ext));    
    spe_hdf_ext1 = strcat({'*'},upper(spe_hdf_ext));
    spe_hdf_ext = [spe_hdf_ext0,spe_hdf_ext1];
%else
 %   spe_hdf_ext = strcat({'*'},lower(spe_hdf_ext));        
%end
if nargin>0
    ext_base = strcat(spe_hdf_ext,{';'});
    ext={['*.spe;' ext_base{:}],['ASCII, HDF and nexus spe files (*.spe, ' ext_base{:} ')'];...
        '*.spe','ASCII spe files: (*.spe)';...
        spe_hdf_ext{1},['HDF spe files: (' spe_hdf_ext{1},')'];...
        spe_hdf_ext{2},['nexus spe files (produced by MANTID): (' spe_hdf_ext{2},')']...        
        };    
else
    if ispc
        ext={'*.spe',spe_hdf_ext{:}}';
    else
        ext={'*.spe','*.SPE',spe_hdf_ext{:}}';        
    end
end
