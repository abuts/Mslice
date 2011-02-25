function cut=cut_spe(data,x,vx_min,vx_max,bin_vx,vy_min,vy_max,vz_min,vz_max,i_min,i_max,out_type,out_file,tomfit)

% function cut=cut_spe(data,x,vx_min,vx_max,bin_vx,vy_min,vy_max,vz_min,vz_max,i_min,i_max,out_type,out_file,tomfit)
%       for single crystal data with PSD detectors and 
% function cut=cut_spe(data,x,vx_min,vx_max,bin_vx,vy_min,vy_max,i_min,i_max,out_type,out_file,tomfit)
%       for single crystal data with conventional detectors, or powder data
% 
% data.v (ndet,ne,3) projections along the viewing axes u1,u2,u3
%     .S (ndet,ne)intensities
%     .ERR (ndet,ne) corresponding errors
%     .axis_label 4-row string vector with labels of the u1,u2,u3 axes and intensity axis
%      save results in .cut format for the fitting programmes tobyfit, smhfit, bobfit
%                  compare .cut files with phoenix_psd cut/1d/t , still ~5e-4 difference in the x positions 
%                  maybe due to how many decimal places were used for pi and transform En-> wavevector
%      save results in xye_file x,y,error table format
% tomfit=true if cut is to be sent directly to Mfit
% returns cut structure 
%     pixels: [5071x6  double]
%    npixels: [   1x41 double]
%          x: [   1x41 double]
%          y: [   1x41 double]
%          e: [   1x41 double]
%    x_label: '[ -0.3, 0, Q_l ]  in 1.160 Å^{-1}'
%    y_label: 'Intensity(abs.units)'
%      title: {   1x2  cell  }
%     symbol: 'rs'
%       axis: [-0.6150 0.6300 0.1000 0.6000]
%      y_min: 0.1000
%      y_max: 0.6000
% Radu Coldea 22-Oct-2000

% === if .spe data file not read in the MSlice ControlWindow or if projections not calculated, return
if ~exist('data','var')|~isfield(data,'v'),
   disp('Load data and calculate projections on viewing axes, then do cut.')
   cut_d=[];
   return
end

% === check presence of required parameters in the calling syntax
if ~exist('x','var')|isempty(x)|~isnumeric(x)|(length(x)~=1)
   disp('Cut cannot be performed if axis is not specified.');
   cut_d=[];
   return;
end
flag=(~exist('vx_min','var'))|isempty(vx_min)|~isnumeric(vx_min)|(length(vx_min)~=1);
flag=flag&(~exist('vx_max','var'))|isempty(vx_max)|~isnumeric(vx_max)|(length(vx_max)~=1);
flag=flag&(~exist('bin_vx','var'))|isempty(bin_vx)|~isnumeric(bin_vx)|(length(bin_vx)~=1);
flag=flag&(~exist('vy_min','var'))|isempty(vy_min)|~isnumeric(vy_min)|(length(vy_min)~=1);
flag=flag&(~exist('vy_max','var'))|isempty(vy_max)|~isnumeric(vy_max)|(length(vy_max)~=1);
if flag,
   disp('One or more of the required range parameters for the cut is missing or has incorrect type.');
   disp('Cut not performed.');
   cut=[];
   return;
end   
   
% === rename variables to maintain compatbility between cut2d_df and cut3d_df (2 or 3 viewing axes)
if size(data.v,3)==2,	%=== 2d data set 
   if exist('out_type','var'),
      tomfit=out_type;
   end
   if exist('i_max','var'),
      out_file=i_max;
   end
   if exist('i_min','var'),
      out_type=i_min;
   end
   if exist('vz_max','var'),
      i_max=vz_max;
   end
   if exist('vz_min','var'),
      i_min=vz_min;
   end
end   
   
% === find out if cut is to be saved to a cut, smh or hkl format to an ASCII file  
to_cut_file=exist('out_file','var')&(~isempty(out_file))&(~isempty(findstr(lower(out_type),'cut')));
% TRUE if pixel information to be saved in .cut format
to_smh_file=exist('out_file','var')&(~isempty(out_file))&(~isempty(findstr(lower(out_type),'smh')))&...
   isfield(data,'hkl');
% TRUE if pixel information to be saved in .smh format
to_hkl_file=exist('out_file','var')&(~isempty(out_file))&(~isempty(findstr(lower(out_type),'hkl')))&...
   isfield(data,'hkl');
% TRUE if pixel information to be saved in .smh format
   
