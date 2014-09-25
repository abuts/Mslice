function [ok,mess] = mcopy_and_rename(input_file,output_path,output_name)
% function used to copy a matlab function as ascii file into other location
% and replacing its name by other name + all instnces of the name in the
% file (e.g. function name or class name for classdef ) by new name.
%
%Usage:
%
%>>mcopy_and_rename(input_file, output_path,output_name)
%where:
% input_file -- input (full or availible file name)
% output_path -- path to place file to
% output_name -- output function and file name
%
% if invoked without output arguments, errors are thrown, if with, errors
% reported in the output arguments
%
%   $Rev: 288 $ ($Date: 2014-04-05 21:48:22 +0100 (Sat, 05 Apr 2014) $)
%
%  23/09/2014 first very ineffective version, which would replace substring
%  multiple times if the source is a substing of the target

ok = true;
if nargout>0
    throw_error=false;
else
    throw_error=true;
end

fs=fopen(input_file,'r');
if fs<0
    err_message=sprintf('Can not open file %s to read data',input_file);
    mess=on_error(throw_error,err_message);
    ok = false;
    return;
end
[in_path,in_file,ext]=fileparts(input_file);

[out_path,out_file,out_ext] = fileparts(output_name);
out_full_file=fullfile(output_path,[out_file,out_ext]);

ft=fopen(out_full_file,'w');
if(ft<0)
    err_message=sprintf('Can not open target file %s to write data',out_full_file);
    mess=on_error(throw_error,err_message);
    ok = false;
    return;
end
co=onCleanup(@()fclose(ft));


line = fgets(fs);
while ischar(line)
    places=strfind(line,in_file);
    if numel(places)>0
        nElements=numel(in_file);
        for i=1:numel(places)
            line = [line(1:places(i)-1),out_file,line(places(i)+nElements:end)];            
        end
    end
    fprintf(ft,'%s',line);
    line=fgets(fs);
end
fclose(fs);



function message=on_error(throw_error,err_message)
if throw_error
    error('MCOPY_AND_RENAME:error',err_message);
else
    message=['MCOPY_AND_RENAME:error',err_message];
end

