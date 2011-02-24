function rez=install_isis(varargin)
% function installs (e.g. allows matlab to find and use) the ISIS package, 
% specified as the first argument of the script to a specific location.
% The location is either specified by user, is default or is the current folder
%
% USAGE:
% >>install_isis('package_name.zip',['guided']) 
%                                   -- install the package into the folder
%                                        where zip file is placed; creates
%                                        ISIS folder with subfolders
%                                        according to the package name
%>>install_isis('current_package_folder',['guided'])
%                                  -- install the package into the
%                                        location, where it is already
%                                        unpacked;
%>>install_isis('package_name.zip','destination_folder',['guided']) 
%                                  -- install into the location specified 
% if the optional parameter 'guided' is provieded, the package will ask
% numner of specific questions about installation;
%
% $Revision$ ($Date$) 
%
rez=false;
% names of packages availible for installations through this script;
pack_names=cell(1,3);
pack_names{1}='Libisis';
pack_names{2}='Horace';
pack_names{3}='Mslice';
% 

%
% DEFAULTS (will be redefined from command line parameters below)
id.package_name         = 'libisis';
id.package_orig_folder  ='./';
id.package_file         ='libisis.zip';

id.allPacks_dest_folder = 'c:/ISIS';
id.pack_install_folder  = fullfile(id.allPacks_dest_folder,id.package_name);
% where to place files, which initiate the package
id.startup_folder       = fullfile(matlabroot,'toolbox','ISIS');
% will be processed according to setting and OS later
id.unpack_folder        = getenv('TEMP');
%
% thise parameters remain unchanged and define the behaviour if silent
% installation is selected (default)
%
id.silent_install    = true;   % do not ask questions about the fields values below abd accept their default values
if nargin>=3 || (nargin==2 && strcmp(varargin{2},'guided'))
    id.silent_install=false;
end
id.add2startup       = true;  % add package-initiation procedures to existiting startup files
id.build_startup     = false; % create an start-up file if one does not exist
id.unpacked          = false; % package is already unpacked. 
id.old_found         = false; % old package with the same name is already indentified. 
id.replace_existing  = false; % place new package intstead of the existing one. 
%
% calculate changes to the installation defaults above on the basis of the input
% arguments;
id=parse_arguments(id,pack_names,varargin{:});
% check if old really exists
old_pack=which([lower(id.package_name),'_init']);
if ~isempty(old_pack)
    id.old_found = true;  
end

%==========================================================================
mess1=sprintf('! Installing package: %s                                        !',id.package_name);
mess2=sprintf('! into the folder: %s !',id.allPacks_dest_folder);
disp('!-------------------------------------------------------------------!')
disp(mess1);
disp(mess2);
disp('!-------------------------------------------------------------------!')
if ~id.silent_install
    mess=sprintf('! would you like to start the package %s each time MATLAB starts (no)? (y/n):',id.package_name);
    user_ans=input(mess,'s');
    if (~isempty(user_ans))&&lower(user_ans(1))=='y'
        id.add2startup  =true;
        id.build_startup=true;
    else
        id.add2startup=false; 
        id.build_startup=false;        
    end
    if id.old_found
        mess1=sprintf('! Anther version of the package %s exists ',id.package_name);    
        mess2=sprintf('! In location: %s ',fileparts(old_pack));    
        disp(mess1);
        disp(mess2);        
    
        user_ans=input('! would you prefer to place the new package there owerwriting the old(no)? (y/n):','s');
        if (~isempty(user_ans))&&lower(user_ans(1))=='y'
            id.replace_existing=true;            
        else
            id.replace_existing=false;            
        end    
    end
end
%--------------------------------------------------------------------------
% actions start
if id.old_found && id.replace_existing
disp('!-------------------------------------------------------------------!')
disp('! deleting existing and placing the path to put new pack there      !')
    old_path_pack   =fileparts(old_pack);
    rmdir(old_path_pack);
    id.allPacks_dest_folder = fileparts(old_path_pack);
    id.pack_install_folder  = fullfile(id.allPacks_dest_folder,id.package_name);
    
