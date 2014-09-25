function is = find_if_isfolder_class( this )
%private method analyses the path and checks if the file is a
%folder-located class def
%
is = false;

fpath = this.source_path_;
if isempty(fpath)
    return;
end

fname = this.source_name_;
if isempty(fname)
     return;
end

[big_path,dir_name]=fileparts(fpath);
if dir_name(1) == '@'
    if strcmp(fname,dir_name(2:end))
        is = true;
    end
end