%==============================================================================
%=== CHOOSE BETWEEN SINGLE CRYSTAL AND PSD DETECTORS (3 viewing axes), 
%=== AND POWDER OR SINGLE CRYSTAL + CONVENTIONAL DETECTORS (2 viewing axes)
%==============================================================================
if size(data.v,3)==3,	%=== single crystal data and PSD detectors
   %=== check that cut limits are in the correct order
   if (vx_min>vx_max)|(vy_min>vy_max)|(vz_min>vz_max),
      disp('Warning: Range x,y or z with lower_limit > upper_limit.');
      disp('Cut not performed.');
   	cut=[];
   	return   
	end
	switch x,	% choose the other axes by permutation
   	case 1,	y=2; z=3;
      case 2,	y=3; z=1;
      case 3,  y=1; z=2;
      otherwise, disp(['Cannot perform cut along axis number ' num2str(x)]); cut=[];return
   end      
   grid=[vx_min vx_max bin_vx vy_min vy_max vz_min vz_max];   
   
   % === if y-axis not intensity, then use standard deviation of the mean per bin as error 
   if ~isfield(data,'ERR')|isempty(data.ERR),
      try
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy,vz]=cut3d_df(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),...
            data.S,data.S,grid);
      catch
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy,vz] =cut3d_m(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),...
            data.S,data.S,grid);
      end
      try
         [cut.y,cut.e]=avpix_df(data.S,cut.perm,cut.npixels);
      catch   
         [cut.y,cut.e] =avpix_m(data.S,cut.perm,cut.npixels);
      end
   else  % normal binning of intensity values
      % to increase speed xye cut only use basic algorithm (do not calculate pixel permutation matrix)
      if ~isfield(data,'altx')&~to_cut_file&~to_smh_file&~to_hkl_file, 
         %disp('Using xye cut routine.');
         try
         	[cut.x,cut.y,cut.e,vy,vz]=...
               cut3dxye_df(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),data.S,data.ERR,grid);
         catch
         	[cut.x,cut.y,cut.e,vy,vz]=...
               cut3dxye_m(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),data.S,data.ERR,grid);            
         end   
         cut.perm=[];
         cut.npixels=[];
		else  % need full pixel information to save data in special format(cut,smh,hkl) or plot on alternative x-axis       
         try
            [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy,vz]=...
               cut3d_df(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),data.S,data.ERR,grid);
      	catch
            [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy,vz] =...
               cut3d_m(data.v(:,:,x),data.v(:,:,y),data.v(:,:,z),data.S,data.ERR,grid);
         end  
      end
   end      
else	%=== single crystal and conventional detectors, or powder data
   if (vx_min>vx_max)|(vy_min>vy_max),
      disp('Warning: Range x or y with lower_limit > upper_limit.');
      disp('Cut not performed.');
   	cut_d=[];
   	return   
	end
	switch x,
   	case 1,	y=2;
      case 2,	y=1;
      otherwise, disp(['Cannot perform cut along axis number ' num2str(x)]); cut=[]; return
   end      
   grid=[vx_min vx_max bin_vx vy_min vy_max];   
   % === if y-axis not intensity, then use standard deviation of the mean per bin as error 
   if ~isfield(data,'ERR')|isempty(data.ERR),
      try 
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy]=cut2d_df(data.v(:,:,x),data.v(:,:,y),data.S,data.S,grid);     
      catch
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy] =cut2d_m(data.v(:,:,x),data.v(:,:,y),data.S,data.S,grid);     
      end   
      try 
         [cut.y,cut.e]=avpix_df(data.S,cut.perm,cut.npixels);
      catch
         [cut.y,cut.e]=avpix_m(data.S,cut.perm,cut.npixels);
      end
   else
      try
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy]=cut2d_df(data.v(:,:,x),data.v(:,:,y),data.S,data.ERR,grid);            
      catch
         [cut.x,cut.y,cut.e,cut.perm,cut.npixels,vy] =cut2d_m(data.v(:,:,x),data.v(:,:,y),data.S,data.ERR,grid);            
      end   
   end      
end

% === if cut contains no data, then return   
if isempty(cut.x),
   disp('Warning: Cut contains no data.');
   cut=[];
   return
end

% === send cut to mfit or plot on a plot_cut window
if exist('tomfit','var')&~isempty(tomfit)&islogical(tomfit)&tomfit,   
	% === disp(['Sending cut data directly to mfit']);
   % === do not plot cut in plot_cut window, but send directly to Mfit    
   cut2mfit(cut);
else
   
end

% === save cut to a file, if required
if ~isempty(out_file)&isempty(findstr(out_type,'none')),
	if to_cut_file&(~isempty(findstr(lower(out_type),'mfit'))),
      cut.efixed=data.efixed;	% numeric
   	cut.emode=data.emode;		% numeric
      cut.MspDir=data.MspDir;	% string
      cut.MspFile=data.MspFile;	% string
      cut.sample=data.sample;	% numeric
      if data.sample==1,	% single crystal, so save lattice parameters and crystal orientation as well
      	cut.abc=data.abc;	% [as bs cs; aa bb cc]
         cut.uv=data.uv;	% [ux uy uz; vx vy vz]
         cut.psi_samp=data.psi_samp;	% numeric
      end
   end   
	save_cut(cut,out_file,out_type);   
end
