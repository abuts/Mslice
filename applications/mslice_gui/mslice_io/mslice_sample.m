function mslice_sample (alatt, angdeg, u, v, psi)
% Fill sample fields in mslice, for single crystal mode
%
%   >> mslice_sample (alatt, angdeg, u, v, psi)
%
%   >> mslice_sample ('powder')
%
%   alatt       Lattice parameters [a,b,c]
%   angdeg      Lattice angles (degrees) [aa,bb,cc]
%   u           Vector in reciprocal lattice units
%   v           Vector in reciprocal lattice units
%   psi         Orientation angle (deg)
%

% T.G.Perring   Feb 2009

% Check if powder mode, and set if selected
if nargin==1 && ischar(alatt) && strcmpi(alatt,'powder')
    ms_setvalue('sample',2)
    return
elseif nargin~=5
    error('Check number and type of input')
end
    

% Lattice parameters
if ~(isnumeric(alatt) && isequal(size(alatt(:),1),3) && all(alatt>0))
    error('Check lattice parameters')
end

% Lattice angles
if ~(isnumeric(angdeg) && isequal(size(angdeg(:),1),3) && all(angdeg>0))
    error('Check lattice parameters')
end

% Orientation vectors
if ~(isnumeric(u) && isequal(size(u(:),1),3) && ~all(u==0))
    error('Check orientation vector [ux,uy,uz]')
end

if ~(isnumeric(v) && isequal(size(v(:),1),3) && ~all(v==0))
    error('Check orientation vector [vx,vy,vz]')
end

% Crystal angle
if ~isnumeric(psi)
    error('Crystal angle nust be numeric')
end

% Set values, now checks have been performed
ms_setvalue('sample',1)     % Set in single crystal mode

ms_setvalue('as',alatt(1))
ms_setvalue('bs',alatt(2))
ms_setvalue('cs',alatt(3))

ms_setvalue('aa',angdeg(1))
ms_setvalue('bb',angdeg(2))
ms_setvalue('cc',angdeg(3))

ms_setvalue('ux',u(1))
ms_setvalue('uy',u(2))
ms_setvalue('uz',u(3))

ms_setvalue('vx',v(1))
ms_setvalue('vy',v(2))
ms_setvalue('vz',v(3))

ms_setvalue('psi_samp',psi)
