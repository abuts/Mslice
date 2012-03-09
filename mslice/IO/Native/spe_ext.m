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
win_fs = ispc;
full_form=false;
% Check input arguments
if nargin>0
    if ismember('-testwin',varargin)        
        win_fs = true;
    elseif ismember('-testunix',varargin)        
        win_fs = false;
    else
        full_form=true;
    end
    if nargin>1
        full_form=true;
    end   
end


spe_hdf_ext=spe_hdf_filestructure('spe_hdf_file_ext');
spe_ext    = ['.spe',spe_hdf_ext];
if ~win_fs
    spe_ext0 = strcat({'*'},lower(spe_ext));    
    spe_ext1 = strcat({'*'},upper(spe_ext));
    spe_ext = [spe_ext0,spe_ext1];
else
   spe_ext = strcat({'*'},lower(spe_ext));
   spe_ext0=spe_ext;
end
if full_form
    ext_base = strcat(spe_ext0,{';'});
    if win_fs
       ext={[ext_base{:}],['ASCII, HDF and nexus spe files (' ext_base{:} ')'];...
          spe_ext0{1},['ASCII spe files: (' spe_ext0{1} ')'];...
          spe_ext0{2},['HDF spe files: (' spe_ext0{2} ')'];...
          spe_ext0{3},['nexus spe files (MANTID): (' spe_ext0{3} ')']...        
        };   
    else
     ext={[ext_base{:}],['ASCII, HDF and nexus spe files (' ext_base{:} ')'];...
        [spe_ext0{1},';',spe_ext1{1}],['ASCII spe files: (' spe_ext0{1} ')'];...
        [spe_ext0{2},';',spe_ext1{2}],['HDF spe files: (' spe_ext0{2} ')'];...
        [spe_ext0{3},';',spe_ext1{3}],['nexus spe files (MANTID): (' spe_ext0{3} ')']...        
        };           
    end
else
    ext=spe_ext';    
end
