function key_name = get_key_name(this)
% get the string, which uniquely describes funcion within a package and
% consists of a function name and partial function path.
key_name = build_key_name(this.short_source_path,this.source_name);
end

function func_name = build_key_name(source_path,fname)
% function takes the path and function name provided as
% input arguments and generates form them the string
% which can be used as valid field name of a matlab structure.
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