function version=matlab_version_num()
% function returns numeric representation of symbolic string, which reports
% Matlab version
%
% $Revision: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%
vr = ver('MATLAB');
vers = vr.Version;
vs = regexp(vers,'\.','split');
version = str2double(vs{1})+0.01*str2double(vs{2});