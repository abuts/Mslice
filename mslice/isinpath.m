function flag=isinpath(directory)

% function flag=isinpath
if isempty(directory)|~ischar(directory),
   disp(['Input parameter for function isinpath has to be a directory name']);
   flag=[];
   help isinpath;
   return;
end

n=length(directory);
fs=filesep;
if strcmp(directory(n),fs)
   directory=directory(1:(n-1));
end
ps = pathsep;
flag=~isempty(findstr([path,ps],[directory, ps]));

