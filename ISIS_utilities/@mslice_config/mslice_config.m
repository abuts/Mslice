function this=mslice_config()
% Create the mslice configuration object 
%
%   >> this=mslice_config
%
% Type >> mslice_config  to see the list of current configuration option values.

%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below

root_config=mslice_root_config;

config_name=mfilename('class');
[ok,this]=is_config_stored(root_config,config_name);
if ~ok
    this=class(struct([]),config_name,root_config);
    build_configuration(this,@default_config,config_name);
end


%--------------------------------------------------------------------------------------------------
%  Alter only the contents of the following subfunction, and the help section of the main function
%
%  This subfunction sets the field names, their defaults, and which ones are sealed against change
%  by the 'set' method.
%
%  The sealed fields must be a cell array of field names, or can be empty. The matlab function
%  struct that can be used has confusing syntax for this purpose: suppose we have fields
%  called 'v1', 'v2', 'v3',...  then we might have:
%   - if no sealed fields:  ...,sealed_fields,{{''}},...
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%  Note that 'sealed_fields' will be treated as a sealed field, whether or not it is in the list.
%
%--------------------------------------------------------------------------------------------------
function defaults=default_config

defaults = ...
    struct('last_copied_libisis',1620, ... % by default, this is the lowest Libisis version which supports copying
    'MSliceDir','',...  % -- sealed: Mslice folder
    'SampleDir','',...  % -- sealed: folder with msp configuration files
    'MspDir','', ...    % folder with msp files which describe mslice configurations
    'MspFile','crystal_psd.msp',... % default msp file
    'DataDir','',...    % data files (spe files)
    'PhxDir','', ...    % phx files (detector angular positions)
    'cut_OutputDir','', ...  % defauld folder to save cuts.              % 'use_par_from_nxspe', 1 ... % if an nxspe file is selected as a source, use par, stored in nxspe file
    'enable_unit_tests',false ...
    ) ;


% Location of the default configuration file
if isdeployed
    defaults.MSliceDir=pwd;
    defaults.SampleDir=fullfile(defaults.MSliceDir,'Data');
else
    defaults.MSliceDir    = fullfile(fileparts(which('mslice_init.m')),'mslice');
    defaults.SampleDir    = fullfile(fileparts(which('mslice_init.m')),'Data');
end
defaults.DataDir      = defaults.SampleDir;
defaults.PhxDir       = defaults.SampleDir;

defaults.MspDir       = defaults.SampleDir;
ms_path = userpath();
if isempty(ms_path)
    ms_path = pwd;
end
defaults.cut_OutputDir=ms_path;
defaults.sealed_fields={'MSliceDir','SampleDir'}; % specify the fields which values can not be changed by user;
