function validate_mslice()
% functon to run tests whch verify the integrity of mslice package
% on 03/2012 is far from completeon
%
%   $Rev: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%

test_path=set_unit_test();
root_path=fileparts(which('mslice_init.m'));

runtests(fullfile(root_path,'admin','unit_test','test_object_collection'));

rmpath(test_path)


function test_path=set_unit_test()
root= fileparts(which('herbert_init.m'));
test_path = fullfile(root,'_test','matlab_xunit','xunit');
addpath(test_path);
