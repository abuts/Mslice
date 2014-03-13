function mslice_powder (varargin)
% Set mslice in powder mode and calculate projections
%
%   >> mslice_powder                % default (|Q|,E)
%   >> mslice_powder (u1, u2)       % set axes u1=1,2,3,4 or 5, u2=1,2,3,4 or 5
%                               1=Energy  2=|Q|  3=2Theta  4=Azimuth  5=Det Group Number
%
%   >> mslice_powder (lab1, lab2)           % default (|Q|,E) with customised labels
%   >> mslice_powder (u1, u2, lab1, lab2)   % set axes with customised labels

% T.G.Perring Feb 2009

lab={'Energy','|Q|','2Theta','Azimuth','DetNo'};

% Check input arguments
if nargin==0
    u1=2;   % |Q|
    u2=1;   % E
    l1=lab(u1);
    l2=lab(u2);
elseif nargin==2 && ok_axis(varargin{1}) && ok_axis(varargin{2})
    u1=varargin{1};
    u2=varargin{2};
    l1=lab(u1);
    l2=lab(u2);
elseif nargin==4 && ok_axis(varargin{1}) && ok_axis(varargin{2}) && ok_label(varargin{3}) && ok_label(varargin{4})
    u1=varargin{1};
    u2=varargin{2};
    l1=varargin{3};
    l2=varargin{4};
else
    error('check number of input arguments')
end

% Check powder sample
if strcmp(ms_getvalue('sample'),'single crystal');
    ms_setvalue('analysis_mode',2)  % single crystal sample, but powder mode
end

% Set values
ms_setvalue('u1',u1)
ms_setvalue('u2',u2)
ms_setvalue('u1label',l1)
ms_setvalue('u2label',l2)

% Perform calculation projections
ms_calc_proj

%---------------------------------------------------------------------------------------
function ok=ok_axis(val)
if isnumeric(val) && numel(val)==4 && (size(val,1)==1||size(val,2)==1) && ~all(numel)==0
    ok=true;
else
    ok=false;
end
    
%---------------------------------------------------------------------------------------
function ok=ok_label(val)
if ischar(val) && size(val,1)==1
    ok=true;
else
    ok=false;
end
