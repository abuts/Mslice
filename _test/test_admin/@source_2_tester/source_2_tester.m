function c=source_2_tester(arg)
%
%  Function to test herbert to mslcie synchronization
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%

a=arg;
b=get(mslice_config,'use_mex');
c=a+b;
end