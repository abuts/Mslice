function this=build_from_file(this,filename)
%
if ~exist(filename,'file')
    error('FILE_DESCRIPTOR:invalid_argument',' File %s does not exist ',filename);
end

[path,name,ext]=fileparts(filename);

this.source_name_ = name;
if ~isempty(ext)
    this.fext_ = ext;
else
    filename = [filename,this.fext_];
end


if isempty(path)
    path = fileparts(which(filename));
else
    
end
if ispc
    path = lower(path);
end

hpath = this.root_source_path();
path = strrep(path,hpath,'');

this.source_path_ = path;

% set provisional destination path equal to source path relative to
% different root
this.dest_path_=path;
t_dest_path = this.dest_path;
if ~exist(t_dest_path,'dir')
    this.dest_path_='';
end

this.is_folder_class_ = find_if_isfolder_class(this);
this.checksum_ = calc_checksum(filename);

