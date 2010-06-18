function mslice(MspFile)

% function mslice;
% draws the Control Window for the MSlice programme
% Radu Coldea 02-October-1999

% *** ISIS changes
%   T.G.Perring, Ron Fowler ~2007: Size of mslice control window changed, and allow resize
%
%   Dean Whittaker, August 2008
%      The following is a list of functions to compile that may only be called
%      as strings. These were found using test2 = []; test = dir, for i = 1:length(test),
%      test2 = [test2, test1(i).name(1:(end-2))] end and then copying and
%      pasting the text contents of test2. 
%
%      hopefully this list is unnesessary as we define these functions in
%      -a options of the compiler
%
%#function store_data a2spe add2mask add_psd_ns add_slice add_spe add_spe_example avpix_m basis_d basis_hkl basis_r basis_u bin2d_df buildspe calcproj calcprojb calcprojpowder combil cs2cucl4 cut2d_m cut2mfit cut3d_m cut3dxye_m cut_spe det2spec det_view detectorview disp_spe dv_load_file dv_mask dv_plot_msk dv_plot_sum dv_read_int dv_save_msk executemsp firstword firstzone fitcut genie getb int_det interp_cut isinpath load_fit load_hkl load_ipgascm load_msk load_par load_phx load_spe load_sum load_xye mask maskmore mc2spe mctr2spe mff_cu3d miller ms_analysis_mode ms_ax_linear_log ms_bkg ms_calc_proj ms_cut ms_cut_axes ms_disp ms_disp_axes ms_disp_or_slice ms_errorbar ms_filter ms_fitcut ms_fitcut_load_data ms_fitcut_save_data ms_fitcut_update ms_fitcut_updatepar ms_getfile ms_getstring ms_help ms_iris ms_iris_spe ms_list_pars ms_load_data ms_load_msp ms_pick_output ms_plot_traj ms_powder_menu ms_printc ms_putfile ms_sample ms_save_data ms_save_msp ms_simulate ms_simulate_iris ms_slice ms_slice_axes ms_sqw ms_sqw_iris ms_toggle ms_updatelabel ms_updatelabelu mslicepath mult_cut no_overlap order_m par2phx phx2par pick_wv pickvar pickvar_hkl pickvarb planeperp plot_cut plot_de plot_det plot_slice plot_spe plot_sum plot_traj pos2spec put_in_matrix putb q2rlu read_Q read_spe rebin_cut rlu2q rm_mask save_cut save_msk save_phx save_spe sim_cs2cucl4 simulate slice_spe small smooth_curve smooth_slice smooth_spe sort_msk spe2modQ spe2sqe spe2sqeb spec2matrix spurion sqe2proj sqe2samp sqw stripath sub_cut sum2det surf_slice swapEmodQ towindow units updatemsp uv_2dtr waverage wdisp_cs2cucl4 avoidtex color_slider fromwindow keep load_cut make_cur 
%
%
% T.G.Perring, 3 April 2009: No longer put mslice at top of the mslice path
%
%  $Revision: 57 $   ($Date: 2010-01-08 17:22:35 +0000 (Fri, 08 Jan 2010) $)
%
global MSliceDir;
[temp,MSliceDir]=stripath(which('mslice.m'));

if isdeployed
%     % if in deployed mode, one needs to move upwards by a few levels in order
%     % to get to the correct path. *** This is an unfortunately "hacky" way to do it
%     % Dean Whittaker, August 2008
%     cd(MSliceDir)
%     cd ..
%     cd ..
% *** Verify
%   January 2010, AB: Modified to do that this is no longer valid but need to verify
%
    MSliceDir = [pwd filesep];
    disp('Current Mslice Dircetory is..'), disp(MSliceDir)
end
    
% === find MSlice directory and place at top of MATLAB search path if not in path already
% path(MSliceDir,path); %   T.G.Perring, 3 April 2009: Removed

% === start by default in Crystal PSD mode if no MspFile given
if ~exist('MspFile','var')||isempty(MspFile)||~ischar(MspFile),
   MspFile=[MSliceDir 'crystal_psd.msp'];
else
   if isempty(findstr(MspFile,'.msp')),
      MspFile=[MspFile '.msp'];
   end
end

