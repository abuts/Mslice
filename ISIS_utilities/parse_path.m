function my_path=parse_path(in_path)
% function interprites symbols like ./ and ../ and their combinations
% in the input path in_path, removes them and calculates file path according to DOS or
% Unix rules to process  symbols ./ and ../;
%
% Usage:
% my_path=parse_path(in_path);
%
% If the input path starts from / or ./ or ../, the function adds path to current
% working directory to the path specified as input argument.
% If it does not start from these symbols,
% the function assumes that you have specified the full path and works with it
%
% function does not check if the resulting path exists
% It returns error if the resulting path points above the root directory
% e.g. c:/windows/../../Documents -> points to /Documents which is wrong
% for Windows
% @bug  (feature?) does not process root path properly under Unix,
%       if you specify root path, it interprets it as a relative path and
%       adds working directory path to it.
%
% Written by: Alex Buts 27/08/2009
%
% Libisis:
% $Revision$ ($Date$)

dirs = regexp(in_path,'[\/\\]','split');

if( size(dirs)==0);
    my_path='';
    return;
end

if(strcmp(dirs{1},'.')||strcmp(dirs{1},'..'))
    root_path=regexp(pwd,'[\/\\]','split');
    dirs = [root_path,dirs];
end
% find the length of the real path
path_length=0;
for i=1:length(dirs)
    if(strcmp(dirs{i},'.'))
        continue
    elseif(strcmp(dirs{i},''))
        continue
    elseif(strcmp(dirs{i},'..'))
        path_length=path_length-1;
        if(path_length<=0)
            error(' parse_path => wrong path; path %s points above the root folder',in_path)
        end
        continue
    else
        path_length=path_length+1;
    end
    dirs(path_length)=dirs(i);  % compress the directories;
end


my_path = join(filesep,dirs,path_length);
if(~strncmp(computer,'PC',2)) % linux root folder -- separate treatment
    if(my_path(1)~='/')
        my_path=['/',my_path];
    end
end


end
%%
function joined=join(sep,array,length)
% functions glues array into a string with separator sep between words
% should work similarly to Perl join

joined = array{1};
for i=2:length
    joined=[joined sep array{i}];
end

end
