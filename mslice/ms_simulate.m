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
%   >> ms_simulate (@my_cross_section, parameters)
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
%       >> ms_simulate (icross, parameters)
%
%   The function ms_sqw has form:
%
%       function [s,wdisp]=ms_sqw(icross,parameters,Q,w,theta,ar,br,cr)
%
%   The meaning of the parameters is given by >> help ms_sqw
%

% *** ISIS changes
% T.G.Perring, Sept 2006:
%   Generalise original ms_simulate to use function handles

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
data.S = simulate_spe(crossection, parameters, data);

if class(crossection)~='function_handle'
    data.ERR=0.1*data.S;            % put arbitrary errors of 10% intensity - for backwards compatibility
    data.filename=['cross=' num2str(crossection) ', p=['];
    if isempty(data.S),
       disp(['Cross-section type ' crosssection ' not available.']);
       return
    end
else
    data.filename=['cross=' func2str(crossection) ', p=['];
end
for i=1:length(parameters),
    data.ERR=zeros(size(data.S));   % zero errors
    data.filename=[data.filename sprintf(' %g,',parameters(i))];
end
data.filename=[data.filename(1:(end-1)) ']'];

% === put data back into mslice control window
towindow(data);
ms_calc_proj;
