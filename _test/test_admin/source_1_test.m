function c=source_1_test(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision$ ($Date$)
%

a=arg;
b=get(mslice_config,'use_mex');
c=a+b;
end