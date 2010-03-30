function ms_load_data
% function ms_load_data
% callback function for the 'Load Data' button on the ControlWindow

% === return if ControlWindow not opened 
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp(['No Control widow opened, no .spe data to be loaded.']);
   return;
end

%=== read parameters of .spe data file
h_dir=findobj(h_cw,'Tag','ms_DataDir');
h_file=findobj(h_cw,'Tag','ms_DataFile');
if isempty(h_dir)||isempty(h_file),
   disp(['Could not associate objects to .spe directory and filename. No data file could be read.']);
   return;
end
spe_file=get(h_file,'String');
spe_file=spe_file(~isspace(spe_file));	% remove white spaces
if ~isempty(spe_file),
   spe_filename=[get(h_dir,'String') spe_file];
else	% whole filename is empty if no file given
   spe_filename=[];
end

% === read parameters of .phx detector layout file
h_dir=findobj('Tag','ms_PhxDir');
h_file=findobj('Tag','ms_PhxFile');
if isempty(h_dir)||isempty(h_file),
   disp(['Could not associate objects to .phx directory and filename. No data file could be read.']);
   return;
end
phx_file=get(h_file,'String');
phx_file=phx_file(~isspace(phx_file));
if ~isempty(phx_file),
	phx_filename=[get(h_dir,'String') phx_file];
else
   phx_filename=[];
end

% === highlight red busy button
h_status=findobj(h_cw,'Tag','ms_status');
if ~isempty(h_status)&&ishandle(h_status),
   red=[1 0 0];
   set(h_status,'BackgroundColor',red);
%   set(h_status,'Visible','on');      
   drawnow;
end

% === construct .spe data structure 
% if ~exist(spe_filename,'file')
%     disp(['can not find file',spe_filename]);
%     disp('choose spe file location'); 
%     spe_pathname = fileparts(spe_filename);
%     [spe_filename,spe_pathname] = uigetfile([spe_pathname,filesep,'*.spe'],'Select SPE files to open');   
%     if(spe_filename ~=0)
%         hMsp_dir=findobj(h_cw,'Tag','ms_MspDir');
%         hMsp_file=findobj(h_cw,'Tag','ms_MspFile');
%         Msp_dir = get(hMsp_dir,'String');
%         Msp_file = get(hMsp_file,'String');        
%         fileName = [Msp_dir,Msp_file];
%         perl('set_key_value.pl',fileName,'DataDir',spe_pathname,'DataFile',spe_filename,'cut_OutputDir',spe_pathname);
%         ms_load_msp(fileName);
%         %h_file
%     end
% end
check_file_existence(spe_filename,'spe','DataDir','DataFile');
check_file_existence(phx_filename,'phx','PhxDir','PhxFile');
data=buildspe(spe_filename,phx_filename);
if ~isempty(data),
   set(h_cw,'UserData',data);
end

% === highlight green button
if ~isempty(h_status)&&ishandle(h_status),
   green=[0 1 0];
   set(h_status,'BackgroundColor',green);
%   set(h_status,'Visible','off');   
   drawnow;
end
%%
function rez=check_file_existence(file_name,ext,dir_field,file_field)
if ~exist(file_name,'file')
    disp(['can not find file',file_name]);
    disp(['choose ',ext,' file location']); 
    path_name = fileparts(file_name);
    [file_name,path_name] = uigetfile([path_name,filesep,'*.',ext],['Select ',ext,' files to open']);   
    if(file_name ~=0)
        h_cw=findobj('Tag','ms_ControlWindow');        
        hMsp_dir=findobj(h_cw,'Tag','ms_MspDir');
        hMsp_file=findobj(h_cw,'Tag','ms_MspFile');
        Msp_dir = get(hMsp_dir,'String');
        Msp_file = get(hMsp_file,'String');        
        fileName = [Msp_dir,Msp_file];
        perl('set_key_value.pl',fileName,file_field,file_name,dir_field,path_name);
        ms_load_msp(fileName);
        %h_file
        rez = 1;                
    else        
        rez = 0;        
    end
else    
    rez = 1;                
end
