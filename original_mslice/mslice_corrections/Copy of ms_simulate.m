function ms_simulate(p1,p2,p3,p4,p5)
% Read spectrometer and single crystal/powder information from MSlice Control Window
% and simulate scattering, put data back into the ControlWindow
%
% 	>> ms_simulate(crossection,parameters)
%
% 	>> ms_simulate(emin,emax,de,crossection,parameters)
%
% Input:
% ------
% emin,emax,de      Energy transfer range (outermost bin boundaries) and bin size
%                   - Optional if an .spe file has been provided; in this case
%                    the energy bins will be picked up from the .spe file.
%                   - Must be provided if an .spe file has not been loaded
%
% crossection       Cross-section model:
%                   - Function handle to cross-section function (see below)
%            *OR*   - For backwards compatibility with original ms_simulate:
%                    Model number = 1,2,.. in the function ms_sqw
%
% parameters        Cross-section parameters as required by function
%                   - Typically vector of scalars [p1 p2 ...]
%                   - but can be data structure, cell array...
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
% Based on R.Coldea's original ms_simulate

% === return if MSlice ControlWindow not active
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp(['MSlice Control Window has to be opened first before simulation can begun.']);
   return
end

% === return if detector information not loaded yet
data=fromwindow;
if isempty(data),
   disp(['Need to load detector information in a .phx file first.']);
   return;
end
ms_calc_proj;
data=fromwindow;

% === generate energy grid
if nargin==5
    emin=p1;emax=p2,de=p3;crossection=p4;parameters=p5;
    data.en=emin:de:emax;
    data.en=data.en(1:(end-1))+de/2; % choose midpoints per each bin
elseif nargin==2
    if ~isfield(data,'en')
        disp('Must provide energy bins or spe file for simulation');
        return
    end
    crossection=p1;parameters=p2;
end

% === simulate scattering in each detector
Q=spe2sqe(data);	% create wavevector Q (ndet,ne,3) in spectrometer reference frame 	
Q=sqe2samp(Q,data.psi_samp);	% transform (Q,E)->(Qx',Qy',Qz',E) into sample reference frame Q[Å^{-1}]
Q=q2rlu(Q,data.ar,data.br,data.cr);
[ndet,ne]=size(Q(:,:,1)); % ndet = number of detector groups, ne=numberof energy bins
en=ones(ndet,1)*data.en;	% table (ndet,ne)
theta=data.det_theta*ones(size(data.en)); % table(ndet,ne)
Qx=Q(:,:,1); % (ndet,ne)
Qy=Q(:,:,2);
Qz=Q(:,:,3);
Q=[Qx(:) Qy(:) Qz(:)]; % (ndet*ne,3)
%=== modified T.G.Perring sept 2006: ==========
if class(crossection)~='function_handle'
    data.S=ms_sqw(crossection,parameters,Q,en(:),theta(:),data.ar,data.br,data.cr);
    data.filename=['cross=' num2str(crossection) ', p=['];
else
    data.S=crossection(parameters,Q,en(:),theta(:),data.ar,data.br,data.cr);
    data.filename=['cross=' func2str(crossection) ', p=['];
end
%==============================================
data.S=reshape(data.S,ndet,ne);
if isempty(data.S),
   disp(['Cross-section type ' crosssection ' not available.']);
   return
end
data.ERR=0.1*data.S;	% put arbitrary errors of 10% intensity
for i=1:length(parameters),
   data.filename=[data.filename sprintf(' %g,',parameters(i))];
end
data.filename=[data.filename(1:(end-1)) ']'];
towindow(data);
ms_calc_proj;
