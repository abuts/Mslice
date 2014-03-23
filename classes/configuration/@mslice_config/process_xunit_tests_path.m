function   process_xunit_tests_path(this, enable )
% Function processes Mslice unit tests path and enable Mslice to use unit
% test harness
%
%Usage:
%>> process_xunit_tests_path(mslice_config, enable )
% if enable is true, function checks necessary dependencies and sets mslice
% unit test harness on the Matlab path.
% if false, unit test harness is removed from the path
%
% $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
%

unit_test_base = which('herbert_init.m');
xunit_path  = fullfile(unit_test_base,'test','matlab_xunit','xunit');
if enable>0
    if isempty(unit_test_base)
        error('MSLICE_CONFIG:enable_unit_tests',' Mslice unit test rely on Herbert being initalized and it is not');
    end
    addpath(xunit_path);
    enable = true;
else
    warn_state=warning('off','all');    % turn of warnings (so don't get errors if remove non-existent path)
    rmpath(xunit_path)
    enable = false;
    warning(warn_state);    % return warnings to initial state
end
config_store.instance().store_config(this,'enable_unit_tests',enable);


end

