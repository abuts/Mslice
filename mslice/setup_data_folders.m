function setup_data_folders(varargin)
% function sets up default folders for msp, par and spe files
% if varargin is present it can choose some of the folders;
%
% $Revision$ ($Date$)
%
select_msp=false;
select_spe=false;
select_phx=false;
select_cut=false;
if nargin==0
    select_msp=true;
    select_spe=true;
    select_phx=true;
    select_cut=true;
else
    par=lower(varargin{1});
    switch (par)
        case 'msp';    select_msp=true;            
        case 'spe';    select_spe=true;
        case 'phx';    select_phx=true;
        case 'cut';    select_cut=true;                  
        otherwise
            return;
    end
    
end
msp_path = get(mslice_config,'MspDir');
data_path= get(mslice_config,'DataDir');
phx_path = get(mslice_config,'PhxDir');
cut_path = get(mslice_config,'cut_OutputDir');
path     = pwd;

if select_msp
    path = uigetdir(msp_path,'Select folder to look for mslice parameters files');
    if ~isnumeric(path)
        set(mslice_config,'MspDir',path);
    end
end

if select_spe
    % select guess value as new msp folder if previous data folder
    % coinsided with previous msp folder;
    if strcmp(msp_path,data_path)
        data_path=path;
    end
    path = uigetdir(data_path,'Select folder to look for data (spe)  files');
    if ~isnumeric(path)
        set(mslice_config,'DataDir',path);
    end
end

if select_phx
    % select guess value as new data folder if previous data folder
    % coinsided with previous phx folder;
    if strcmp(data_path,phx_path)
        phx_path=path;
    end
    path = uigetdir(phx_path,'Select folder to look for detector location (phx)  files');
    if ~isnumeric(path)
        set(mslice_config,'PhxDir',path);
    end
end

if select_cut
    % select guess value as new data folder if previous data folder
    % coinsided with previous phx folder;
    if strcmp(data_path,cut_path)
        cut_path=path;
    end
    path = uigetdir(cut_path,'Select folder to place your cut (cut, xye, smh or hkl)  files');
    if ~isnumeric(path)
        set(mslice_config,'cut_OutputDir',path);
    end
end

