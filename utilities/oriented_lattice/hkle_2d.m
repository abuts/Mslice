function hkle=hkle_2d (data, varargin)
% Return h,k,l and en for a series of points on a 2D slice (single crystal, PSD mode only)
% Must have previously done a 'calculate projections', and obtain data with fromwindow.
%
%   >> data = fromwindow;
%   >> hkle = hkle_2d (data, u1, u2, u3, pos_xy)
%
%   u1, u2, u3      Define the slice (see below,; same as slice_2d)
%   pos_xy          (n x 2) array of (x,y) positions in the slice
%                          x1,y1
%                          x2,y2,
%                            :
%   
%   hkle            [4 x n] array of h,k,l,e for each of the points

%   Determines which is the perpendicular axis as being the instance of u1,
%  u2 or u3 that has only two elements
%   e.g.  >> hkle = hkle_2d (data,[0.5,0.03,1.5],[-0.1,0.1],[-0.5,2,95]);
%  has the second projection axis as the plane perpendicular
%

% T.G.Perring   Feb 2009
% Currently works only for single crystal PSD mode

if numel(varargin)~=4
    error('Check number of arguments')
end

if isnumeric(varargin{4}) && numel(size(varargin{4}))==2
    x=varargin{4}(:,1);
    y=varargin{4}(:,2);
else
    error('Check number and type of input arguments')
end

u=zeros(3,numel(x));
if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
    u1=varargin{1}; u2=varargin{2}; u3=varargin{3};
    n1=numel(u1); n2=numel(u2); n3=numel(u3);
    if n1==2 && n2==3 && n3==3
        u(1,:)=0.5*(u1(1)+u1(2));
        u(2,:)=x(:);
        u(3,:)=y(:);
    elseif n1==3 && n2==2 && n3==3
        u(1,:)=y(:);
        u(2,:)=0.5*(u2(1)+u2(2));
        u(3,:)=x(:);
    elseif n1==3 && n2==3 && n3==2
        u(1,:)=x(:);
        u(2,:)=y(:);
        u(3,:)=0.5*(u3(1)+u3(2));
    else
        error('Check number and type of arguments')
    end
else
    error('Check number and type of arguments')
end

% Get the missing fourth component of (Q,w)
if max(abs(data.u(:,4)))==0  % all three projection axes are Q
    hkle=data.u'*u;
    xcryst=[data.ar',data.br',data.cr']*hkle(1:3,:);     % in orthonormal frame, x||u, z||(u x v)
    qpara=cos(data.psi_samp)*xcryst(1,:)-sin(data.psi_samp)*xcryst(2,:);
    qperp=sin(data.psi_samp)*xcryst(1,:)+cos(data.psi_samp)*xcryst(2,:);
    qz=xcryst(3,:);
    cnvrt=2.07; % for consistency with rest of mslice
    if data.emode==1
        ki=sqrt(data.efixed/cnvrt);
        hkle(4,:)=data.efixed-cnvrt*((ki-qpara).^2 + qperp.^2 + qz.^2);
    else    % indirect geometry
       error('Not yet implemented for indirect geometry')  
    end
else
    error('Not yet implemented for energy as one of the viewing axes')
end
