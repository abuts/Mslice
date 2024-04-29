function this = build_short_dest_path(this,path)
% Build target path within the target folder

%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%

root_path = this.root_dest_path();
% remove root path from short path if it is there;
path = strrep(path,root_path,'');

if this.is_folder_class
    % for folder class folder should have the name of the class with @ sign.
    classname = this.dest_name;
    [rest_path,class_path]=fileparts(path);
    if class_path(1) ~= '@'
        path = fullfile(path,['@',classname]);
    else
        path = fullfile(rest_path,['@',classname]);
    end
else % just assign partial path.
end
if numel(path)==1 
    if path =='-'
        this.dest_path_ = '-';
        return;
    end
end
if strcmp(path,this.source_path_)
    this.dest_path_='';
else
    this.dest_path_=path;
end





