function   [enable,xunit_path]=process_xunit_tests_path(this, enable )
% Function processes Mslice unit tests path and enable Mslice to use unit
% test harness
%
%Usage:
%>> process_xunit_tests_path(mslice_config, enable )
% if enable is true, function checks necessary dependencies and sets mslice
% unit test harness on the Matlab path.
% if false, unit test harness is removed from the path.
%
% Unit test harness is taken from Herbert. First time this function is
% deployed, Herbert has to be present on the matlab search path. 
% Later it can be taken from stored configuration file.
%
% $Revision$ ($Date$)
%

unit_test_base = fileparts(which('herbert_init.m'));
xunit_path  = fullfile(unit_test_base,'_test','matlab_xunit','xunit');
if enable>0
    if isempty(unit_test_base)
        xunit_path=config_stor_msl.instance().get_config_field(this,'last_unittest_path');
        if isempty(xunit_path);
            warning('MSLICE_CONFIG:enable_unit_tests',[' Mslice unit test rely on Herbert being installed and identified by Mslice at least once.\n' ...
                                                        'Apparently it was not. Unit tests are not enabled.\n' ...
                                                        'Initialize Herbert, type mslice_config and set ans.init_tests=1 with Herbert enabled at least once\n']);
            enable = false;
        else
            addpath(xunit_path);
            enable = true;
        end
    else
        addpath(xunit_path);
        enable = true;
    end
else
    warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
    rmpath(xunit_path)
    enable = false;
    warning(warn_state);    % return warnings to initial state
end
