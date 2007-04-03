function multivolume_data=multires3d(x,y,z, int, err, vx_min,vx_max,bin_vx,fix_x,vy_min,vy_max,bin_vy,fix_y,vz_min,vz_max,bin_vz,fix_z,NLEVEL,NERROR,varargin)
%____________________________________________________________________________________________
% multivolume_data=multires3d(x,y,z,int,err,...
%                                           vx_min,vx_max,bin_vx,fix_x,...
%                                           vy_min,vy_max,bin_vy,fix_y,...
%                                           vz_min,vz_max,bin_vz,fix_z,...
%                                           NLEVEL,NERROR,varargin)
%                           
% required inputs:
%
%  	  x   (n,1)     projections of data points on the x axis.
%  	  y   (n,1)     projections of data points on the y axis.
%  	  z   (n,1)     projections of data points on the z axis.
%     int (n,1)     intensities associated to data points.
%     err (n,1)     corresponding errors.
%        
%     (*)where n is the total number of raw input data
%
%     vx_min,vx_max,bin_vx, ->  to stablish the boundaries and the maximum bin size for x axis.
%                               different grids will be constructed starting from minimum bin size:
%                               'bin_vx_min' (= bin_vx/(2.^(NLEVEL-1))] up to 'bin_vx'.
%     vy_min,vy_max,bin_vy, ->  to stablish the boundaries and the maximum bin size for y axis.
%                               different grids will be constructed starting from minimum bin size:
%                               'bin_vy_min' (= bin_vy/(2.^(NLEVEL-1))] up to 'bin_vy'.
%     vz_min,vz_max,bin_vz, ->  to stablish the boundaries and the maximum bin size for z axis.
%                               different grids will be constructed starting from minimum bin size:
%                               'bin_vz_min' (= bin_vz/(2.^(NLEVEL-1))] up to 'bin_vz'.
%
%     fix_x(1,1),               In case we want to perform a multiresolution analysis on x axis 
%                               then 'FALSE'. In case fix_x=='TRUE', the algorithm will
%                               perform an EQUAL-WIDTH binning along the x-axis.
%     fix_y(1,1),               In case we want to perform a multiresolution analysis on y axis 
%                               then 'FALSE'. In case fix_y=='TRUE', the algorithm will
%                               perform an EQUAL-WIDTH binning along the y-axis.
%     fix_z(1,1),               In case we want to perform a multiresolution analysis on z axis 
%                               then 'FALSE'. In case fix_z=='TRUE', the algorithm will
%                               perform an EQUAL-WIDTH binning along the z-axis.
%
%     NLEVEL(1,1)    indicates the number of levels we are going to explore
%     NERROR(1,1)    indicates the ERROR_INTENSITY / INTENSITY threshold
%
%
%___________________________________________________________________________________________
%
% optional input:
%     out(1,1)       Indicates the output, if == 0 only information related
%                    to center-bins will be stored in 'multislice_data'
%                    structure. If == 1 only information related to
%                    'patches' plotting will be stored in 'multislice_data'
%                    structure. If == 2 both conventions will be stored in
%                    the 'multislice_data' structure. (By default = 2).
%
%___________________________________________________________________________________________
%
%
% OUTPUT:
%
% multivolume_data = 
% 
%            vx: [1x24 double]          centers of bins (number of bins) along x
%            vy: [1x24 double]          centers of bins (number of bins) along y
%            vz: [1x24 double]          centers of bins (number of bins) along z
%     intensity: [24x24x24 double]      intensity collected in this bin (*) (vx,vy,vz) 
%         error: [24x24x24 double]      error collected in this bin (vx,vy,vz)
%
%            XX: [8x380 double]         (**)
%            YY: [8x380 double]
%            ZZ: [8x380 double]
%            SS: [1x380 double]
%            EE: [1x380 double]
%            X2: [8x97 double]
%            Y2: [8x97 double]
%            Z2: [8x97 double]
%            S2: [1x97 double]
%            E2: [1x97 double]
%            XR: [8x9194 double]
%            YR: [8x9194 double]
%            ZR: [8x9194 double]
%            SR: [1x9194 double]
%            ER: [1x9194 double]
%
%           L_T: [4x1 double]          Number of counts the algorithm stores at each level. (***) 
%
%
% (*)   An extra column and row has been added with NaN values to intensity and error variable 
%       in order to use the 'pcolor' plotting routine. 
%
% (**)   XX, YY, SS and EE will store information about bins which ERR/S is below 
%       the imposed threshold, where XX and YY store positions of bin corners. 
%       X2, Y2, S2 and E2 will store information about bins which ERR/S is NOT 
%       below the imposed threshold, and finally XR, YR, SR and ER will store 
%       information about bins with no counts, very useful in order to mask areas 
%       of the space where no detector exist.
%
% (***)  L_T = (variable that stores the number of counts collected in each level)
% 
%           (1,1) --> Counts collected in EXTRAPOLYGON LEVEL
%           (2,1) --> Counts collected in LEVEL 1
%           (3,1) --> Counts collected in LEVEL 2
%           (4,1) --> Counts collected in LEVEL 3
%___________________________________________________________________________________________
%
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%               E   X   A   M   P   L   E
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%
% if we take a known volume dataset
% 
% >> [x,y,z,v] = flow;
% 
% consider v a positive signal: 
% 
% >> int=v+abs(min(min(min(v))));
% 
% add some random noise:
% 
% >> err=sqrt(int);
% >> A=v-1.5*err./2;
% >> B=v+1.5*err./2;
% >> A=abs(A);
% >> B=abs(B);
% >> int = A + (B-A) .* rand(size(int));     % simulated data with noise
% 
% reshape input data:
% 
% >> int=reshape(int,[],1);
% >> err=reshape(err,[],1);
% >> x=reshape(x,[],1);
% >> y=reshape(y,[],1);
% >> z=reshape(z,[],1);
% 
% >> clear A B v
%
% 
% reconstruction performed by multires_3d
%
% >> multivolume_data=multires3d(x,y,z,int,err, 0.1,9.9,2,logical(0),  -3,3,1,logical(0), -3,3,1,logical(0), 3,0.35);
% 
% 
% An excellent way of visualizing the reconstructed volume dataset is 
% by using the 'sliceomatic' software, you can download it FREE from:
% http://gtts.ehu.es:8080/Ibon/ISIS/multires.htm
% 
% >> sliceomatic(multivolume_data.VX,multivolume_data.VY,multivolume_data.VZ,...
%           multivolume_data.INT,'U1','U2','U3','X-Axis','Y-Axis','Z-Axis',[1.7041 9.8268])
%
%
% the resulting image can be seen here: http://gtts.ehu.es:8080/Ibon/ISIS/multires_3d.PNG
%
%___________________________________________________________________________________________
% More Info: 
% I. Bustinduy, F.J. Bermejo, T.G. Perring, G. Bordel
% A multiresolution data visualization tool for applications in neutron time-of-flight spectroscopy
% Nuclear Inst. and Methods in Physics Research, A. 546 (2005)  498-508.
%
% Author information: Ibon Bustinduy [multiresolution@gmail.com] 
%                URL: http://gtts.ehu.es:8080/Ibon/ISIS/multires.htm  
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________




