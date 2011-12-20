function conf=mslice_config()
% the constructor describing horace-memory and some other defaults configuration and providing singleton
% behaviour.
%
% Do not inherit your configuration classes from this class; 
% Inherit from the basic class 'config' instead
%
%
% $Revision: 1835 $ ($Date: 2011-10-22 22:49:44 +0100 (Sat, 22 Oct 2011) $)
%
%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below
persistent this_local;

if isempty(this_local)
    config_name=mfilename('class');

    build_configuration(config,@mslice_defaults,config_name);    
    this_local=class(struct([]),config_name,config);
end
conf = this_local;


function defaults=mslice_defaults()
% functuion builds the structure, which describes default parameters used
% by mslice;
% This structure is used if no previous configuration has been defined on
% this machine,e.g. configuration file does not exist. 
% Ths function also can define the fields which will always have default
% values specifying their names in the field:
% fields_sealed

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
    

% and the location of the default configuration file
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
defaults.sealed_fields={'sealed_fields','MSliceDir','SampleDir'...
                        }; % specify the fields which values can not be changed by user;







