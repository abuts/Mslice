function version=matlab_version_num()
% function returns numeric representation of symbolic string, which reports
% Matlab version
%
% $Revision$ ($Date$)
%
vr = ver('MATLAB');
vers = vr.Version;
vs = regexp(vers,'\.','split');
version = str2double(vs{1})+0.01*str2double(vs{2});