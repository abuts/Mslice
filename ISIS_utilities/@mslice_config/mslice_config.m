function conf=mslice_config()
% the constructor describing horace-memory and some other defaults configuration and providing singleton
% behaviour.
%
% Do not inherit your configuration classes from this class; 
% Inherit from the basic class 'config' instead
%
%
% $Revision: 1676 $ ($Date: 2010-05-17 18:08:06 +0100 (Mon, 17 May 2010) $)
%
global configurations;

%this_class_name=mfilename('class');
this_class_name='mslice_config';

% this is generig code which has to be copied to any consrucor, inheriting
% from the class "config"
[is_in_memory,n_this_class,child_structure] = build_child(config,@homer_defaults,this_class_name);
if is_in_memory
    conf=configurations{n_this_class};
else
    conf = class(child_structure,this_class_name,configurations{1});   
    configurations{n_this_class}=conf;
end

function defaults=homer_defaults()
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
            'PhxDir','', ...
            'cut_OutputDir','' ...
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
defaults.fields_sealed={'fields_sealed','MSliceDir','SampleDir'...
                        }; % specify the fields which values can not be changed by user;