%------------------------------------------------------------------------------------------------------
%-------------------                CHECKING                 ------------------------------------------
%------------------------------------------------------------------------------------------------------


if ~exist('x','var')|isempty(x)
   disp('## Volume cannot be performed if x is not specified.');
   multivolume_data=[];
   return;
end
if ~exist('y','var')|isempty(y)
   disp('## Volume cannot be performed if y is not specified.');
   multivolume_data=[];
   return;
end

if ~exist('z','var')|isempty(z)
   disp('## Volume cannot be performed if y is not specified.');
   multivolume_data=[];
   return;
end

if ~exist('int','var')|isempty(int)
   disp('## Volume cannot be performed if int is not specified.');
   multivolume_data=[];
   return;
end
if ~exist('err','var')|isempty(err)
   disp('## Volume cannot be performed if err is not specified.');
   multivolume_data=[];
   return;
end

if ~exist('NLEVEL','var')|isempty(NLEVEL)|~isnumeric(NLEVEL)|(length(NLEVEL)~=1)
   disp('## Volume cannot be performed if NLEVEL is not specified.');
   multivolume_data=[];
   return;
   
if(NLEVEL~=round(NLEVEL)),
    disp('## NLEVEL value has to be an INTEGER value');
    multivolume_data=[];
    return;
end

if ~exist('RES_LEVEL','var')|isempty(RES_LEVEL)|~isnumeric(RES_LEVEL)|(length(RES_LEVEL)~=1)
   disp('## Volume cannot be performed if RES_LEVEL is not specified.');
   multivolume_data=[];
   return;
end   
end
if ~exist('NERROR','var')|isempty(NERROR)|~isnumeric(NERROR)|(length(NERROR)~=1)
   disp('## Volume cannot be performed if NERROR is not specified.');
   multivolume_data=[];
   return;
end


