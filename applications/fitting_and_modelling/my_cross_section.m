function [s,wdisp]=my_cross_section(par,Q,w,data_pars)
% Cross-section model for simulation of scattering. Example to show most
% general usage. In particular, ensuring that the optional arguments
% data_pars and wdisp have the form described below enables other utilities to
% be used.
%
%	>> [s,wdisp]=my_cross_section(par,Q,w,data_pars)
%
% Input:
% ------
%   par             Parameters needed by the cross-section
%                     - Typically vector of scalars [p1 p2 ...]
%                     - but can be data structure, cell array...
%                   In this example:
%                       [amplitude, J, ichain_axis, const_bkgd, quad_bkgd] 
%                       e.g. [1.2,240,2,1.0,2.0] for chains along b*, with
%                           quadratic background inscattering angle
%   Q               Q points (h,k,l) (size(Q)=[n,3])
%   w               w values at Q (size(w)=[n,1])
%   data_pars       [Optional]. Structure with various useful parameters passed from mslice
%                  including length of reciprocal lattice vectors, scattering angles...
%                  Type >> help get_data_pars for full list.
% Output:
% -------
%   s               Calculated signal strength (size(s)=[n,1])
%   wdisp           [Optional]. Structure of calculated dispersion relation(s)
%                  at the points Q:
%                       wdisp.w1    size(wdisp.w1)=[n,1]
%                       wdisp.w2    size(wdisp.w2)=[n,1]
%                           :               :

% T.G.Perring  Sept. 2006

% Spinon continuum for S=1/2 Heisenberg antiferromagnet
sigma_mag=289.6d0;
small = 1e-5;

amp=par(1);     % amplitude
J=par(2);       % zone boundary energy pi/2*J for lower bound
ichain=par(3);  % chain direction h=1, k=2, l=3
q=Q(:,ichain);
w1=(pi*J/2)*abs(sin(2*pi*q));
w2=  (pi*J)*abs(sin(pi*q));

wdisp.w1=w1;       % Keep lower bound as dispersion
wdisp.w2=w2;       % Keep lower bound as dispersion
s=amp*(sigma_mag/pi)*((w>(w1+small)).*(w<=w2))./sqrt(max(w.^2-w1.^2,(small^2).*ones(size(q))));

const_bkgd = par(4);
quad_bkgd = par(5);
bkgd = const_bkgd + quad_bkgd*(data_pars.theta.^2 + data_pars.psi.^2);

s = s + bkgd;
