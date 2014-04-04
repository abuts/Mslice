function [summm,changes_present] = calc_checksum(filename,varargin)
% function calculates checksum of a file by summing all
% non-space ascii character codes in the file
%
%>>summ = calc_checksum(filename);
%
%>>[summ,changes_present] = calc_checksum(filename,check_changes)
%
% filename      -- the name of the file to process
% check_changes -- if present, excludes number of specific rows which 
%                  changes when copying from Herbert to Mslice (e.g. 
%                  mslice_config instead of herbert_config)
%
%Returns:
% summ            -- sum of bytes in the file
% changes_present -- if checked indicates that the rows which need to be
%                    replaced moving from Herbert to Mslice are present in
%                    the file
%
%
% It also omits the srting where svn keyword Revision can be found;
%
%
%
% $Revision$ ($Date$)
%
%
if nargin>1
    check_changes=varargin{1};
else
    check_changes=false;
end
changes_present=false;
changes_to_check = funcCopier.fieldsToModify();

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
            continue;
        end
    end
    if check_changes
        contin=false;
        for i=1:numel(changes_to_check)
            if ~isempty(strfind(line,changes_to_check{i}))
                contin=true;
                changes_present = true;              
                break;                
            end
        end
        if contin
            continue;
        end
    end
    summm = summm+sum(line);
end
fclose(fileID);
warning(warn);