flag=(~exist('vx_min','var'))|isempty(vx_min)|~isnumeric(vx_min)|(length(vx_min)~=1);
flag=flag&(~exist('vx_max','var'))|isempty(vx_max)|~isnumeric(vx_max)|(length(vx_max)~=1);
flag=flag&(~exist('bin_vx','var'))|isempty(bin_vx)|~isnumeric(bin_vx)|(length(bin_vx)~=1);
flag=flag&(~exist('vy_min','var'))|isempty(vy_min)|~isnumeric(vy_min)|(length(vy_min)~=1);
flag=flag&(~exist('vy_max','var'))|isempty(vy_max)|~isnumeric(vy_max)|(length(vy_max)~=1);
flag=flag&(~exist('bin_vy','var'))|isempty(bin_vy)|~isnumeric(bin_vy)|(length(bin_vy)~=1);
flag=flag&(~exist('vz_min','var'))|isempty(bin_vy)|~isnumeric(bin_vy)|(length(bin_vy)~=1);
flag=flag&(~exist('vz_max','var'))|isempty(bin_vy)|~isnumeric(bin_vy)|(length(bin_vy)~=1);
flag=flag&(~exist('bin_vz','var'))|isempty(bin_vy)|~isnumeric(bin_vy)|(length(bin_vy)~=1);
flag=flag&(~exist('fix_x','var'))|isempty(fix_x)|~islogical(fix_x)|(length(fix_x)~=1);
flag=flag&(~exist('fix_y','var'))|isempty(fix_y)|~islogical(fix_y)|(length(fix_y)~=1);
flag=flag&(~exist('fix_z','var'))|isempty(fix_z)|~islogical(fix_z)|(length(fix_z)~=1);

if flag,
   disp('## One or more of the required parameters for VOLUME is not correct. VOLUME not performed.');
   multivolume_data=[];
   return;
end  


int=reshape(int,[],1);
err=reshape(err,[],1);
x=reshape(x,[],1);
y=reshape(y,[],1);
z=reshape(z,[],1);

if ( size(int,1)~=size(err,1) | size(int,1)~=size(x,1) | size(int,1)~=size(y,1)| size(int,1)~=size(z,1) )
   disp('## Input parameters must be EQUAL LENGTH. Volume not performed.');
   multivolume_data=[];
   return;  
   
else
    VXY=[x,y,z];  % matrix (ndet*ne,2) with projections
    clear x y z
end

%-------------------------------------------------------------------------
%--------- NO MULTIRESOLUTION --------------------------------------------
if(NLEVEL<1),
    disp('## NLEVEL value has been set to 1 [No Multiresolution]');
    multivolume_data=[];
    return;
end

if(fix_x & fix_y & fix_z),
    disp('## No multiresolution');
    NLEVEL=1;
    fix_x=logical(0);
    fix_y=logical(0);
    fix_z=logical(0);
end

RES_LEVEL=NLEVEL;

%------------------------------------------------------------------------------------------------------
%-------------------            END CHECKING                 ------------------------------------------
%------------------------------------------------------------------------------------------------------

disp('## USING multires3d version 2.0');
warning off MATLAB:divideByZero; %otherwise we will end up havig to many nonsense warning messages 

% ==============================================================================
% Establish orientation of cutting plane with respect to the viewing axes u1,u2,u3
% ==============================================================================

    if (vx_min>vx_max)|(vy_min>vy_max)|(vz_min>vz_max),
        disp('## Warning: Range x,y or z with lower_limit > upper_limit. Volume not performed.');
        multivolume_data=[];
        return   
    end



   % ==================================================================================================
   % Extract data contained within the boundaries of the VOLUME, to be binned onto the 3d grid
   % ==================================================================================================
   
   index = ~isnan(int);
   VXY = VXY(index,:);
   int = int(index,:);
   err = err(index,:);


   n=floor((vx_max+bin_vx-(vx_min-bin_vx/2))/bin_vx);	% number of vx bins
   m=floor((vy_max+bin_vy-(vy_min-bin_vy/2))/bin_vy);	% number of vy bins
   p=floor((vz_max+bin_vz-(vz_min-bin_vz/2))/bin_vz);	% number of vz bins
   
   index=((VXY(:,1)>=(vx_min-bin_vx/2))&(VXY(:,1)<(vx_min-bin_vx/2+n*bin_vx))&(VXY(:,2)>=(vy_min-bin_vy/2))&...
      (VXY(:,2)<(vy_min-bin_vy/2+m*bin_vy))&(VXY(:,3)>=(vz_min-bin_vz/2))&(VXY(:,3)<(vz_min-bin_vz/2+p*bin_vz)));
  % [) in both directions to agree with Phoenix 4.1
  
   VXY = VXY(index,:);
   int = int(index);
   err = err(index);
                                               
   pixels=[VXY(:,1)'; VXY(:,2)'; VXY(:,3)'; int'; err'];		% (5,Npixels)
   
   
   % === return if volume contains no data
   
   if isempty(VXY),
      disp('## Volume contains no data. Volume not performed.');
      multivolume_data=[];
      return;
   end
   
  clear VXY int err


   
   % ===============================================================================================
   % ===== where NLEVEL=1 means 1 level,id est: no multiresolution
if(fix_x),
		bin_vx_min=bin_vx;
        vx_min_min=vx_min;
        n_min=n;
else
      	bin_vx_min=bin_vx/(2.^(NLEVEL-1));
        vx_min_min=vx_min-bin_vx*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));  
        n_min=n.*(2.^(NLEVEL-1));
