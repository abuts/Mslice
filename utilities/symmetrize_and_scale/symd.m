function symd(n1,n2,n)
% Symmetrise data about the diagonals
%   >> symd(n1,n2,n)
% n1, n2    Horizontal and vertical axes labels, call them h and k,
%          assumed orthogonal and in the same units
% n         Determines symmetrization:
%
% symd(n1,n2,1) Symmetrize data with respect to the diagonal h=k
%               Data folded into area below this diagonal (i.e. lower right)
% symd(n1,n2,2) Symmetrize data with respect to the diagonal h=-k
%               Data folded into area above this diagonal (i.e. upper right)
% symd(n1,n2,3) Symmetrize data with respect to both diagonals 
%               Data folded into quadrant centred on positive horizontal axis
%

% Algorithm by R.Coldea.
% T.G.Perring added more copious checks on input arguments

% Check input
if nargin~= 3; error('Check number of arguments to symgen'); end
if min(n1,n2)<1|max(n1,n2)>3; error('Check indicies of viewing axes passed to symd'); end
if n1==n2; error('Indicies of viewing axes must be different (symd)'); end

% Get data from Mslice:
data=fromwindow;

% Check that neither of the two viewing axes are energy
if strcmp(data.axis_unitlabel(n1,1:5),'(meV)')|strcmp(data.axis_unitlabel(n2,1:5),'(meV)')
    error('Viewing axes cannot be along energy axis')
end

% Get length of viewing axes in inverse Angstroms
xlength = data.axis_unitlength(n1);
ylength = data.axis_unitlength(n2);

if abs(xlength-ylength)/sqrt(xlength*ylength) > 0.001
    disp('WARNING: unit lengths along the two symmetrisation axes are not the same')
end

% Transform to rotated reference frame where +x-axis is along diagonal at 45 deg
% and +y-axis is along diagonal at 135 deg
x=( data.v(:,:,n1)+data.v(:,:,n2))/sqrt(2);
y=(-data.v(:,:,n1)+data.v(:,:,n2))/sqrt(2);

% Now perform symmetrization in the xy reference frame i.e fold -x over x and -y over y 
if n==1,       % fold y onto -y
   y=-abs(y);
elseif n==2,   % fold -x onto x
   x=abs(x);
elseif n==3,   % fold -x onto x and y onto -y
   x=abs(x);
   y=-abs(y);
end    

% Transform back into the original horizontal-vertical hk reference frame
data.v(:,:,n1)=(x-y)/sqrt(2);
data.v(:,:,n2)=(x+y)/sqrt(2);
label=sprintf('symd(%g,%g,%g)',n1,n2,n);      
data.title_label=label;

% Put data back into mslice
towindow(data);