end
%--------------------------------------------------------------------------
disp('!-------------------------------------------------------------------!')
disp('!  unpacking package into the destination folder                    !')
if ~id.unpacked
    unzip(fullfile(id.package_orig_folder,id.package_file),id.unpack_folder);
    id.unpacked=true;
    id.unpack_folder=fullfile(id.unpack_folder,'ISIS');
end
disp('!  Successfull                                                      !')


delete_tmp=false;
if ~strcmp(id.unpack_folder,id.allPacks_dest_folder)
    app_tmp_folder=fullfile(id.unpack_folder,id.package_name);
    copyfile(app_tmp_folder,id.pack_install_folder,'f');
    rmdir(app_tmp_folder,'s');
    delete_tmp=true;    
end
disp('!-------------------------------------------------------------------!')
disp('!  Modifying MATLAB search path to look for application             !')
%
id=create_init_folder(id);
%
id=modify_app_startup_files(id);
%
disp('!-------------------------------------------------------------------!')
if id.add2startup 
    % modify MATLAB startup.m file    
    startup_modified=modify_MATLAB_startup_file(id);
    mess1 = sprintf('! Sucsessfully installed ISIS application: %s',id.package_name);
    disp(mess1);
    if startup_modified
disp('! It will be automatically availble after you restart MATLAB        !')
%        f_name=[lower(id.package_name),'_init'];
    else
        mess = sprintf('! You need to type %s_on to initiate it after MATLAB restarted',lower(id.package_name));           
        disp(mess) ;
    end
    f_name=[lower(id.package_name),'_on'];            
    rehash toolbox;       
    eval(f_name);        
    
disp('!-------------------------------------------------------------------!')   
else
    mess = sprintf('! Sucsessfully installed ISIS application: %s',id.package_name);
    disp(mess);
    if strcmpi(id.pack_install_folder,id.startup_folder)
        mess = sprintf('! You can type %s_on or %s_init to initiate it',lower(id.package_name),lower(id.package_name));
    else
        mess = sprintf('! Type %s_on to initiate it',lower(id.package_name));    
    end
    disp(mess);
end
if delete_tmp
    rmdir(id.unpack_folder,'s');
end
rez=true;
disp('!-------------------------------------------------------------------!')
%
%% -------------------------------------------------------------------

function id=parse_arguments(id,pack_names,package_f_or_dir,package_dest_folder)
% function calculates the installation details on the basis of the
% installation options supplied in a command line;
%
%
if ~exist('package_f_or_dir','var')
    error('install_ISIS:arguments','first argument can not be empty and has to be a package name or folder');
end
%!------------------------------------------------------------------------!
%! identify if either the package name or package folder is supplied;     !
%!------------------------------------------------------------------------!
package_file=false;
package_dir =false;
if exist(package_f_or_dir,'dir')
    package_dir= true;    
elseif exist(package_f_or_dir,'file')
    package_file=true;
end

if ~(package_file||package_dir)
    mess=sprintf('install_ISIS:arguments :: can not find file or folder %s',package_f_or_dir);
    disp(mess);
    error('install_ISIS:arguments','first argument has to be installation package name or package folder');
end
% identify the package name one of list of availible
% 
if package_dir
    ext='';
    dir_path=regexprep(package_f_or_dir,'\\','/');
    dir_tree=regexp(dir_path,'/','split');
    if isempty(dir_tree{end});
        dir_tree=dir_tree(1:end-1);
    end
    last_name=dir_tree{end};
    path='';
    fs=filesep;
    for i=1:numel(dir_tree)-1
        path=[path,dir_tree{i},fs];
    end
    
else
    [path,last_name,ext]=fileparts(package_f_or_dir);
end
% idenfify full package path;
cur_path=pwd;
if ~isempty(path)
    cd(path);
end
path=pwd;    
cd(cur_path);