end

if(fix_y),
        bin_vy_min=bin_vy;
        vy_min_min=vy_min;
        m_min=m;    
else
        bin_vy_min=bin_vy/(2.^(NLEVEL-1));
        vy_min_min=vy_min-bin_vy*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));
        m_min=m.*(2.^(NLEVEL-1));    
end

if(fix_z),
        bin_vz_min=bin_vz;
        vz_min_min=vz_min;
        p_min=p;    
else
        bin_vz_min=bin_vz/(2.^(NLEVEL-1));
        vz_min_min=vz_min-bin_vz*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));
        p_min=p.*(2.^(NLEVEL-1));   
end
   
   

%    if ((n_min.*m_min.*p_min)>9000000),
%         disp('## Warning: You Are Requesting Too High Resolution. Volume Not Performed.');
%         multivolume_data=[];
%         return   
%    end
   
   % =============================================================================================== 
   % ===============================================================================================
   % alternative faster MATLAB binning routine 27-October-2003, based in the Radu's binning algorithm
   % distribute all points in bins, cummulate intensities and errors^2, then do the averaging
   % in "NLEVEL" resolution levels.
   % ===============================================================================================
   
   
   % ===============================================================================================
   %   initialization
   % ===============================================================================================
   % ===============================================================================================
   
      intensity=zeros(m_min,n_min,p_min);
      number=intensity;
      error_int=intensity;
      for VAR=1:size(pixels,2),
                                             
                        i=floor((pixels(2,VAR)-(vy_min_min-bin_vy_min/2))/bin_vy_min)+1;
                        j=floor((pixels(1,VAR)-(vx_min_min-bin_vx_min/2))/bin_vx_min)+1;
                        k=floor((pixels(3,VAR)-(vz_min_min-bin_vz_min/2))/bin_vz_min)+1;
                        
                        number(i,j,k)=number(i,j,k)+1;
                        intensity(i,j,k)=intensity(i,j,k)+pixels(4,VAR);
                        error_int(i,j,k)=error_int(i,j,k)+pixels(5,VAR)^2;
                        
      end
      
      initial_intensity=intensity;
      initial_error_int=error_int;
      initial_number=number;
      
      
      index=(number==0);	% identify bins with no pixels  
      intensity(index)=NaN;
      intensity(~index)=intensity(~index)./number(~index); 
      error_int(index)=NaN;
      error_int(~index)=sqrt(error_int(~index))./number(~index);
      pre_index=isnan(intensity);

      
      C_int2=intensity;
      C_err2=error_int;
      C_num2=number;
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      
      C_x2 = vx_min_min+(0:n_min-1)*bin_vx_min;
      C_y2 = vy_min_min+(0:m_min-1)*bin_vy_min;
      C_z2 = vz_min_min+(0:p_min-1)*bin_vz_min;

      C_binx2 = bin_vx_min;
      C_biny2 = bin_vy_min;
      C_binz2 = bin_vz_min;
      
      
      XX = zeros(8,1);
      YY = XX;
      ZZ = XX;
      SS = 0;
      EE = 0;
      
      cc_num=C_num2;      
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      
      INTENSITY=intensity;
      INTENSITY(:,:,:)=NaN;
      ERROR_INT=intensity;
      ERROR_INT(:,:,:)=NaN;
      NUMBER=INTENSITY;
      NUMBER(:,:,:)=0;
      
   % ===============================================================================================
   
   % -------    To mask the Non-existent areas -----------------------------------------------------
      
if(fix_x),
        bin_vx_res=bin_vx;
        vx_min_res=vx_min;
        n_res=n;   
else
        bin_vx_res=bin_vx/(2.^(RES_LEVEL-1));
        vx_min_res=vx_min-bin_vx*((2.^(RES_LEVEL-1))-1)/(2.^(RES_LEVEL));
        n_res=n.*(2.^(RES_LEVEL-1));
end

if(fix_y),
        bin_vy_res=bin_vy;    
        vy_min_res=vy_min;
        m_res=m;   
