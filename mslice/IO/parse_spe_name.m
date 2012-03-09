%==========================================================================================
function [filename1,filename2,ebar_opt]=parse_spe_name (string)
% Determine if file has form <path>diff(<file1>,<file2>) or <path>diff(<file1>,<file2>,ebar_opt)
% Used in the generalisation of load_spe to enable differnece between two spe files to be read
% 
%   >> [filename1,filename2,ebar_opt]=parse_spe_name (string)
%
%   If does not have the form <path>diff(<file1>,<file2>) or <path>diff(<file1>,<file2>,ebar_opt)
%  then f1 is returned as the input string, and f2 and ebar_opt are left blank
%
% e.g. 'c:\temp\diff(hello.spe,there.spe)' => 
%   f1='c:\temp\hello.spe', f2='c:\temp\there.spe', ebar_opt=[]
%
% e.g. '\diff('c:\temp\hello.spe,'d:\blobby\there.spe,[1,0])' => 
%   f1='c:\temp\hello.spe', f2='d:\blobby\there.spe', ebar_opt=[1,0]
%
%
% T.G.perring April 2008

k=strfind(lower(string),'diff(');
if ~isempty(k)  % assume must have the form suitable for file differencing
    try
        if k~=1
            filepath=string(1:k-1);
        else
            filepath='';
        end
        string=string(k+5:end-1);   % strip out the contents of diff(...)
        k=strfind(string,',');
        if length(k)==1 % no ebar_opt
            filename1=[filepath,string(1:k-1)];
            filename2=[filepath,string(k+1:end)];
            ebar_opt=[];
        else    % *MUST* have ebar_opt if format is correct
            filename1=[filepath,string(1:k(1)-1)];
            filename2=[filepath,string(k(1)+1:k(2)-1)];
            ebar_opt=str2num(string(k(2)+1:end));
        end
    catch
        filename1=string;
        filename2='';
        ebar_opt=[];
    end
else
    filename1=string;
    filename2='';
    ebar_opt=[];
end
