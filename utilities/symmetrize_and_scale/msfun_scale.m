function msfun_scale(scale)
% Multiply dataset by scale factor:
%
%   >> msfun_scale(scale)
d=fromwindow;
d.S = d.S.*scale;
d.ERR = d.ERR.*scale;
towindow(d);