else
        bin_vy_res=bin_vy/(2.^(RES_LEVEL-1));    
        vy_min_res=vy_min-bin_vy*((2.^(RES_LEVEL-1))-1)/(2.^(RES_LEVEL));
        m_res=m.*(2.^(RES_LEVEL-1));    
end      

if(fix_z),
        bin_vz_res=bin_vz;    
        vz_min_res=vz_min;
        p_res=p;   
else
        bin_vz_res=bin_vz/(2.^(RES_LEVEL-1));   
        vz_min_res=vz_min-bin_vz*((2.^(RES_LEVEL-1))-1)/(2.^(RES_LEVEL));
        p_res=p.*(2.^(RES_LEVEL-1));  
end 


      intensity_res=zeros(m_res,n_res,p_res);
      number_res=intensity_res;
      error_int_res=intensity_res;
   
      for VAR=1:size(pixels,2),
                                             
                        i=floor((pixels(2,VAR)-(vy_min_res-bin_vy_res/2))/bin_vy_res)+1;
                        j=floor((pixels(1,VAR)-(vx_min_res-bin_vx_res/2))/bin_vx_res)+1;
                        k=floor((pixels(3,VAR)-(vz_min_res-bin_vz_res/2))/bin_vz_res)+1;
                        
                        number_res(i,j,k)=number_res(i,j,k)+1;
                                          
      end
   
      index_res=(number_res==0);	% identify bins with no pixels
      
      for i=1:m_min,
          for j=1:n_min,
              for k=1:p_min,
              NUMBERRES(i,j,k)=number_res(ceil(i/(2.^(NLEVEL-RES_LEVEL))),ceil(j/(2.^(NLEVEL-RES_LEVEL))),ceil(k/(2.^(NLEVEL-RES_LEVEL))));
              end
          end
      end
      
      INDEX_RES=(NUMBERRES==0);	% identify bins with no pixels
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-=-=-=-=-=-=-=-=-=-=-=-=-
C_x_res=vx_min_res+(0:n_res-1)*bin_vx_res;
C_y_res=vy_min_res+(0:m_res-1)*bin_vy_res;
C_z_res=vz_min_res+(0:p_res-1)*bin_vz_res;

C_int_res=intensity_res;
C_err_res=error_int_res;

[XC,YC,ZC]=meshgrid(C_x_res,C_y_res,C_z_res);
XC=XC(index_res);
YC=YC(index_res);
ZC=ZC(index_res);

C_int_res=reshape(C_int_res(index_res),1,[]);
C_err_res=reshape(C_err_res(index_res),1,[]);


%-------------------
XC_=reshape(XC,1,[]);
YC_=reshape(YC,1,[]);
ZC_=reshape(ZC,1,[]);

C_binx=bin_vx_res;
C_biny=bin_vy_res;
C_binz=bin_vz_res;
%-------------------


XR(1,:)=XC_ - C_binx/2;
XR(2,:)=XC_ + C_binx/2;
XR(3,:)=XR(2,:);
XR(4,:)=XR(1,:);
XR(5,:)=XC_ - C_binx/2;
XR(6,:)=XC_ + C_binx/2;
XR(7,:)=XR(2,:);
XR(8,:)=XR(1,:);


YR(1,:)=YC_ - C_biny/2;
YR(2,:)=YR(1,:);
YR(3,:)=YC_ + C_biny/2;
YR(4,:)=YR(3,:);
YR(5,:)=YC_ - C_biny/2;
YR(6,:)=YR(1,:);
YR(7,:)=YC_ + C_biny/2;
YR(8,:)=YR(3,:);


ZR(1,:)=ZC_ - C_binz/2;
ZR(2,:)=ZC_ - C_binz/2;
ZR(3,:)=ZC_ - C_binz/2;
ZR(4,:)=ZC_ - C_binz/2;
ZR(5,:)=ZC_ + C_binz/2;
ZR(6,:)=ZC_ + C_binz/2;
ZR(7,:)=ZC_ + C_binz/2;
ZR(8,:)=ZC_ + C_binz/2;



SR=C_int_res;
ER=C_err_res;

