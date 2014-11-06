function ms_load_msp(file)
% function reads mslice msp file and sets msp parameters values into GUI


% ==== return if ControlWindow not opened or if MspDir and MspFile objects could not be located
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
    disp('No MSlice Control widow opened, no parameter file loaded.');
    return;
end
%
% if the file is example file
is_read_only=false;
%=== SELECT .MSP PARAMETER FILE
if ~exist('file','var'),
    % ==== select .msp file by browsing =====
    cancel=ms_getfile('MspDir','MspFile','*.msp','Load parameter file for MSlice ControlWindow (.msp)');
    % === if cancel button pressed then return, do not load in .msp file
    if cancel,
        return
    end
    msc = mslice_config();
    file_path =msc.MspDir;
    file_name =msc.MspFile;
    
    file_path = check_default_msp_file(file_path,file_name);
    fullname = fullfile(file_path,file_name);
else  % ==== select given or default .msp file =========
    if exist(file,'file'),
        [file_path,file_name,ext]=fileparts(file);
        file_name=[file_name,ext];
        % if default msp file selected, copy it to different place to avoid
        % overwriting defaults.
        file_path = check_default_msp_file(file_path,file_name);        
        fullname = fullfile(file_path,file_name);
        
    elseif exist(fullfile(get(mslice_config,'MspDir'),file),'file')
        % it is default msp file;
        file_name = file;
        file_path = get(mslice_config,'MspDir');
        file_path = check_default_msp_file(file_path,file);
        
        fullname=fullfile(file_path,file);
        
    elseif exist(fullfile(pwd,file),'file')
        file_name = file;
        file_path  = pwd;
        % are we working in msp configuration folder?
        file_path = check_default_msp_file(file_path,file);
        
        fullname=fullfile(file_path ,file);
    else % file could not be found in the default search path ,
        % default parameter file chosen instead
        disp(['Given parameter file ' file ' not found in search path.']);
        sample_file_path = get(mslice_config,'SampleDir');
        file_name = 'crystal_psd.msp';
        
        file_path = check_default_msp_file(sample_file_path,file_name);
        fullname=fullfile(file_path,file_name);
        
        if ~exist(fullname,'file')
            error('ms_load_msp:mslice_error','a file %s which is the part of mslice distributive is absent at sample dir: %s',file_name,sample_file_path);
        end
        disp(['Selected default parameter file: ' fullname]);
    end
end
set(mslice_config,'MspDir',file_path);
set(mslice_config,'MspFile',file_name);

% get data defined in mslice configurations.
msl_conf  = get(mslice_config);
%msl_conf = msl_conf.mslice_config;
% === open .msp parameter file for reading as an ASCII text file
fid=fopen(fullname,'rt');
if fid==-1,
    disp(['Error opening parameter file ' fullname '. Return.']);
    return;
end

% === highlight red button indicating 'busy'
h_status=findobj(h_cw,'Tag','ms_status');
if ~isempty(h_status)&& ishandle(h_status),
    red=[1 0 0];
    set(h_status,'BackgroundColor',red);
    drawnow;
end
nmodific    = 0;
modificators='';
is_nxspe_file=false;       % usually not;

