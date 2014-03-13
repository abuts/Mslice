function cancel=ms_getfile(hdir,hfile,filter,titlewindow)

% function ms_getfile(hdir,hfile,filter,titlewindow);
% uses the uiwindow to select a file with a given filter
% starting directory in get(hdir,'String');
% store final pathname and filename in the 'String' properties of hdir and hfile


pathname=get(mslice_config,hdir);

% === if pathname is empty or could not be located in the current search path
% === replace with MSlice directory
if isempty(pathname)||(~exist(pathname,'dir'))
    pathname=fileparts(which('mslice.m'));
    if  isempty(pathname)||(~exist(pathname,'dir'))
        disp('Could not determine MSlice path. Return.');
        cancel=1;
        return;
    end
end
if iscell(filter)
    [filename,pathname]=uigetfile(filter,titlewindow,pathname);        
else
    if pathname(end:end)~=filesep
        pathname=[pathname,filesep];
    end
    [filename,pathname]=uigetfile([pathname filter],titlewindow);    
end
if ischar(filename),
   set(mslice_config,hdir,pathname);
   
   if ishandle(hfile)
        set(hfile,'String',filename);
   elseif ischar(hfile)
        set(mslice_config,hfile,filename);       
   else
       error('ms_getfile:wrong_parameters',' second parameter of ms_getfile has to be graphical handler or character string'); 
   end
   cancel=0;
   
   [dir,fname,fext]=fileparts(filename);
   % set the default behaviour of the "par from nxpse checkbox
    h_cw     =findobj('Tag','ms_ControlWindow');        
    h_checkbox=findobj(h_cw,'Tag','ms_usePhxFromNXSPE'); 
   if strcmpi(fext,'.nxspe')
       set(h_checkbox,'Value',true);
   else
       set(h_checkbox,'Value',false);
   end
else
   cancel=1;
end