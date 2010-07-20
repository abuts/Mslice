function mslice_load_data (spe_file, phx_file, efix, emode, intensity_label, title_label)
% Fill fields for Load Data in mslice
%
%   >> mslice_load_data (spe_file, phx_file, efix, emode)
%   >> mslice_load_data (spe_file, phx_file, efix, emode, intensity_label, title_label)
%
% Required:
%   spe_file    spe file name
%   phx_file    phx file name
%   efix        Fixed energy (meV)
%   emode       =1 direct geometry, =2 indirect geometry
%
% Optional:
%   intensity_label     Character string for intensity axis
%   title_label         Title label

% T.G.Perring   Feb 2009
% Not very robust - e.g. doesn't perform all checks
% Could be generalised - e.g. if spe file does not include directory, us existing DataDir, if one


% check all files exist:
if ~exist(spe_file,'file')
    error (['SPE file ' spe_file ' does not exist'])
end
if ~exist(phx_file,'file')
    error (['PHX file ' phx_file ' does not exist'])
end

% load msp file
ms_setvalue('efixed',efix)
ms_setvalue('emode',emode)

% load spe file:
[path,file,ext] = fileparts(spe_file);
set(mslice_config,'DataDir',[path filesep]); 
ms_setvalue('DataFile',[file ext]); 

% load phx file:
[path,file,ext] = fileparts(phx_file);
set(mslice_config,'PhxDir',[path filesep]); 
ms_setvalue('PhxFile',[file ext]); 

% Optional labels
if exist('intensity_label')
    ms_setvalue('IntensityLabel',intensity_label)
end

if exist('title_label')
    ms_setvalue('TitleLabel',title_label)
end


% load data 
ms_load_data; 
