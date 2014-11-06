function msfun_mult_eps(pwr)
% Multiply dataset by eps^(p):
%
%   >> msfun_mult_eps		% multiply by eps
%
%   >> msfun_mult_eps(p)	% multiply by eps^p

d=fromwindow;
if nargin==0
    d.S = d.S.*(repmat(d.en,size(d.S,1),1));
    d.ERR = d.ERR.*(repmat(d.en,size(d.S,1),1));
else
    d.S = d.S.*(repmat(d.en,size(d.S,1),1)).^pwr;
    d.ERR = d.ERR.*(repmat(d.en,size(d.S,1),1)).^pwr;
end
towindow(d);
