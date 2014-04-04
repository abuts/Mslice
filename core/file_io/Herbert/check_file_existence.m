function rez=check_file_existence(file_name,ext,dir_field,file_field,set_non_existent)
% function verifies if the file exists and pops the gui requesting to provide 
% a file if the file has not been found
% if the set_non_existent field is set to true
%
%

try
    file_name = check_file_exist(file_name,ext);
    rez = file_name;
    return;
catch exception;
    if ~strcmp(exception.identifier,'CHECK_FILE_EXIST:wrong_argument') % file not found       
        rethrow(exception);
    end
end

% if not found initial file, check another one. 
if exist('set_non_existent','var') && set_non_existent
        if isempty(file_name)
            file_name='non-existent file';
        end
        path_name=' ';
else
        disp(['can not find file',file_name]);
        disp(['choose ',ext,' file location']); 
        path_name = fileparts(file_name);
        [file_name,path_name] = uigetfile([path_name,filesep,'*.',ext],['Select ',ext,' files to open']);   
end
% set the actual value of the filename and filepath to configuration
% and GUI
if(file_name ~=0)
        h_cw     =findobj('Tag','ms_ControlWindow');   
        if isempty(h_cw)
            rez = file_name;
            return;
        end
        h_file=findobj(h_cw,'Tag',file_field);
        set(mslice_config,dir_field,path_name);
        set(h_file,'String',file_name)

        msp_dir=get(mslice_config,'MspDir');
        msp_file=get(mslice_config,'MspFile');

        full_msp=fullfile(msp_dir,msp_file);

        set_key_value(full_msp,file_field(4:end),file_name)        
        
        
        %h_file
        rez = fullfile(path_name,file_name);                
else        
        rez = '';        
end


