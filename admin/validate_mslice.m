function validate_mslice(varargin)
% functon to run tests whch verify the integrity of mslice package
% on 03/2014 is far from completeon
%
%   $Rev$ ($Date$)
%

options = {'-parallel','-talkative'};

if nargin==0
    talkative=false;
    parallel=false;
else
    [ok,mess,parallel,talkative]=parse_char_options(varargin,options);
    if ~ok
        error('VALIDATE_HERBERT:invalid_argument',mess)
    end
end


%==============================================================================
% Place list of test folders here (relative to the master _test folder)
% -----------------------------------------------------------------------------
test_folders={...
    'test_object_collection',...
    'test_utilities',...
    };
% Generate full test paths to unit tests:
rootpath = fileparts(which('mslice_init'));
test_path=fullfile(rootpath,'_test');   % path to folder with all unit tests folders:
test_folders_full = cellfun(@(x)fullfile(test_path,x),test_folders,'UniformOutput',false);

%=============================================================================
% On exit always revert to initial Mslice configuration
% ------------------------------------------------------
% (Validation must always return Mslice to its initial state, regardless
%  of any changes made in the test routines.
%
cur_config=get(mslice_config);
cleanup_obj=onCleanup(@()validate_herbert_cleanup(cur_config,test_folders_full));


% Run unit tests
% --------------
% Set Mslice configuration to the default (but don't save)
% (The validation should be done starting with the defaults, otherwise an error
%  may be due to a poor choice by the user of configuration parameters)
mc = mslice_config();
mc.saveable = false; % equivalent to older '-buffer' option for all setters below

%set(mc,'defaults'); -- defaults for mslice are no unit tests. Then test 
                       % will not work without herbert_on
mc.init_tests = true;   % initialise unit tests
if ~talkative
 %  mc.log_level=-1; % turn off mslice informational output -- currently
 %  disabled
end


% temporary, untill Herbert IO completed
%state = herbert_io();
%herbert_io('-off');
%runtests(fullfile(root_path,'admin','_unit_test','test_herbert_IO'));
%herbert_io('-on');
runtests(test_folders_full{:});

%=================================================================================================================
function validate_herbert_cleanup(cur_config,test_folders)
% Reset the configuration
set(mslice_config,cur_config);
% clear up the test folders, previously placed on the path
warn = warning('off','all'); % avoid varnings on deleting non-existent path
for i=1:numel(test_folders)
    rmpath(test_folders{i});
end
warning(warn);


