function ms_calc_proj

% function ms_calc_proj;

% === if no Control Window opened or data not loaded, return 
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   disp('Control Window not present. Return');
   return;
end
data=get(fig,'UserData');
if isempty(data),
   disp('No data set in the Control Window. Load data first.');
   return;
end
data.v=[]; % reset previous projections
set(fig,'UserData',data);

% === highlight red button indicating 'busy'
h_status=findobj(fig,'Tag','ms_status');
if ~isempty(h_status)&&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
   drawnow;
end

% === establish which variable names are to be read depending on sample type, analysis mode and detector type
samp=get(findobj(fig,'Tag','ms_sample'),'Value');
if samp==2,     % sample is powder 
   vars={'u1','u1label','u2','u2label','efixed','emode','IntensityLabel','TitleLabel'};
elseif samp==1, % sample is single crystal 
   vars={'as','bs','cs','aa','bb','cc','ux','uy','uz','vx','vy','vz','psi_samp','efixed','emode','IntensityLabel','TitleLabel'};
   analmode=get(findobj('Tag','ms_analysis_mode'),'Value');
   if analmode==2,	% analysed as powder
      vars=[vars,{'u1','u1label','u2','u2label'}];	   	  
      psd=(1<0);	% FALSE
   elseif analmode==1	% analysed as single crystal
      vars=[vars,{'u1label','u2label','u11','u12','u13','u14','u21','u22','u23','u24'}];
		dettype=findobj('Tag','ms_det_type');
		% === read flag for detector type and identify if PSD
		if isempty(dettype),
   		   disp('Detector type not defined');
   		   return;
		end
		psd=(get(dettype,'value')==1);
		if psd,	% for PSD detectors add one more viewing vector 
  			vars=[vars,{'u3label','u31','u32','u33','u34'}];
        end   
   elseif analmode==3 % powder remap
       % tempoerary, treat as powder;
      vars=[vars,{'u1','u1label','u2','u2label','polar_min','polar_max','polar_delta'}];	   	  
      psd=false;	% FALSE      
   else
       error('MSLICE:ms_calc_proj','unknown analysis mode %d',analmode);
   end
end

% ===== read relevant parameters from ControlWindow

for i=1:size(vars,2)
    name=vars{i};
    switch vars{i}
        case{'emode'}
            emode=ms_getvalue(name,'raw');
        case{'efixed'}
            efixed=ms_getvalue(name);
        case{'IntensityLabel'}
            IntensityLabel=ms_getvalue(name,'noeval');
        case{'TitleLabel'}
            TitleLabel=ms_getvalue(name,'noeval');
        case{'u1label'}
            u1label=ms_getvalue(name,'noeval');
        case{'u2label'}
            u2label=ms_getvalue(name,'noeval');
        case{'u3label'}
            u3label=ms_getvalue(name,'noeval');
        case{'u1'}
            u1=ms_getvalue(name,'raw');
        case{'u2'}
            u2=ms_getvalue(name,'raw');
        case{'psi_samp'}
            psi_samp=ms_getvalue(name);
        case{'ux'}
            ux=ms_getvalue(name);
        case{'uy'}
            uy=ms_getvalue(name);
        case{'uz'}
            uz=ms_getvalue(name);
        case{'vx'}
            vx=ms_getvalue(name);
        case{'vy'}
            vy=ms_getvalue(name);
        case{'vz'}
            vz=ms_getvalue(name);
        case{'as'}
            as=ms_getvalue(name);
        case{'bs'}
            bs=ms_getvalue(name);
        case{'cs'}
            cs=ms_getvalue(name);
        case{'aa'}
            aa=ms_getvalue(name);
        case{'bb'}
            bb=ms_getvalue(name);
        case{'cc'}
            cc=ms_getvalue(name);
        case{'u11'}
            u11=ms_getvalue(name);
        case{'u12'}
            u12=ms_getvalue(name);
        case{'u13'}
            u13=ms_getvalue(name);
        case{'u14'}
            u14=ms_getvalue(name);
        case{'u21'}
            u21=ms_getvalue(name);
        case{'u22'}
            u22=ms_getvalue(name);
        case{'u23'}
            u23=ms_getvalue(name);
        case{'u24'}
            u24=ms_getvalue(name);
        case{'u31'}
            u31=ms_getvalue(name);
        case{'u32'}
            u32=ms_getvalue(name);
        case{'u33'}
            u33=ms_getvalue(name);
        case{'u34'}
            u34=ms_getvalue(name);
        otherwise
            % this has to be one of psi ranges -- psi_min, psi_max, delta_psi;
            % And it has to be transformed from degrees to radians. 
            range.(vars{i})=ms_getvalue(name)*pi/180;
    end
