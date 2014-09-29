function key_name = get_key_name(this)
% get the string, which uniquely describes funcion within a package 


string = remove_os_dependency(this.short_source_path,this.source_name);
chksum = calc_checksum(string,'S');
key_name = ['k', num2str(chksum,'%lu')];
%build_key_name(this.short_source_path,this.source_name);
end

function func_name = remove_os_dependency(source_path,fname)
% function takes the path and function name provided as
% input arguments and generates form them the string
% which is OS independent to use as 
%
func_name = fullfile(source_path,fname);
if ispc
    func_name = regexprep(func_name,'[\\,@,\.]','_');
else
    func_name = regexprep(func_name,'[/,@,\.]','_');
end
if func_name(1)=='_'
    func_name(1)='a';
end
end