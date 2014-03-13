function validate_mslice()
% functon to run tests whch verify the integrity of mslice package
% on 03/2012 is far from completeon
%
%   $Rev$ ($Date$)
%

test_path=set_unit_test();
root_path=fileparts(which('mslice_init.m'));

runtests(fullfile(root_path,'admin','_unit_test','test_object_collection'));


% temporary, untill Herbert IO completed
state = herbert_io();
%herbert_io('-off');
%runtests(fullfile(root_path,'admin','_unit_test','test_herbert_IO'));
herbert_io('-on');
runtests(fullfile(root_path,'admin','_unit_test','test_herbert_IO'));

if state
    herbert_io('-on');
else
    herbert_io('-off');
end


rmpath(test_path)


function test_path=set_unit_test()
try
    root= herbert_on('where');
catch
    error('herbert_on has not been found anywhere. Herbert provides unit tests package, so no unit tests availible for Mslice');
end
test_path = fullfile(root,'_test','matlab_xunit','xunit');
addpath(test_path);