SR(:)=NaN;
ER(:)=NaN;

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   
 % ===============================================================================================  
   
   
    for LEVEL=NLEVEL:-1:1
        
      disp(['## LEVEL :: [',num2str(LEVEL),']']);

      %======================================================================
      %==============                       5                     ===========
      %==============   rename to be able to pass the information to the
      %                 next step cycle.
      
      C_int=C_int2;
      C_err=C_err2;
      C_num=C_num2;
      C_x=C_x2;
      C_y=C_y2;
      C_z=C_z2;
 
      %-------------------
      C_binx=C_binx2;
      C_biny=C_biny2;
      C_binz=C_binz2;

      %-------------------

       
      %==============                       1                   ===========
      %==============   We will extend the convolution to the smallest
      %                 binning size matrix
      for i=1:m_min,
          for j=1:n_min,
              for k=1:p_min, 
                  
                    intensity(i,j,k)=C_int(ceil(i/(2.^(NLEVEL-LEVEL))),ceil(j/(2.^(NLEVEL-LEVEL))),ceil(k/(2.^(NLEVEL-LEVEL))));
                    number(i,j,k)=C_num(ceil(i/(2.^(NLEVEL-LEVEL))),ceil(j/(2.^(NLEVEL-LEVEL))),ceil(k/(2.^(NLEVEL-LEVEL))));
                    error_int(i,j,k)=C_err(ceil(i/(2.^(NLEVEL-LEVEL))),ceil(j/(2.^(NLEVEL-LEVEL))),ceil(k/(2.^(NLEVEL-LEVEL))));
              end     
          end
      end
      
      LNUM(LEVEL)=sum(sum(sum(C_num)));
      intensity_aux=intensity;
      error_int_aux=error_int;
      number_aux=number;
      %======================================================================
      %==============                       2                     ===========
      %==============   we extract the information from the intensity
      %                 matrix to the 'final' INTENSITY matrix.      
      index_error=((error_int./intensity)<=NERROR);
      index_INTENSITY=isnan(INTENSITY);
      index=and(index_error,index_INTENSITY);
      
      INTENSITY(index)=intensity(index);
      ERROR_INT(index)=error_int(index);
      NUMBER(index)=number(index);
      
      intensity(index)=NaN;
      error_int(index)=NaN;
      number(index)=0;
      %======================================================================      
      %==============                       3                     ===========
      %==============  Delete the contributing points
      
      index_delete=((C_err./C_int)<=NERROR);
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-=-=-=-=-=-=-=-=-=-=-=-=-      


[XC,YC,ZC]=meshgrid(C_x,C_y,C_z);
XC=XC(index_delete);
YC=YC(index_delete);
ZC=ZC(index_delete);

intensity_=reshape(C_int(index_delete),1,[]);
error_int_=reshape(C_err(index_delete),1,[]);

%-------------------
XC_=reshape(XC,1,[]);
YC_=reshape(YC,1,[]);
ZC_=reshape(ZC,1,[]);

C_binx;
C_biny;
C_binz;
%-------------------


X(1,:)=XC_ - C_binx/2;
X(2,:)=XC_ + C_binx/2;
X(3,:)=X(2,:);
X(4,:)=X(1,:);
X(5,:)=XC_ - C_binx/2;
X(6,:)=XC_ + C_binx/2;
X(7,:)=X(2,:);
X(8,:)=X(1,:);

Y(1,:)=YC_ - C_biny/2;
Y(2,:)=Y(1,:);
Y(3,:)=YC_ + C_biny/2;
Y(4,:)=Y(3,:);
Y(5,:)=YC_ - C_biny/2;
Y(6,:)=Y(1,:);
Y(7,:)=YC_ + C_biny/2;
Y(8,:)=Y(3,:);

Z(1,:)=ZC_ - C_binz/2;
Z(2,:)=ZC_ - C_binz/2;
Z(3,:)=ZC_ - C_binz/2;
Z(4,:)=ZC_ - C_binz/2;
Z(5,:)=ZC_ + C_binz/2;
Z(6,:)=ZC_ + C_binz/2;
Z(7,:)=ZC_ + C_binz/2;
Z(8,:)=ZC_ + C_binz/2;

XX=[X,XX];
YY=[Y,YY];
ZZ=[Z,ZZ];

clear X
clear Y
clear Z

SS=[intensity_,SS];
EE=[error_int_,EE];

%-=-=-=-=-=-=-=-=-=-=-=-=-      

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!      
      C_int(index_delete)=NaN;
      C_err(index_delete)=NaN;
      C_num(index_delete)=0;
      %======================================================================
      %==============                       4                     ===========
      %==============  Create a convolution of the rest matrix
clear K
if(~fix_x & ~fix_y & ~fix_z),
    K=ones(2,2,2);
end     
if(~fix_x & ~fix_y & fix_z),
    K(:,:,1)=[1,1;1,1];
end
if(~fix_x & fix_y & ~fix_z),
    K(1,:,:)=[1,1;1,1];
end
if(~fix_x & fix_y & fix_z),
    K(:,:,1)=[1,1];
end
if(fix_x & ~fix_y & ~fix_z),
    K(:,1,:)=[1,1;1,1];
