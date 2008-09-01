function intensity = simulate_spe(crossection, parameters, data)
% Simulate scattering from a model cross-section
%
% 	>> intensity = simulate_spe(crossection,parameters,data)
%
% Input:
% ------
% crossection       Cross-section model:
%                   - Function handle to cross-section function (see below)
%            *OR*   - For backwards compatibility with original ms_simulate:
%                    Model number = 1,2,.. in the function ms_sqw
%
% parameters        Cross-section parameters as required by function
%                   - Typically vector of scalars [p1 p2 ...]
%                   - but can be data structure, cell array...
%
% data              Data as obtained from >> data = fromwindow   after
%                  performing 'load data' and 'calculate projections'
%
%
% Output:
% -------
% intensity         Array size(ndet,ne) of intensities at the pixels, suitable
%                  for replacing data.S
%
%
% Use with a cross-section function
% --------------------------------------
%   >> intensity = simulate_spe (@my_cross_section, parameters, data)
%
%   The cross-section function can be anywhere on the Matlab path and
%  have any name; the function has the form:
%
%   function [s,wdisp]=my_cross_section(parameters,Qhkl,en,data_pars)
%
% Input:
% ------
%   parameters      Parameters needed by the cross-section
%                     - Typically vector of scalars [p1 p2 ...]
%                     - but can be data structure, cell array...
%   Qhkl            Q points (h,k,l) at which to evaluate function (size(Q)=(n,3))
%   en              Energies values at those Q points (size(w)=n)
%   data_pars       [Optional]. Structure with various useful parameters passed from mslice
%                  including length of reciprocal lattice vectors, scattering angles...
%                  Type >> help get_data_pars for full list.
%
% Output:
% -------
%   s               Calculated signal strength (size(s)=[n,1])
%   wdisp           [Optional]. Structure of calculated dispersion relation(s)
%                  at the points Q:
%                       wdisp.w1    size(wdisp.w1)=[n,1]
%                       wdisp.w2    size(wdisp.w2)=[n,1]
%                           :               :
%
%
% Backwards compatibility: if model is in the function ms_sqw:
% ------------------------------------------------------------
%   Edit the function ms_sqw to add an extra cross-section model number,
%  and then simulate by calling ms_simulate with that cross-section number:
%    e.g.
%       >> intensity = simulate_spe (icross, parameters, data)
%
%   The function ms_sqw has form:
%
%       function [s,wdisp]=ms_sqw(icross,parameters,Q,w,theta,ar,br,cr)
%
%   The meaning of the parameters is given by >> help ms_sqw
%
%
% T.G.Perring, Sept 2006:

[Q,en] = get_hkle(data);    % Get hkle for each pixel
 
if class(crossection)~='function_handle'    % original ms_sqw format
    theta=data.det_theta*ones(size(data.en));
    intensity=ms_sqw(crossection,parameters,Q,en,theta(:),data.ar,data.br,data.cr);
    if isempty(intensity),
        disp(['Cross-section type ' crosssection ' not available.']);
        return
    end
else
    dd = get_data_pars(data);
    n_argin = nargin(crossection);
    if n_argin==3
        intensity=crossection(parameters,Q,en);
    else
        intensity=crossection(parameters,Q,en,dd);
    end
end

ndet=length(data.det_theta);
ne  =length(data.en);
intensity=reshape(intensity,ndet,ne);
