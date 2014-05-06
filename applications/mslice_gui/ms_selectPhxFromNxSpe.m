function output_args = ms_selectPhxFromNxSpe( )
% function controls the state of the PhxFromNxSpe check-box
% and should be storing this for future usage
%
% As nxspe does not currently work properly in all situations,
% a warning is issued when the option is enabled and the state of the
% check-box is not saved


h_cw     =findobj('Tag','ms_ControlWindow');
h_checkbox=findobj(h_cw,'Tag','ms_usePhxFromNXSPE');
Value=get(h_checkbox,'Value');
%
h_file=findobj(h_cw,'Tag','ms_PhxFile');
if isempty(h_file),
    disp('Could not associate objects to .phx filename. No data file could be read.');
    return;
end
%
phx_file=get(h_file,'String');
phx_file=phx_file(~isspace(phx_file));
phx_nxspe_tag = false;
if strcmpi(phx_file,'obtainedfromnxspefile')||strcmpi(phx_file,'phxdatastoredinnxspefilewillbeused')
    phx_nxspe_tag =true;
end
if Value
    if phx_nxspe_tag
        set(h_file,'String','phx data stored in nxspe file will be used') ;
    else
        h_data_file=findobj(h_cw,'Tag','ms_DataFile');
        if isempty(h_data_file),
            disp('Could not associate objects to data filename. It can not be nxspe file');
            return;
        end
        data_file = get(h_data_file,'String');
        if isempty(data_file)
            warning('ms_select_from_nxspe:not_nxspe',' can not get data file name from gui');
        end
        [dir,fname,fext] = fileparts(data_file);
        if ~strcmpi(fext,'.nxspe')
            warning('ms_select_from_nxspe:not_nxspe',' the file %s does not have nxspe extension, so probably is not nxspe file; can not load par data from it',data_file);
            set(h_checkbox,'Value',0);
        end
      
    end
    set(h_file,'String',phx_file,'ForegroundColor','w');        
    
else
    
    if phx_nxspe_tag  % not a file, but nxspe identifier;
        path_name=get(mslice_config,'PhxDir');
        if strncmp(' ',path_name,1)
            path_name = get(mslice_config,'DataDir');
        end
        if strncmp(' ',path_name,1)
            path_name = get(mslice_config,'MSliceDir');
        end
        [file_name,path_name] = uigetfile([path_name,filesep,'*.','phx'],['Select phx file to use with this spe file']);
        set(mslice_config,'PhxDir',path_name);
        if ~isempty(file_name)
            set(h_file,'String',file_name)
        else
            set(h_file,'String',' ')
        end
        
        msp_dir=get(mslice_config,'MspDir');
        msp_file=get(mslice_config,'MspFile');
        
        full_msp=fullfile(msp_dir,msp_file);
        if ~isempty(file_name)
            set_key_value(full_msp,'PhxFile',file_name)
            %  perl('set_key_value.pl',full_msp,'PhxFile',file_name)
        end
        set_key_value(full_msp,'PhxDir',path_name)
        %perl('set_key_value.pl',full_msp,'PhxDir', path_name)
    end
    set(h_file,'String',phx_file,'ForegroundColor','k');           
    
end

% set(h_checkbox,'Value',false);

end

