function summm = calc_checksum(filename)
% function calculates checksum of a file by summing all
% non-space ascii character codes in the file
%
% It also omits the srting where svn keyword Revision can be found;
%
%
% $Revision$ ($Date$)
%

fileID = fopen(filename,'r');
if fileID<0
    error('CALC_CHECKSUM:open_file','Can not open file %s: ',filename);
end
warn = warning('off','MATLAB:strrep:InvalidInputType');
summm = 0;
line = 0;
while(line>-1)
    line = fgetl(fileID);    
    line = strrep(line,' ','');
    if isempty(line)
        line=0;
        continue;
    end
    
    if line(1) == '%'
        if strncmp('%$Revision:',line,11)
            line = fgetl(fileID);
            continue;
        end
    end
    summm = summm+sum(line);
end
fclose(fileID);
warning(warn);
