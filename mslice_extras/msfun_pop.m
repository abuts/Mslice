function msfun_pop(T)
% Multiplies by (hbar.w/kB.T)/(1-exp(-hbar.w/kB.T)))
%
%   >> msfun_pop(T)   % T = temperature in Kelvin
%
% To invert, i.e. divide by (hbar.w/kB.T)/(1-exp(-hbar.w/kB.T))),
% use negative T
%
% *** NOT a correction for the Bose factor

d=fromwindow;
y = pop((11.6045/abs(T)).*d.en);    % Recall 1 meV = 11.6045 K
if T<0
    y=1./y;
end
d.S = d.S.*(repmat(y,size(d.S,1),1));
d.ERR = d.ERR.*(repmat(y,size(d.S,1),1));
towindow(d);

%====================================================================================
function p = pop(y)
% Calculates the function y/(1-exp(-y)), looking after negative y and y near zero

by2=0.5; by6=1/6; by60=1/60; by42=1/42; by40=1/40;

p=zeros(size(y));

yabs=abs(y);
ibig=yabs>0.1;
ibigneg=ibig & y<0;

p(ibig)    = yabs(ibig) ./ (1 - exp(-yabs(ibig)));
p(ibigneg) = p(ibigneg) .* exp(-yabs(ibigneg));
p(~ibig)   = 1 + by2*y(~ibig).*( 1 + by6*y(~ibig).*...
    (1 - by60*(y(~ibig).^2).*(1-by42*(y(~ibig).^2).*(1-by40*(y(~ibig).^2) ))));