end
if(fix_x & ~fix_y & fix_z),
    K(:,:,1)=[1,1]';
end
if(fix_x & fix_y & ~fix_z),
    K(1,1,1:2)=1;
end

      
      W_index=isnan(C_int);      
      C_num2=convn(C_num,K,'valid');
      W2=(C_num2==0);
      C_int(W_index)=0;
      C_err(W_index)=0;      
      C_int_b=C_num.*C_int;
      C_err_b=(C_num.*C_err).^2;
      
      C_int2=convn(C_int_b,K,'valid');
      C_err2=sqrt(convn(C_err_b,K,'valid'));      
      
      C_int2(W2)=NaN;
      C_err2(W2)=NaN;
      
      I=C_int;
      ERR=C_err;
      N=C_num;
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!            
      C_int(W_index)=NaN;
      C_err(W_index)=NaN; 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!            
        %disp('after dividing by weight -->');
      C_int2(~W2)=C_int2(~W2)./C_num2(~W2);
      C_err2(~W2)=C_err2(~W2)./C_num2(~W2);
      
        %disp('after resizing           -->');      
      C_int2=C_int2(1:2:size(C_int2,1),1:2:size(C_int2,2),1:2:size(C_int2,3));
      C_err2=C_err2(1:2:size(C_err2,1),1:2:size(C_err2,2),1:2:size(C_err2,3));
      C_num2=C_num2(1:2:size(C_num2,1),1:2:size(C_num2,2),1:2:size(C_num2,3));

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!                  
        %disp('x and y positions           -->');      
      B=[1/2,1/2];  
      C_x2=conv2(C_x,B,'valid');
      C_y2=conv2(C_y,B,'valid');
      C_z2=conv2(C_z,B,'valid');      
      C_x2=C_x2(1:2:size(C_x2,2));
      C_y2=C_y2(1:2:size(C_y2,2));
      C_z2=C_z2(1:2:size(C_z2,2));
      
      C_binx2=2*C_binx;
      C_biny2=2*C_biny;
      C_binz2=2*C_binz;    
      
      B=[1/2,1/2];  
        if(fix_x),
            C_x2=C_x;
            C_binx2=C_binx;
        else
            C_x2=conv2(C_x,B,'valid');
            C_x2=C_x2(1:2:size(C_x2,2));
            C_binx2=2*C_binx;
        end        
        if(fix_y),
            C_y2=C_y;
            C_biny2=C_biny;
        else
            C_y2=conv2(C_y,B,'valid');
            C_y2=C_y2(1:2:size(C_y2,2));
            C_biny2=2*C_biny;
        end
        if(fix_z),
            C_z2=C_z;
            C_binz2=C_binz;
        else
            C_z2=conv2(C_z,B,'valid');      
            C_z2=C_z2(1:2:size(C_z2,2));
            C_binz2=2*C_binz;
        end
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!            
      
       
   end    
   
   % ===============================================================================================
   % ===============================================================================================

      disp('## Multiresolution Algorithm performed');

      in=isnan(INTENSITY);
      INTENSITY_AUX=INTENSITY;
      ERROR_INT_AUX=ERROR_INT;
      NUMBER_AUX=NUMBER;
      
      INTENSITY_AUX(in)=intensity_aux(in);
      ERROR_INT_AUX(in)=error_int_aux(in);
      NUMBER_AUX(in)=number_aux(in);
      
      L0=sum(sum(cc_num(in)));
      
      INTENSITY_AUX2=INTENSITY_AUX;
      ERROR_INT_AUX2=ERROR_INT_AUX;
      INTENSITY_AUX2(INDEX_RES)=NaN;
      ERROR_INT_AUX2(INDEX_RES)=NaN;
      % !!!!!!!!!!!!!!!!!!
      NUMBER_AUX2=NUMBER_AUX;
      NUMBER_AUX2(INDEX_RES)=NaN;
      % !!!!!!!!!!!!!!!!!!
      
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%-=-=-=-=-=-=-=-=-=-=-=-=-      

index_c=isnan(C_int);

[XC,YC,ZC]=meshgrid(C_x,C_y,C_z);
XC=XC(~index_c);
YC=YC(~index_c);
ZC=ZC(~index_c);

intensity_=reshape(C_int(~index_c),1,[]);
error_int_=reshape(C_err(~index_c),1,[]);

%-------------------
XC_=reshape(XC,1,[]);
YC_=reshape(YC,1,[]);
ZC_=reshape(ZC,1,[]);
%-------------------


X(1,:)=XC_ - C_binx/2;
X(2,:)=XC_ + C_binx/2;
X(3,:)=X(2,:);
X(4,:)=X(1,:);
X(5,:)=XC_ - C_binx/2;
X(6,:)=XC_ + C_binx/2;
X(7,:)=X(2,:);
X(8,:)=X(1,:);

