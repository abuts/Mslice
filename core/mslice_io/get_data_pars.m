function dd = get_data_pars(data)
% Package various parameters from the data into a structure for use in e.g. simulations
%
% 	>> dd = get_data_pars(data)
%
% Input:
% ------
% data      Data as obtained from >> data = fromwindow; after
%          performing 'load data' and 'calculate projections'
% Output:
% -------
% dd        Various data parameters, some derived, some simply copied, from data
%       dd.theta            scattering angle for each pixel
%       dd.psi              azimuthal angle for each pixel
%       dd.arlu             [1x3] length of a*,b*,c* (Ang^-1)
%
%       dd.en               [1xne] energy bin centres
%       dd.det_theta        [ndetx1] scattering angle for each detector
%       dd.det_psi          [ndetx1] azimuthal angle for each detector
%       dd.emode            =1 direct geometry; =2 indirect geometry
%       dd.efixed           fixed energy value
%       dd.ar           -|  a*, b*, c* (Ang^-1) in orthonormal frame
%       dd.br            |- with x-axis || u, z-axis || u x v
%       dd.cr           -|
%       dd.psi_samp         Psi anlge of sample (rad)
%       dd.uv               [2x3] scattering plane vectors u and v in r.l.u.
%
% Modified T.G.Perring, Sept 2006:

% Values derived from fields in data:
theta    = data.det_theta*ones(size(data.en)); % scattering angle for each pixel
psi      = data.det_psi  *ones(size(data.en)); % azimuthal angle for each pixel
dd.theta = reshape(theta,prod(size(theta)),1);
dd.psi   = reshape(psi,prod(size(psi)),1);
dd.arlu  = [norm(data.ar),norm(data.br),norm(data.cr)]; % length of a*,b*,c* (Ang^-1)

% Values transfered directly from fields in data:
dd.en    = data.en;
dd.det_theta = data.det_theta;
dd.det_psi   = data.det_psi;
dd.emode = data.emode;
dd.efixed= data.efixed;
dd.ar    = data.ar;
dd.br    = data.br;
dd.cr    = data.cr;
dd.psi_samp = data.psi_samp;
