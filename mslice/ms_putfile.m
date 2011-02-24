function cancel=ms_putfile(hdir,hfile,filter,titlewindow)

% function cancel=ms_getfile(hdir,hfile,filter,titlewindow);
% uses the uiwindow to select a file with a given filter
% starting directory in get(hdir,'String');
% store final pathname and filename in the 'String' properties of hdir and hfile

% === return if ControlWindow not opened 
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp(['No ControlWidow opened, no file can be selected using the uiwindow menu.']);
   return;
end

pathname=get(mslice_config,hdir);

% === if pathname is empty or could not be located in the current search path
% === replace with MSlice Examples directory
if isempty(pathname)|| ~exist(pathname,'dir')
   pathname=get(mslice_config,'SampleDir');
   if ~exist(pathname,'dir')
       disp('MSlice samples path appears can not be found. Return.');
       cancel=1;
       return;       
   end
end

if(pathname(end)~=filesep)
    pathname=[pathname,filesep];
end
%
if ishandle(hfile)  
   [filename,pathname]=uiputfile([pathname ms_filter(hfile,filter)],titlewindow);
elseif ischar(hfile)
    file_name=get(mslice_config,hfile);
    [ff,file_base]=fileparts(file_name);    
    [filename,pathname]=uiputfile([pathname,filter],titlewindow);    
else
    error('ms_getfile:wrong_parameters',' second parameter of ms_getfile has to be graphical handler or character string');     
end
    

if ischar(filename),
   set(mslice_config,hdir,pathname);
% save the file name in graphical handle or configuration depending on call parameters   
   if ishandle(hfile)   
       set(hfile,'String',filename);
   elseif ischar(hfile)
        set(mslice_config,hfile,filename);       
   end
   cancel=0;
else
   cancel=1;
end