% === define colours in RGB format
colordef white;
white=[1 1 1];
black=[0 0 0];
grey=[0.752941 0.752941 0.752941];

% === close previous MSlice Control Windows
h=findobj('Tag','ms_ControlWindow');
if ~isempty(h),
   disp(['Closing previous MSlice Control Window'])
   delete(h);
end

% === display MSlice version ===
helpfile=[MSliceDir 'help.txt'];
try
    fpos=ffind(helpfile,'%%% version');
    err_ll='';
catch
    err_ll=lasterr();
    fpos=-1;
end
if fpos<1,
   disp(['Cannot determine MSlice version date. ' err_ll]);
   lastupdate='(date of last update not available)';   
else
	fid=fopen(helpfile,'rt');
   fseek(fid,fpos+length('%%% version'),'bof');
   lastupdate=fgetl(fid);
   fclose(fid);
end
disp(['Starting MSlice version' lastupdate ]);
disp(['More information in the About MSlice... box.']);   

% === draw Control Window and establish positions and dimensions of menu items
% Change to 'Resize' 'on', so user can adjust size of mslice control window

if ispc
    fig=figure('MenuBar','none','Resize','on',...
        'Position',[5    33   550   770],...
        'Name','MSlice : Control Window',...
        'NumberTitle','off',...
        'Tag','ms_ControlWindow');
else
    fig=figure('MenuBar','none','Resize','on',...
        'Position',[5    33   696   820],...
        'Name','MSlice : Control Window',...
        'NumberTitle','off',...
        'Tag','ms_ControlWindow');
end
    
h=uicontrol('Parent',fig,'Style','text','String','Spectrometer',...
   'BackgroundColor',white);
pos=get(h,'Extent');
lineheight=pos(4);
interlines=ceil(lineheight/4);
nlines= 33.2+0.15; 
width=8*pos(3);
bottomx=5;
bottomy=33;

set(fig,'Position',[bottomx bottomy width lineheight*nlines+interlines*(nlines-1)]);
pos=[0 lineheight*(nlines-1)+interlines*(nlines-1) pos(3) pos(4)];
set(h,'Position',pos); 
oneline=[0 lineheight+0*interlines 0 0];
pos=pos-[0 interlines 0 0];

% ============== MSliceDir, MspDir and MspFile 
h=uicontrol('Parent',fig,'Style','text','String',MSliceDir,...
   'Position',pos,'Tag','ms_MSliceDir','Visible','off');
h=uicontrol('Parent',fig,'Style','text','String','',...
   'Position',pos,'Tag','ms_MspDir','Visible','off');
h=uicontrol('Parent',fig,'Style','text','String','',...
   'Position',pos,'Tag','ms_MspFile','Visible','off');
green=[0 1 0];
red  =[1 0 0];
h=uicontrol('Parent',fig,'Style','frame',...
   'Position',pos+[7.5*pos(3) 0 -pos(3)/2 interlines],'Tag','ms_status',...
   'Visible','on','BackgroundColor',green,'UserData',[green; red]);