%!------------------------------------------------------------------------!
%! PACKAGE FILE SUPPLIED  -------->                                       !
%!------------------------------------------------------------------------!
if package_file % file name supplied;
    
    if ~strcmpi(ext,'.zip')
        error('install_ISIS:arguments',' package extension to be .zip but %s supplied',ext);
    end
    package_name='';
    for i=1:numel(pack_names)
        if regexpi(last_name,pack_names{i},'once')
            package_name=pack_names{i};
            break;
        end
    end
    id.unpacked           = false;
    id.package_orig_folder= path;
    id.package_file       = [last_name,'.zip'];
    id.package_name       = package_name;
    package_fullfile=fullfile(path,id.package_file);    
    if ~exist(package_fullfile,'file')
        error('install_ISIS:logic',' installation package %s does not exist, try alternative installation methods',package_fullfile)
    end
    % where to unpack package temporary :    
    if ispc()
        id.unpack_folder        = getenv('TEMP');
    else
        id.unpack_folder        = '/tmp';
        if mkdir(fullfile(id.unpack_folder,'tt'))
            rmdir(fullfile(id.unpack_folder,'tt'));
        else
            id.unpack_folder        = getenv('TMPDIR');
            if ~mkdir(fullfile(id.unpack_folder,'tt'))
                error('install_ISIS:arguments',...
               'can not obtain folder to keep temporary files. Please, set up TMPDIR enviromental variable to a temporary folder where you have permissions to write')
            else
                rmdir(fullfile(id.unpack_folder,'tt'));                
            end
        end
    end
    
end
%!------------------------------------------------------------------------!
%! PACKAGE DIR  SUPPLIED  -------->                                       !
%!------------------------------------------------------------------------!
if package_dir % folder name supplied
    package_name='';
    for i=1:numel(pack_names)
        pack_init_name=lower([pack_names{i},'_init.m']);
        if exist(fullfile(path,last_name,pack_init_name),'file')
            package_name=pack_names{i};
            break;            
        end
    end
    id.package_orig_folder=fullfile(path,last_name);
    id.package_file       ='';
    id.unpacked           = true;    
    id.unpack_folder      = path;
    id.package_name       = package_name;   
end
%
if isempty(package_name)
   mess=['install_ISIS:arguments :: recognized packages are: ',sprintf('%s ',pack_names{:})];
   disp(mess);
   error('install_ISIS:arguments',' can not identify the package in %s',package_f_or_dir);    
end
%!------------------------------------------------------------------------!
%! IDENTIFY THE DESTINATION FOLDER:                                       !
%!------------------------------------------------------------------------!
if exist('package_dest_folder','var') % simple case -- user have specified it. 
    if ~exist(package_dest_folder,'dir') 
        success=mkdir(package_dest_folder); %create
        if ~success
           error('install_ISIS:folder',' Can not create destination folder %s',package_dest_folder);
        end
    end
    % make full path to destination folder;
    cd(package_dest_folder)
    package_dest_folder=pwd;
    cd(cur_path);

    id.allPacks_dest_folder =package_dest_folder;
    id.pack_install_folder  =fullfile(id.allPacks_dest_folder,[upper(package_name(1)),lower(package_name(2:end))]);        
else
    if package_file
        id.allPacks_dest_folder =fullfile(id.package_orig_folder,'ISIS'); 
        id.pack_install_folder  =fullfile(id.allPacks_dest_folder,[upper(package_name(1)),lower(package_name(2:end))]);                
    else %package dir;
        id.pack_install_folder = id.package_orig_folder; 
        id.allPacks_dest_folder= fileparts(id.pack_install_folder);
    end
end


%% -----------------------------------------------------------------------

function startup_present=modify_MATLAB_startup_file(id)
% modify startup file and add current application init file to the end of
% this file
%
stf=which('startup.m');
if isempty(stf) 
    if ~id.build_startup
        startup_present =false;
        return;
    end
    stf=fullfile(userpath(),'startup.m');   
    fout = fopen(stf,'w');
else
    fout=fopen(stf,'a+');

    warning('install_isis:startup_exists',...
            ['! You have matlab startup file located in: %s \n',...
             '! The installation script have added %s initiation code to the startup \n',...
             '! To avoid multiple initiations of the package %s, \n',...
             '! You have to modify startup file manualy if you have initiated it in the startup before'],...
        fileparts(stf),id.package_name,id.package_name);        
    fprintf(fout,'\n');        
end
startup_present  =true;

