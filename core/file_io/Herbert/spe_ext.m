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
% $Revision: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
%
win_fs = ispc;
% provide output as cellarray of extensions with the description of the
% extencion meanings.
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

ext0 = loaders_factory.instance().supported_file_extensions;
if ~win_fs
    spe_ext0 = strcat({'*'},lower(ext0));
    spe_ext1 = strcat({'*'},upper(ext0));
    spe_ext = [spe_ext0;spe_ext1]';
else
    spe_ext = strcat({'*'},lower(ext0));
    spe_ext0=spe_ext';
end
if full_form
    ext_base = strcat(spe_ext0,{';'});
    descr=loaders_factory.instance().reader_descriptions;
    nDescr=numel(descr);
    
    ext=cell(nDescr+1,2);
    ext{1,1}=[ext_base{:}];
    ext{1,2}=['Supported file extensions (' ext_base{:} ')'];
    for i=1:nDescr
        if win_fs
            ext{i+1,1}=spe_ext0{i};
        else
            ext{i+1,1}=[spe_ext0{i},';',spe_ext1{i}];
        end
        ext{i+1,2}=descr{i};
    end
else
    ext=spe_ext';
end
