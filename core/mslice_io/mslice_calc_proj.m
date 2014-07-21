function mslice_calc_proj (varargin)
% Set parameters for calculate projections with single crystals. 
% Determines if powder analysis, and PSD or non-PSD from number of arguments
%
%   >> mslice_calc_proj (u1, u2)        % single crystal non-PSD mode
%   >> mslice_calc_proj (u1, u2, u3)    % single crystal PSD mode
%
% With customised labels:
%   >> mslice_calc_proj (u1, u2, lab1, lab2)            % non-PSD mode
%   >> mslice_calc_proj (u1, u2, u3, lab1, lab2, lab3)  % PSD mode

% T.G.Perring Feb 2009

% Check single crystal sample
if ~strcmp(ms_getvalue('sample'),'single crystal');
    error('Sample is not a single crystal')
end

% Check input arguments
if nargin==2 && ok_view_axis(varargin{1}) && ok_view_axis(varargin{2})
    psd_mode=false;
    u1=varargin{1};
    u2=varargin{2};
    l1='u1';
    l2='u2';
elseif nargin==3 && ok_view_axis(varargin{1}) && ok_view_axis(varargin{2}) && ok_view_axis(varargin{3})
    psd_mode=true;
    u1=varargin{1};
    u2=varargin{2};
    u3=varargin{3};
    l1='u1';
    l2='u2';
    l3='u3';
elseif nargin==4 && ok_view_axis(varargin{1}) && ok_view_axis(varargin{2}) && ok_label(varargin{3}) && ok_label(varargin{4})
    psd_mode=false;
    u1=varargin{1};
    u2=varargin{2};
    l1=varargin{3};
    l2=varargin{4};
elseif nargin==6 && ok_view_axis(varargin{1}) && ok_view_axis(varargin{2}) && ok_view_axis(varargin{3}) ...
                 && ok_label(varargin{4}) && ok_label(varargin{5}) && ok_label(varargin{6})
    psd_mode=true;
    u1=varargin{1};
    u2=varargin{2};
    u3=varargin{3};
    l1=varargin{4};
    l2=varargin{5};
    l3=varargin{6};
else
    error('Check number and type of input arguments')
end

% Set values
ms_setvalue('analysis_mode',1)  % set single crystal analysis
if psd_mode
    ms_setvalue('det_type',1)
else
    ms_setvalue('det_type',2)
end

ms_setvalue('u11',u1(1))
ms_setvalue('u12',u1(2))
ms_setvalue('u13',u1(3))
if numel(u1)==4
    ms_setvalue('u14',u1(4))
else
    ms_setvalue('u14',0)
end

ms_setvalue('u21',u2(1))
ms_setvalue('u22',u2(2))
ms_setvalue('u23',u2(3))
if numel(u2)==4
    ms_setvalue('u24',u2(4))
else
    ms_setvalue('u24',0)
end

if psd_mode
    ms_setvalue('u31',u3(1))
    ms_setvalue('u32',u3(2))
    ms_setvalue('u33',u3(3))
    if numel(u3)==4
        ms_setvalue('u34',u3(4))
    else
        ms_setvalue('u34',0)
    end
end

ms_setvalue('u1label',l1)
ms_setvalue('u2label',l2)
if psd_mode
    ms_setvalue('u3label',l3)
end

% Perform projection
ms_calc_proj

%---------------------------------------------------------------------------------------
function ok=ok_view_axis(val)
if isnumeric(val) && (size(val,1)==1||size(val,2)==1) && (numel(val)==3 || numel(val)==4)
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