%========= efixed and emode =========
pos=pos-oneline;
h=uicontrol('Parent',fig,'Style','text','String','efixed (meV)',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_efixed',...
   'Position',pos+[pos(3) 0 0 interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','popupmenu','String',{'direct','indirect'},...
   'Tag','ms_emode','BackgroundColor',white,...
	'Position',pos+[3*pos(3) interlines/2 0 interlines],'Value',2);
h=uicontrol('Parent',fig,'Style','text','String','geometry',...
   'Position',pos+[4*pos(3) 0 0 0]);   

%========= DataFile ==================
pos=pos-oneline;
h=uicontrol('Parent',fig,'Style','text','String',[pwd '\'],...
   'Position',pos,'Visible','off','Tag','ms_DataDir');
h=uicontrol('Parent',fig,'Style','text','String','DataFile(.spe)',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_DataFile',...
   'Position',pos+[pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white);
  
h=uicontrol('Parent',fig,'Style','pushbutton','String','Browse',...
   'Callback',...
   'ms_getfile(findobj(''Tag'',''ms_DataDir''),findobj(''Tag'',''ms_DataFile''),spe_ext(1),''Choose Data File'');',...
   'Position',pos+[4*pos(3) interlines/2 0 0]);   

%========= DetFile, Save Data As... and Load Data pushbuttons ==================
pos=pos-oneline;
h=uicontrol('Parent',fig,'Style','text','String','DetFile(.phx)',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','text','String',[pwd '\'],...
   'Position',pos,'Visible','off','Tag','ms_PhxDir');
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_PhxFile',...
   'Position',pos+[pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
	'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','pushbutton','String','Browse',...
   'Callback',...
   'ms_getfile(findobj(''Tag'',''ms_PhxDir''),findobj(''Tag'',''ms_PhxFile''),''*.phx'',''Choose Detector File'');',...
   'Position',pos+[4*pos(3) interlines/2 0 0]);   
h=uicontrol('Parent',fig,'Style','pushbutton','String','Save Data As ...',...
   'Callback','ms_save_data;',...
   'Position',pos+[5.5*pos(3) interlines 0.5*pos(3) 0]);   
h=uicontrol('Parent',fig,'Style','pushbutton','String','Load Data',...
   'Callback','ms_load_data;',...
   'Position',pos+[7*pos(3) interlines 0 0]);   

%========= Intensity and title label =================
pos=pos-oneline;
h=uicontrol('Parent',fig,'Style','text','String','Intensity label',...
   'Position',pos);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_IntensityLabel',...
   'Position',pos+[pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
   'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','text','String','Title label*',...
   'Position',pos+[4*pos(3) 0 0 0]);
h=uicontrol('Parent',fig,'Style','edit','Enable','on','Tag','ms_TitleLabel',...
   'Position',pos+[5*pos(3) 0 2*pos(3) interlines],...
   'HorizontalAlignment','left',...
   'BackgroundColor',white);

%========= Sample :Single Crystal/Powder ==================

pos=pos-1.5*oneline;
h=uicontrol('Parent',fig,'Style','text','String','Sample',...
   'Position',pos,'BackgroundColor',white);
h=uicontrol('Parent',fig,'Style','popupmenu','String',{'single crystal','powder'},...
   'Tag','ms_sample','BackgroundColor',white,...
   'Position',pos+[pos(3) 0 0.5*pos(3) interlines],...
   'Callback','ms_sample','Value',1);

%========== Top Figure Menu ===========================
h=uimenu(fig,'Label','Exit');
h=uimenu(h,'Label','Exit','Callback','ms_close_windows;');

% === construct Parameters menu
h=uimenu(fig,'Label','Parameters');
h1=uimenu(h,'Label','Load Parameters','Callback','ms_load_msp;');
h1=uimenu(h,'Label','Save Parameters','Callback','ms_save_msp;');
h1=uimenu(h,'Label','List Parameters','Callback','ms_list_pars;');
h1=uimenu(h,'Label','Save List to File','Callback','ms_list_pars(''file'');');

% === construct Background menu
h=uimenu(fig,'Label','Background');
h1=uimenu(h,'Label','Subtract stored bkg(E) from data','Callback','ms_bkg(''subtract'');');
h2=uimenu(h,'Label','Add stored bkg(E) back to data','Callback','ms_bkg(''add'');');
h3=uimenu(h,'Label','Display history of stored bkg(E)','Callback','ms_bkg(''display'');');
h5=uimenu(h,'Label','Delete currently stored bkg(E)','Callback','ms_bkg(''delete'');');


% === the Workspaces Menu
h=uimenu(fig,'Label','Data workspaces');
h1=uimenu(h,'Label','W1','Callback','store_data(''W1'');');
h1=uimenu(h,'Label','W2','Callback','store_data(''W2'');');
h1=uimenu(h,'Label','W3','Callback','store_data(''W3'');');
h1=uimenu(h,'Label','W4','Callback','store_data(''W4'');');
h1=uimenu(h,'Label','W5','Callback','store_data(''W5'');');
h1=uimenu(h,'Label','W6','Callback','store_data(''W6'');');
h1=uimenu(h,'Label','RESET','Callback','store_data(''RESET'');');


%==== construct 'Help' menu
h=uimenu(fig,'Label','Help','Tag','ms_help');
% === for the moment do not enable help option on the VMS, problems reading the help file
a=version;
if (a(1)<=5)&isvms,
   set(h,'Visible','off');
end
% === the ControlWindow top menu
h1=uimenu(h,'Label','ControlWindow Top menu');
h2=uimenu(h1,'Label','Exit',...
   'Callback','ms_help(''Exit'');');
h2=uimenu(h1,'Label','Parameters',...
   'Callback','ms_help(''Parameters'');');
h2=uimenu(h1,'Label','Background',...
   'Callback','ms_help(''Background'');');
h2=uimenu(h1,'Label','Help',...
   'Callback','ms_help(''Help'');');
% === the Spectrometer menu
h1=uimenu(h,'Label','Spectrometer');
h2=uimenu(h1,'Label','efixed',...
   'Callback','ms_help(''efixed'');');
h2=uimenu(h1,'Label','geometry',...
   'Callback','ms_help(''geometry'');');
h2=uimenu(h1,'Label','DataFile(.spe)',...
   'Callback','ms_help(''DataFile'');');
h2=uimenu(h1,'Label','DataFile(.spe from IRIS)',...
   'Callback','ms_help(''DataFile(.spe from IRIS)'');');
h2=uimenu(h1,'Label','SaveDataAs...',...
   'Callback','ms_help(''SaveDataAs...'');');
h2=uimenu(h1,'Label','LoadData',...
   'Callback','ms_help(''LoadData'');');
h2=uimenu(h1,'Label','DetFile(.phx)',...
   'Callback','ms_help(''DetFile'');');
h2=uimenu(h1,'Label','IntensityLabel',...
   'Callback','ms_help(''IntensityLabel'');');
h2=uimenu(h1,'Label','TitleLabel',...
   'Callback','ms_help(''TitleLabel'');');

% === the Sample menu
h1=uimenu(h,'Label','Sample');
h2=uimenu(h1,'Label','general',...
   'Callback','ms_help(''Sample'');');
h2=uimenu(h1,'Label','Single Crystal');

% === the Analysis Mode/Detectors/Viewing axes for single crystal mode 
h3=uimenu(h2,'Label','Unit cell and orientation',...
   'Callback','ms_help(''Single crystal: unit cell and orientation'');');
h3=uimenu(h2,'Label','Analysis Mode',...
   'Callback','ms_help(''Analysis Mode'');');
h3=uimenu(h2,'Label','Detectors',...
   'Callback','ms_help(''Detectors'');');
h3=uimenu(h2,'Label','Viewing Axes',...
   'Callback','ms_help(''Viewing Axes: Single Crystal'');');

% === the Viewing axes for powder mode
h2=uimenu(h1,'Label','Powder');
h3=uimenu(h2,'Label','general',...
   'Callback','ms_help(''Powder'');');
h3=uimenu(h2,'Label','Viewing Axes',...
   'Callback','ms_help(''Viewing Axes: Powder'');');

% === the Calculate Projections button 
h1=uimenu(h,'Label','Calculate Projections', ...
   'Callback','ms_help(''Calculate Projections'');');

% === the Display menu
h1=uimenu(h,'Label','Display');
h2=uimenu(h1,'Label','general',...
	'Callback','ms_help(''Display'');');
h2=uimenu(h1,'Label','Intensity range',...
   'Callback','ms_help(''Display: Intensity range:'');');
h2=uimenu(h1,'Label','Colour map',...
   'Callback','ms_help(''Display: Colour map'');');
h2=uimenu(h1,'Label','Smoothing',...
   'Callback','ms_help(''Display: Smoothing level'');');
h2=uimenu(h1,'Label','Shading',...
   'Callback','ms_help(''Display: Shading'');');
h2=uimenu(h1,'Label','Display',...
   'Callback','ms_help(''Display: Display'');');	

% === the Slice menu
h1=uimenu(h,'Label','Slice');
h2=uimenu(h1,'Label','general',...
	'Callback','ms_help(''Slice plane'');');
h2=uimenu(h1,'Label','Intensity range',...
   'Callback','ms_help(''Slice plane: Intensity range:'');');
h2=uimenu(h1,'Label','Colour map',...
   'Callback','ms_help(''Slice plane: Colour map'');');
h2=uimenu(h1,'Label','Smoothing',...
   'Callback','ms_help(''Slice plane: Smoothing level'');');
h2=uimenu(h1,'Label','Shading',...
   'Callback','ms_help(''Slice plane: Shading'');');
h2=uimenu(h1,'Label','Plot Slice',...
   'Callback','ms_help(''Slice plane: Plot Slice'');');	
h2=uimenu(h1,'Label','Surf Slice', ...
   'Callback','ms_help(''Slice plane: Surf Slice'');');



% === the Cut menu
h1=uimenu(h,'Label','Cut');
h2=uimenu(h1,'Label','general',...
   'Callback','ms_help(''Cut'');');
h2=uimenu(h1,'Label','Intensity range',...
   'Callback','ms_help(''Cut: Intensity range'');');
h2=uimenu(h1,'Label','Symbol', ...
   'Callback','ms_help(''Cut: Symbol'');');
h2=uimenu(h1,'Label','OutputFile', ...
   'Callback','ms_help(''Cut: OutputFile'');');
h2=uimenu(h1,'Label','To Mfit', ...
   'Callback','ms_help(''Cut: To Mfit'');');
h2=uimenu(h1,'Label','Store bkg(E)', ...
   'Callback','ms_help(''Cut: Store bkg(E)'');');
h2=uimenu(h1,'Label','x-axis', ...
   'Callback','ms_help(''Cut: x-axis:'');');
h2=uimenu(h1,'Label','Plot Cut', ...
   'Callback','ms_help(''Cut: Plot Cut:'');');
h2=uimenu(h1,'Label','Plot Cut Over', ...
   'Callback','ms_help(''Cut: Plot Cut Over'');');

% === the Detector Trajectories menu
h1=uimenu(h,'Label','Detector Trajectories',...
   'Callback','ms_help(''Detector Trajectories'');');

% === the Command Line Operations menu
h1=uimenu(h,'Label','Command line operations');
h2=uimenu(h1,'Label','Adding files',...
   'Callback','ms_help(''Adding .spe files'');');
h2=uimenu(h1,'Label','More files in memory simultaneously',...
   'Callback','ms_help(''More files in memory simultaneously'');');
h2=uimenu(h1,'Label','Saving data in binary .mat format','Callback',...
   'ms_help(''Saving data in binary .mat format'');');
h2=uimenu(h1,'Label','Masking detectors','Callback',...
   'ms_help(''Masking detectors'');');
h2=uimenu(h1,'Label','Simulating scattering','Callback',...
   'ms_help(''Simulating scattering'');');
h2=uimenu(h1,'Label','Subtracting backgrounds',...
   'Callback','ms_help(''Subtracting backgrounds'');');
h2=uimenu(h1,'Label','Displaying 3d/4d data from other sources','Callback',...
   'ms_help(''Displaying 3d/4d data from other sources'');');

% === the Useful Software menu
h1=uimenu(h,'Label','Useful Software');
h2=uimenu(h1,'Label','Editor for PC',...
   'Callback','ms_help(''Editor for PC'');');
h2=uimenu(h1,'Label','FTP for PC',...
   'Callback','ms_help(''FTP for PC'');');
h2=uimenu(h1,'Label','Mfit',...
   'Callback','ms_help(''Mfit fitting programme for MATLAB'');');


%========== Top Menu : About ==========================
hmenu=uimenu(fig,'Label','About MSlice ...');
hmenu1=uimenu(hmenu,'Label',['MSlice version' lastupdate]);
hmenu1=uimenu(hmenu,'Label','Matlab Visualisation Software');
hmenu1=uimenu(hmenu,'Label','for Single Crystal and Powder Time-of-Flight Neutron Data');
hmenu1=uimenu(hmenu,'Label','written by Radu Coldea @1998-2001');
hmenu1=uimenu(hmenu,'Label','           Oak Ridge National Labortatory, USA');
hmenu1=uimenu(hmenu,'Label','           and ISIS Facility, Rutherford Appleton Laboratory, UK');
hmenu1=uimenu(hmenu,'Label','           email : r.coldea@rl.ac.uk');
hmenu1=uimenu(hmenu,'Label','Self Test Mslice','Callback','test_mslice','Separator','on');
hmenu1=uimenu(hmenu,'Label','Quich check Mex-files correctness','Callback','check_mex_version');

% =========== Draw sample and viewing parameters menu options ===========
% =========== different for powder and single crystal samples ===
ms_sample;

% ======= Load parameter (.msp) file ==============
ms_load_msp(MspFile);











  