%=== READ .MSP FILE LINE BY LINE
disp(['Proceed reading parameter file ' fullname]);
t=fgetl(fid);
while (ischar(t))&(~isempty(t(~isspace(t))))
    if t(1)=='#' % skip comments
        t=fgetl(fid);
        continue
    end
    pos=strfind(t,'=');
    field=t(1:pos-1);
    field=field(~isspace(field));
    
    % === if having reached det_type, the sample is single crystal and analysis mode is undefined
    % === put by default analysis mode = single crystal
    if strcmpi(field,'det_type')&(get(findobj(h_cw,'Tag','ms_sample'),'Value')==1),
        analobj=findobj(h_cw,'Tag','ms_analysis_mode');
        if ~isempty(analobj)&(get(analobj,'Value')~=1),
            set(analobj,'Value',1);
            ms_analysis_mode;
            drawnow;
        end
    end
    value=t(pos+1:length(t));
    % check if the value is not a form
    str_position = strfind(value,'#');
    its_a_form   = false;
    if isempty(str_position)
        % remove leading and trailing blanks from both the beginning and end of string
        value=strtrim(deblank(value));
    else
        % remove the character, which indicates that it is a form
        value = value(str_position+1:end);
        its_a_form =true;
    end
    h=findobj(h_cw,'Tag',['ms_' field]);
    if ~isempty(h),
        if strcmp(get(h,'Style'),'popupmenu')|| strcmp(get(h,'Style'),'checkbox'),
            if its_a_form
                form_contents = regexp(value,';','split');
                valid_fields = cellfun(@(x) ~isempty(x),form_contents);
                form_contents =form_contents(valid_fields);
                if numel(form_contents)>0
                    set(h,'Value',1);
                    set(h,'String',form_contents(:));
                end
                t=fgetl(fid);
                continue
            else
                set(h,'Value',str2double(value));
            end
        else
            set(h,'String',value);
        end
        
        % To avoid the use of eval set the sample mode implicitly every time and execute ms_sample to
        % generate the correct fields in the main window.
        % The code
        %    switch field
        %       :
        %    end
        % replaces
        %    eval(get(h,'Callback'));
        switch field
            case{'sample'}
                set(h,'Value',str2num(value))
                ms_sample
            case{'analysis_mode'}
                set(h,'Value',str2num(value))
                ms_analysis_mode
            case{'det_type'}
                set(h,'Value',str2num(value))
                ms_disp_or_slice
            case{'DataFile'}
                [dir,fname,fext]=fileparts(value);
                if strcmpi(fext,'.nxspe')
                    is_nxspe_file = true;
                end
            case{'PhxFile'}
                h=findobj(h_cw,'Tag','ms_usePhxFromNXSPE');
                phx_file=value(~isspace(value));
                if strcmpi(phx_file,'obtainedfromnxspefile')
                    if is_nxspe_file % file is nxspe file and no par file is defined;
                        set(h,'Value',1);
                    else                % file is nxpse file but par file is present; use par file
                        set(h,'Value',0);
                    end
                else  % not obtained from nxspe and not nxspe file;
                    set(h,'Value',0);
                end
            otherwise
        end
        % drawnow;
    else % it is possible that the field is defined in configuration now. This field is a path then
        if isfield(msl_conf,field)
            % this is a path which may be specified either in the file
            % itself, or in configuration; Arbitration would occur.
            
            if (strcmp(field,'MspDir')||strcmp(field,'MspFile')) % if it is MspDir or MspFile, then it has been set already
                if strcmp(field,'MspFile') && ~strcmp(value,file_name) % but the msp file name in defined in the file is different from the filename itself
                    % need to fix it;
                    nmodific =nmodific+1;
                    modificators{nmodific}='MspFile';
                    nmodific =nmodific+1;
                    modificators{nmodific}=file_name;
                end
            elseif strncmp(value,'$.',2) % this is probably relative path to a sample data and the field is read only
                full_dir=fullfile(get(mslice_config,'MspDir'),value(4:length(value)));
                set(mslice_config,field,full_dir);
                is_read_only=true;
            elseif strncmp(value,'.',1) % this is probably relative path to a sample data below
                full_dir=fullfile(get(mslice_config,'MspDir'),value(3:length(value)));
                if exist(full_dir,'dir')
                    set(mslice_config,field,full_dir);
                else
                    full_dir=get(mslice_config,field);
                    msp_dir =get(mslice_config,'MspDir');
                    short_dir=strrep(full_dir,msp_dir,'./');
                    nmodific =nmodific+1;
                    modificators{nmodific}=field;
                    nmodific =nmodific+1;
                    modificators{nmodific}=short_dir;
                end
                
            else
                if exist(value,'dir') % the path is specified by sting in the file;
                    set(mslice_config,field,value);
                else % the path should be y specified by config variables
                    path=get(mslice_config,field);
                    msp_dir =get(mslice_config,'MspDir');
                    path  =strrep(path,msp_dir,'./');
                    
                    nmodific =nmodific+1;
                    modificators{nmodific}=field;
                    nmodific =nmodific+1;
                    modificators{nmodific}=path;
                end
                
            end
        else
            disp(['Field ms_' field ' not defined and Field ' field ' does not exist in configuration. Check .msp file.']);
        end
    end
    t=fgetl(fid);
end
drawnow;
fclose(fid);
disp(['Successfully read parameter file ' fullname]);

% replace sting in old msp file with its new equivalents

if ~isempty(modificators)&&(~is_read_only)
    keys  = modificators(1:2:nmodific);
    values = modificators(2:2:nmodific);
    set_key_value(fullname,keys,values)
    %     for i=1:floor(nmodific/2)
    %         perl('set_key_value.pl',fullname,modificators{2*i-1},modificators{2*i});
    %     end
end

% === update .msp file details
%[filename]=stripath(fullname);
%pathname=get(mslice_config,'MspDir');
%set(h_file,'String',filename);

% === highlight green button indicating 'not busy'
if ~isempty(h_status)&& ishandle(h_status),
    green=[0 1 0];
    set(h_status,'BackgroundColor',green);
    drawnow;
end

function working_file_path=check_default_msp_file(working_file_path,file_name)
% check if there is default msp file and if it is, copy it for further
% usage into working location.
% return full file name to the working msp file
msc = mslice_config();
sample_path = msc.SampleDir;
if ispc
    same_path = strcmpi(working_file_path,sample_path);
else
    same_path = strcmp(working_file_path,sample_path);    
end

if same_path
    % copy default msp file into the place where mslice configuration
    % is stored for it to be modifiable safely
    working_file_path= msc.config_folder;
    sample_msp_file = fullfile(sample_path,file_name);
    work_msp_file = fullfile(working_file_path,file_name);
    copyfile(sample_msp_file,work_msp_file);
    
    disp(['Copied sample parameter file ' sample_msp_file ' to working file ' work_msp_file]);
end


