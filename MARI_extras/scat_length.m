function [L]=scat_length(RMM,rho,xsec)
%calc length of sample for a 10% scatterer
%density in gcm^3
%[l]=scat_length(RMM,rho,xsec)
sig=((rho.*6.023e23)./RMM).*(xsec.*1e-24);

L=(log(.9)./sig).*-10

mass=(16.*(L./10)).*rho