end

% if no spe data but only detector layout read then make energy bin range
if ~isfield(data,'S'),
   data.en=linspace(0,efixed,25);
end

data.emode=emode;
data.efixed=efixed;
if (samp==1) && (analmode<3),	% single crystal sample 
	% === Determine reciprocal basis
	[ar,br,cr]=basis_r(as,bs,cs,aa*pi/180,bb*pi/180,cc*pi/180);

	% === Determine crystal orientation 
   % old convention when u and v are expressed in the reference frame of the direct lattice
   %	u=[ux uy uz];
   %	v=[vx vy vz];
   % new convetion where u and v are vectors expresses in terms of the reciprocal lattice vectors
   % u and v need not be orthogonal
   u=ux*ar+uy*br+uz*cr;	
   v=vx*ar+vy*br+vz*cr;
   % now u and v are (1,3) vectors expressed in the same reference frame as ar, br and cr
	u=u/norm(u);
	v=v-dot(v,u)*u;
	v=v/norm(v);	% (u,v) define the principal scattering plane of the spectrometer (Horiz HET&IRIS, Vert MARI)
    w=cross(u,v);	% w is vertically up on the (u,v) plane 
   % now (u,v,w) is a right-handed cooordinate system with all vectors orthogonal to each other and of unit length
   
	% === Determine components of the reciprical basis in terms of the (u,v,w) frame
	ar=[dot(ar,u) dot(ar,v) dot(ar,w)];
	br=[dot(br,u) dot(br,v) dot(br,w)];
	cr=[dot(cr,u) dot(cr,v) dot(cr,w)];

	% === Update crystal orientation in the data set 
   data.ar=ar;
   data.br=br;
   data.cr=cr;
   data.psi_samp=psi_samp*pi/180;
   data.uv=[ux uy uz; vx vy vz]; % crystal orientation, 2 axes in the principal scattering plane
end   

if (samp==1)&&(analmode==1), % single crystal data analysed in single crystal mode
    if psd, % PSD detectors
		data.axis_label=str2mat(u1label,u2label,u3label);
        data.axis_unitlabel=str2mat('','','',IntensityLabel);
   	    data.title_label=TitleLabel;
		data.u=[u11 u12 u13 u14; u21 u22 u23 u24; u31 u32 u33 u34];      
        % calculate projections for crystall
        data=calcproj(data);
        ms_updatelabel(3);   
      % === clear stored slice data 
      ms_slice('clear');
   else % non-PDS detectors
	data.axis_label=str2mat(u1label,u2label);
   	data.axis_unitlabel=str2mat('','',IntensityLabel);
   	data.title_label=TitleLabel;
   	data.u=[u11 u12 u13 u14; u21 u22 u23 u24];  
    % calculate projections for reduced crystall
   	data=calcprojb(data);
    end
elseif(samp==1)&&(analmode==3) % powder remap
   data.axis_label=str2mat(u1label,u2label);
   data.axis_unitlabel=str2mat('','',IntensityLabel);
   data.title_label=TitleLabel;
   data.u=[u1;u2];
   data.range = range;
   data=rebin_cryst_img_to_rings(data);
   data=calcprojpowder(data);      
else	% sample is powder or analysed as powder
   data.axis_label=str2mat(u1label,u2label);
   data.axis_unitlabel=str2mat('','',IntensityLabel);
   data.title_label=TitleLabel;
   data.u=[u1;u2];
   % projections for powder
   data=calcprojpowder(data);  
end
% no label should change when projections are calculated;
%ms_updatelabel(1);
%ms_updatelabel(2);
if ~isempty(data),
   set(fig,'UserData',data);
end               

% === highlight green button indicating 'not busy' 
if ~isempty(h_status)&&ishandle(h_status),
   green=[0 1 0];
   set(h_status,'BackgroundColor',green);
   drawnow;
end
