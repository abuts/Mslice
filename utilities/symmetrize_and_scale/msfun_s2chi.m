function msfun_s2chi(T)
% COnverts S(Q,w) to X''(Q,w): X''(Q,w) = S(Q,w)*(1-exp(-hbar.w/kB.T)))
%
%   >> msfun_s2chi(T)   % T = temperature in Kelvin

d=fromwindow;
y = 1 - exp(-(11.065/T).*d.en);    % Recall 1 meV = 11.6045 K
d.S = d.S.*(repmat(y,size(d.S,1),1));
d.ERR = d.ERR.*(repmat(y,size(d.S,1),1));
towindow(d);
