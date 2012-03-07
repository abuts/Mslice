function run_unit_tests()
%
%   $Rev: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%

test_path=set_unit_test();

runtests test_object_collection

rmpath(test_path)


function test_path=set_unit_test()
root= fileparts(which('herbert_init.m'));
test_path = fullfile(root,'_test','matlab_xunit','xunit');
addpath(test_path);