Y(1,:)=YC_ - C_biny/2;
Y(2,:)=Y(1,:);
Y(3,:)=YC_ + C_biny/2;
Y(4,:)=Y(3,:);
Y(5,:)=YC_ - C_biny/2;
Y(6,:)=Y(1,:);
Y(7,:)=YC_ + C_biny/2;
Y(8,:)=Y(3,:);

Z(1,:)=ZC_ - C_binz/2;
Z(2,:)=ZC_ - C_binz/2;
Z(3,:)=ZC_ - C_binz/2;
Z(4,:)=ZC_ - C_binz/2;
Z(5,:)=ZC_ + C_binz/2;
Z(6,:)=ZC_ + C_binz/2;
Z(7,:)=ZC_ + C_binz/2;
Z(8,:)=ZC_ + C_binz/2;


X2=X;
Y2=Y;
Z2=Z;
clear X
clear Y
clear z
S2=intensity_;
E2=error_int_;



if(size(XX,2)>1),
    XX=XX(:,1:size(XX,2)-1);
    YY=YY(:,1:size(YY,2)-1);
    ZZ=ZZ(:,1:size(ZZ,2)-1);
    SS=SS(:,1:size(SS,2)-1);
    EE=EE(:,1:size(EE,2)-1);
end



%-=-=-=-=-=-=-=-=-=-=-=-=-   

   % ===============================================================================================
   %   We have to decide what to do with the zones which do not satisfy the
   %   choosen threshold, In this case we store in INTENSITY the points
   %   that satisfy it, whereas in INTENSITY_AUX we also will store those
   %   points, which belong to the lowest binning size choosen by the user. 
   %   They won't be so accurate,but at least those points will give us a better 
   %   overview.  
   % ===============================================================================================
   % =====================================================================
if(fix_x),
		bin_vx_min=bin_vx;
        vx_min_min=vx_min;
        n_min=n;
else
      	bin_vx_min=bin_vx/(2.^(NLEVEL-1));
        vx_min_min=vx_min-bin_vx*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));  
        n_min=n.*(2.^(NLEVEL-1));
end

if(fix_y),
        bin_vy_min=bin_vy;
        vy_min_min=vy_min;
        m_min=m;    
else
        bin_vy_min=bin_vy/(2.^(NLEVEL-1));
        vy_min_min=vy_min-bin_vy*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));
        m_min=m.*(2.^(NLEVEL-1));    
end
   
if(fix_z),
        bin_vz_min=bin_vz;
        vz_min_min=vz_min;
        p_min=p;    
else
        bin_vz_min=bin_vz/(2.^(NLEVEL-1));
        vz_min_min=vz_min-bin_vz*((2.^(NLEVEL-1))-1)/(2.^(NLEVEL));
        p_min=p.*(2.^(NLEVEL-1));
end

 vx=vx_min_min+(0:n_min-1)*bin_vx_min;
 vy=vy_min_min+(0:m_min-1)*bin_vy_min;
 vz=vz_min_min+(0:p_min-1)*bin_vz_min;
 
 
 
 
if (isempty(varargin)),
    out=2;
else
    out = varargin{1};
end

if (out==0 | out==2),
        multivolume_data.vx=vx;
        multivolume_data.vy=vy;
        multivolume_data.vz=vz;
        multivolume_data.intensity=INTENSITY_AUX2;
        multivolume_data.error=ERROR_INT_AUX2;
end

if (out==1 | out==2),
        multivolume_data.XX=XX;
        multivolume_data.YY=YY;
        multivolume_data.ZZ=ZZ;
        multivolume_data.SS=SS;
        multivolume_data.EE=EE;
        % the bins that don't satisfy the threshold-condition
        multivolume_data.X2=X2;
        multivolume_data.Y2=Y2;
        multivolume_data.Z2=Z2;
        multivolume_data.S2=S2;
        multivolume_data.E2=E2;
        % the masking patches
        multivolume_data.XR=XR;
        multivolume_data.YR=YR;
        multivolume_data.ZR=ZR;
        multivolume_data.SR=SR;
        multivolume_data.ER=ER;
end

if(NLEVEL>1),    
    for i=NLEVEL:-1:2,
    L_T(i+1,1)= LNUM(i)-LNUM(i-1);
    end
end    
L_T(2,1)=LNUM(1)-L0;
L_T(1,1)=L0;

multivolume_data.L_T=L_T;


%-----------------------------------------------------------------------
warning on MATLAB:divideByZero; %we have to restore the warning messages 
%-----------------------------------------------------------------------
