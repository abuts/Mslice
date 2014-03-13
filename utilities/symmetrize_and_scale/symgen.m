function symgen(n1,n2,theta)
% Symmetrise data in Mslice by reflecting through a plane.
%
% Syntax:
%
%   >> sym(n1,n2,theta)
%
%   n1, n2      Index of two of the viewing axes to define a plane
%              in reciprocal space
%   theta       Angle (deg) w.r.t. axis n1 and towards axis n2 of the line 
%              of intersection of the reflection plane with the plane 
%              defined by n1 and n2.
%
% Notes:
% ------
% (1) The algorithm constructs a new x-axis along the line defined by theta, and
% folds the data over this axis onto the positive new y-axis
%
% (2) theta can be an array, in which case each transformation is applied successively
%
% e.g.
%
%   >> sym(1,2,45)          % folds data in upper-left across diagonal
%                             pointing to north-east
%
%   >> sym(1,2,[-45,-135])  % folds data into quadrant enclosed by south-east 
%                             to north-east
%
% T.G.Perring

% Check input
if nargin~= 3; error('Check number of arguments to symgen'); end
if min(n1,n2)<1|max(n1,n2)>3; error('Check indicies of viewing axes passed to symgen'); end
if n1==n2; error('Indicies of viewing axes must be different (symgen)'); end

% Get data from Mslice:
data=fromwindow;

% Check that neither of the two viewing axes are energy
if strcmp(data.axis_unitlabel(n1,1:5),'(meV)')|strcmp(data.axis_unitlabel(n2,1:5),'(meV)')
    error('Viewing axes cannot be along energy axis')
end

% Get length of viewing axes in inverse Angstroms
xlength = data.axis_unitlength(n1);
ylength = data.axis_unitlength(n2);

for i=1:length(theta)
    ct=cos(theta(i)*pi/180);
    st=sin(theta(i)*pi/180);
% New coordinate frame is defined by x axis at angle theta to viewing axis n1
% Convert coordinates to inverse Angstroms and calculate new x, y coordinates,
% folding the data about the new axis to have +ve value along new y-axis.
% Finally, convert x, y axes to have unit lengths the same as n1, n2.
    x=(ct*xlength)*data.v(:,:,n1)+(st*ylength)*data.v(:,:,n2);
    y=abs(-(st*xlength)*data.v(:,:,n1)+(ct*ylength)*data.v(:,:,n2));
    data.v(:,:,n1)= (ct*x-st*y)/xlength;
    data.v(:,:,n2)= (st*x+ct*y)/ylength;
end
format_string = repmat('%g,',1,length(theta));
format_string = format_string(1:end-1);
label=sprintf(['symgen(%g,%g) rot(',format_string,')'],n1,n2,theta);
data.title_label=label;

% Put data back into mslice
towindow(data);