app_startup_string1=['addpath(''',fullfile(id.pack_install_folder,''),''')'];
app_startup_string2=[lower(id.package_name),'_init'];
fprintf(fout,'%s\n',app_startup_string1);    
fprintf(fout,'%s\n',app_startup_string2);    
fclose(fout);

function id=modify_app_startup_files(id)
% modify template 
app_startup_template= fullfile(id.unpack_folder, lower([id.package_name,'_on.mt']));
app_startup_file    = fullfile(id.startup_folder,lower([id.package_name,'_on.m']));
if ~exist(app_startup_template,'file')
    create_pack_on_teplate(id.package_name,id.unpack_folder);
end
copyfile(app_startup_template,app_startup_file,'f');
template_path=lower(['$',id.package_name,'_path$']);

if strcmpi(id.package_name,'horace')
    libisis_init_file=which('libisis_init');
    if isempty(libisis_init_file)
        disp('! Horace needs libisis to be availible. Please, provide current or prospective location for the installed libisis_init.m file');
        libisis_init_file=uigetfile('libisis_init.m','Select the location of libisis_init file');
        if isempty(libisis_init_file)
            error('install_ISIS:prerequest',' you need libisis installed and initiated to be able to install and use horace')
        else
            if ~exist(libisis_init_file,'dir')
                if exist(libisis_init_file,'file')
                    libisis_install_path=fileparts(libisis_init_file);
                else
                    error('install_ISIS:prerequest',' can not locate file %s',libisis_init_file)                    
                end
            else
                libisis_install_path=libisis_init_file;
            end
        end
    else
        libisis_install_path=fileparts(libisis_init_file);        
    end

    modify_template(app_startup_file,'$libisis_path$',libisis_install_path);    
end
modify_template(app_startup_file,template_path,id.pack_install_folder);
if exist(app_startup_template,'file')
    delete(app_startup_template);
end
% copy start_app.m 
start_app_file=fullfile(id.unpack_folder,'start_app.m');
if ~exist(start_app_file,'file')
    create_pack_on_teplate('start_app',id.unpack_folder);
end
dest_file   = fullfile(id.startup_folder,'start_app.m');
if ~strcmp(start_app_file,dest_file)
    copyfile(start_app_file,dest_file,'f');    
    delete(start_app_file);
end



%
function modify_template(inout_file,template_var,var_value)
% replace specified template strings by their symbolic values;

new_string =sprintf('''%s''',var_value);
new_string =regexprep(new_string,'\\','/');

template_var=regexprep(template_var,'\$','\\\$');
old_string  =sprintf('%s',template_var);


fid = fopen(inout_file);    
if fid < 0   % Check file exists
    error('Input file template %s file can not be opened for access',inout_file)
end


[path,file]=fileparts(inout_file);
tmp_file   =fullfile(path,[file,'.tmp']);
fout= fopen(tmp_file,'w');
if fout<0
    error('Working file  %s file can not be opened for access',tmp_file)    
end

while 1
    tline = fgetl(fid); % get line of text

    if ~ischar(tline), break, end  % break at end of file (tline = -1)
    
    if numel(tline)>0 && tline(1)=='%'
        tlout=tline;
    else
        tlout = regexprep(tline,old_string,new_string);        
    end    
    fprintf(fout,'%s\n',tlout);
end
fclose(fid);
fclose(fout);
copyfile(tmp_file,inout_file,'f');
delete(tmp_file);


function id=create_init_folder(id)
% create the folder to place startup files and add this folder to the
% MATLAB search path or use existing startup folder
%
if ~exist(id.startup_folder,'dir')
    ok = mkdir(id.startup_folder);
    if ~ok
        id.startup_folder=id.pack_install_folder;
    end
end
addpath(id.startup_folder);
savepath;

function create_pack_on_teplate(package,path)
% the function creates a start-up template for files initiated by the package
% the templates are actually sitting in this file and saved;
% 
libisis_on={...
'function libisis_on(non_default_path)',...
'% The function switches libisis on by adding to Matlab search path all libisis folders necessary for proper work',...
'% The function has to be present in Matlab search path and the variable $libisis_path$ should be replaced ',...
'% by the full OS specific path where libisis has been unpacked. ',...
'%',...
'% $Revision$ ($Date$) ',...
'%',...
'warn_state=warning(''off'',''all'');    % turn of warnings (so dont get errors if remove non-existent paths)',...
'try',...
'   try',...
'         mgenie_off;',...
'   catch',...
'   end',...
'   warning(warn_state);     % return warnings to initial state',...
'catch',...
'     warning(warn_state);    % return warnings to initial state if error encountered',...
'end',...
'if nargin==1 ',...
'	start_app(''libisis'',non_default_path);',...
'else',...
'	start_app(''libisis'',$libisis_path$);',...
'end'...    
};
horace_on={... 
'function horace_on(non_default_libisis_path,non_default_horace_path)',...
'%  safely switches horace on',...
'%  horace_on()                                   -- calls horace with default settings',...
'%  horace_on(non_default_libisis_path)           -- calls horace with another libisis settings',...
'%  horace_on(''default'',non_default_horace_path)  -- calls horace with default libisis and non-default horace folder;',...
'%  horace_on(non_default_libisis_path,non_default_horace_path)  -- calls horace with libisis and horace located in non-default place',...
'%',...
'%',...
'%',...
'default_libisis_path=$libisis_path$;',...
'default_horace_path =$horace_path$;',...
'%',...
'warn_state=warning(''off'',''all'');    % turn of warnings (so dont get errors if remove non-existent paths)',...
'try',...
'   mslice_off',...
'catch',...
'end',...
'try',...
'    mgenie_off;',...
'catch',...
'end',...
'try',...
'   libisis_off',...
'catch',...
'end',...
'try',...
'   horace_off',...
'catch',...
'end',...
'warning(warn_state);    % return warnings to initial state',...
' ',...
'if nargin==1 ',...
'	start_app(''libisis'',non_default_libisis_path);',...
'elseif(nargin==2)',...
'    if strcmp(non_default_libisis_path,''default'')',...
'        non_default_libisis_path=default_libisis_path;',...
'    end',...
'	start_app(''libisis'',non_default_libisis_path);',...
'	start_app(''horace'',non_default_horace_path);	',...
'else',...
'	start_app(''libisis'',default_libisis_path);',...
'	start_app(''horace'',default_horace_path);',...
'end',...
' '...
};
mslice_on={...
'function mslice_on(non_default_path)',...
'% The function switches mslice on by adding to Matlab search path all mslice folders necessary for its correct operations',...
'% The function has to be present in Matlab search path and the variable $mslice_path$ should be replaced ',...
'% by the full OS specific path where libisis has been unpacked. ',...
'%',...
' ',...
'%',...
'if nargin==1 ',...
'	start_app(''mslice'',non_default_path);',...
'else',...
'	start_app(''mslice'',$mslice_path$);',...
'end',...
'   '...
};
start_app={...
'function start_app (app_name,opt,varargin)',...
'% Startup a named application with given root directory, or turn off an application',...
'%',...
'% Place this file (i.e. start_app) in a directory on your matlab path. To set up, for example,',...
'% libisis, which has root directory c:\mprogs\libisis, type (or add to your startup.m):',...
'%   >> start_app (''libisis'',''c:\mprogs\libisis'')',...
'%',...
'% To turn the application off:',...
'%   >> start_app (''libisis'', ''-off'')',...
'%',...
'% Note:',...
'% This routine assumes the existence of initialisation an ''off'' functions in the roots',...
'% directory of the application. For example, if the application is called ''my_program''',...
'% then if is assumed that the root directory for that application will contain the functions',...
'%',...
'%   my_program_init.m       % application specific function that sets the paths and any other initialisation',...
'%   my_program_off.m        % application specific function to turn off the program',...
'%',...
'% If my_program_init requires other parameters p1, p2,... to be passed to it, then this can be done',...
'% by passing them through start_app',...
'%',...
'% e.g. >> start_app (''mgenie'', ''c:\mprogs'', p1, p2, ...)',...
'%',...
'% The purpose of start_app is to enable greater control in testing multiple versions of a given',...
'% application. In particular, start_app(<name>,''-off'') will turn off all instances of a given application',...
'%',...
'%',...
'%',...
' ',...
' ',...
'% Check application name argument exists',...
'if exist(''app_name'',''var'')',...
'    if ~isvarname(app_name)',...
'        error (''First argument must be a valid name - no action taken.'');',...
'    end',...
'else',...
'   error(''Must give application name'')',...
'end',...
' ',...
'% Get root directory or other option',...
'if exist(''opt'',''var'')  % Check that the rootpath exists',...
'    if ischar(opt) && size(opt,1)==1',...
'        if strncmpi(opt,''-off'',max(length(opt),2))',...
'            initialise_application=false;',...
'        elseif exist(opt,''dir'')==7',...
'            initialise_application=true;',...
'            rootpath = opt;',...
'        else',...
'            error(''"%s" not a valid directory or option - no action taken.'',opt);',...
'            return',...
'        end',...
'    else',...
'        error(''First argument must be a valid directory or option - no action taken.'');',...
'    end',...
'else    % use the current working directory if none given',...
'    rootpath = pwd;',...
'end',...
'',...
'% Turn off any instances of application',...
'application_off (app_name,''no_no_present_message'')',...
'',...
'',...
'% Initialise particular instance of application, if requested',...
'if initialise_application',...
'    mess=application_init (app_name, rootpath, varargin{:});',...
'    if ~isempty(mess)',...
'        error(mess)',...
'    end',...
'end',...
'',...
'%=========================================================================================================',...
'function mess=application_init(app_name,rootpath,varargin)',...
'% Initialisation of application',...
'',...
'start_dir=pwd;',...
'try',...
'    cd(rootpath)',...
'    % Check that the required initialisation and removal functions exist in rootpath',...
'    if exist(fullfile(pwd,[app_name,''_init.m'']),''file'')',...
'        feval([app_name,''_init''],varargin{:})    % call initialisation routine',...
'    else',...
'        warning(''Initialisation function "%s_init.m" not found in directory "%s"'',app_name,rootpath)',...
'    end',...
'    cd(start_dir)',...
'    mess='''';',...
'catch ',...
'    cd(start_dir)',...
'    message=lasterr; % kept lasterr for backward compartibility',...
'    mess=[''Problems initialising '',app_name,'' Reason: '',message];',...
'end',...
'',...
'%=========================================================================================================',...
'function application_off(app_name,varargin)',...
'% Remove paths to all instances of the application.',...
'% if varargin present, no messages that aplication is not present is given',...
'',...
'start_dir=pwd;',...
'',...
'% Determine the rootpaths of any instances of the application by looking for app_name on the matlab path',...
'application_init_old = which([app_name,''_init''],''-all'');',...
'',...
'for i=1:numel(application_init_old)',...
'    try',...
'        rootpath=fileparts(application_init_old{i});',...
'        cd(rootpath)',...
'        if exist(fullfile(pwd,[app_name,''_off.m'']),''file'') % check that ''off'' routine exists in the particular rootpath',...
'            try',...
'                feval([app_name,''_off''])    % call the ''off'' routine',...
'            catch',...
'                if(nargin<2)',...
'					disp([''Unable to run function '',app_name,''_off.m''])',...
'				end',...
'            end',...
'        else',...
'            disp([''Function '',app_name,''_off.m not found in '',rootpath])',...
'            disp(''Clearing rootpath and subdirectories from matlab path in any case'')',...
'        end',...
'        paths = genpath(rootpath);',...
'        warn_state=warning(''off'',''all'');    % turn of warnings (so don''t get errors if remove non-existent paths)',...
'        rmpath(paths);',...
'        warning(warn_state);    % return warnings to initial state',...
'        cd(start_dir)           % return to starting directory',...
'    catch',...
'        cd(start_dir)           % return to starting directory',...
'        disp([''Problems removing '',rootpath,'' and any sub-directories from matlab path'']);',...
'    end',...
'end',...
' '...    
};
switch lower(package)
    case 'libisis'
        save_var_vile('libisis_on.mt',libisis_on,path);
    case 'horace'
        save_var_vile('horace_on.mt',horace_on,path);
    case 'mslice'
        save_var_vile('mslice_on.mt',mslice_on,path);        
    case 'start_app'
        save_var_vile('start_app.m',start_app,path);                
    otherwise
       error('install_isis:create_pack_on_teplate:wrong_arguments','unknown name %s. Four names are recognazed: start_app,mslice,horace or libisis ',package)
end


function save_var_vile(f_name,contents,path)
if ~exist('path','var')
    path=pwd;
end

f_name=fullfile(path,f_name);
fout = fopen(f_name,'w');
for i=1:numel(contents)
    fprintf(fout,'%s\n',contents{i});    
end
fclose(fout);

