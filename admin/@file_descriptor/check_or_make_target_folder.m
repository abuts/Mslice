function check_or_make_target_folder(this,dir_name)
% make target path recursively;

if ~exist(dir_name,'dir')==7
    mkdir(dir_name);
end

