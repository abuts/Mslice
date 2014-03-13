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
% $Revision: 226 $ ($Date: 2012-03-12 12:36:12 +0000 (Mon, 12 Mar 2012) $)
%
spe_ext=rundata().supported_extensions;
spe_ext = strcat({'*'},spe_ext);

win_fs = ispc;
full_form=false;

% Check input arguments
if nargin>0
    if ischar(varargin{1})
        if ismember('-testwin',varargin)        
            win_fs = true;
        elseif ismember('-testunix',varargin)        
            win_fs = false;
        else
            full_form=true;
        end
    else
       full_form=true;
    end
    if nargin>1
        full_form=true;
    end   
end



if ~win_fs 
    spe_ext_wd = [lower(spe_ext),upper(spe_ext)];
    ext = spe_ext_wd';
else
   ext = spe_ext'; 
end
if full_form
    ext_base = strcat(spe_ext,{';'});
    descr    = rundata().ext_descr;
    
    ext={[ext_base{:}],['ASCII, HDF and nexus spe files (' ext_base{:} ')']};    
    if win_fs
        for i=1:numel(spe_ext)
            ext=[ext;{spe_ext{i},descr{i}}];
        end
    else
        for i=1:numel(spe_ext)
            ext=[ext;{[lower(spe_ext{i}),';',upper(spe_ext{i})],descr{i}}];
        end        
    end
end
