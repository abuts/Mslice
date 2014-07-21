function sym(n1,n2)
% Symmetrise data in Mslice by reflecting through a plane.
%
% Syntax:
%
%    >> sym(n1)     % Symmetrise along axis n1
% OR >> sym(n1,n2)  % Symmetrise along axes n1 and n2
%
%
% T.G.Perring, based on R.Coldea

% Check input
if nargin>2; error('Check number of arguments to sym'); end
if nargin==2
    if min(n1,n2)<1|max(n1,n2)>3; error('Check indicies of viewing axes passed to sym'); end
    if n1==n2; disp('WARNING: Indicies of the symmetriseation axes are identical (sym)'); end
end

% Get data from Mslice:
data=fromwindow;

% Check that neither of the two viewing axes are energy
if strcmp(data.axis_unitlabel(n1,1:5),'(meV)')
    error('Viewing axes cannot be along energy axis')
end
if nargin==2
    if strcmp(data.axis_unitlabel(n2,1:5),'(meV)')
        error('Viewing axes cannot be along energy axis')
    end
end

% Symmetrise data
if nargin==1,
   data.v(:,:,n1)=abs(data.v(:,:,n1));
   label=sprintf('sym(%g)',n1);
elseif nargin==2,   
   data.v(:,:,n1)=abs(data.v(:,:,n1));
   data.v(:,:,n2)=abs(data.v(:,:,n2));
   label=sprintf('sym(%g,%g)',n1,n2);      
end
data.title_label=label;

% Put data back into mslice
towindow(data);
