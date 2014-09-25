function shash = calc_checksum(filename)
% function calculates checksum of a file by summing all
% non-space ascii character codes in the file
%
%>>summ = calc_checksum(filename);
%
%>>[summ,changes_present] = calc_checksum(filename,cnanges_to_check)
%
% filename      -- the name of the file to process
% cnanges_to_check -- cell-array of specific rows which should be ignored
%                     when the check sum is calculated
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



fileID = fopen(filename,'r');
if fileID<0
    error('CALC_CHECKSUM:open_file','Can not open file %s: ',filename);
end
S=fscanf(fileID,'%s');
fclose(fileID);
S=strrep(S,' ','');
% remove subversion contents
irev = strfind(S,'%$Revision:');
if ~isempty(irev)
    revStr = S(irev(1):irev(1)+61);
    S=strrep(S,revStr,'');
end
hash = string2hash(S);
shash = int32(hash);








function hash=string2hash(str,type)
% This function generates a hash value from a text string
%
% hash=string2hash(str,type);
%
% inputs,
%   str : The text string, or array with text strings.
% outputs,
%   hash : The hash value, integer value between 0 and 2^16-1
%   type : Type of has 'djb2' (default) or 'sdbm'
%
% From c-code on : http://www.cse.yorku.ca/~oz/hash.html 
%
% djb2
%  this algorithm was first reported by dan bernstein many years ago 
%  in comp.lang.c
%
% sdbm
%  this algorithm was created for sdbm (a public-domain reimplementation of
%  ndbm) database library. it was found to do well in scrambling bits, 
%  causing better distribution of the keys and fewer splits. it also happens
%  to be a good general hashing function with good distribution.
%
% example,
%
%  hash=string2hash('hello world');
%  disp(hash);
%
% Function is written by D.Kroon University of Twente (June 2010)


% From string to double array
str=double(str);
if(nargin<2), type='djb2'; end
switch(type)
    case 'djb2'
        hash = 5381*ones(size(str,1),1); 
        for i=1:size(str,2), 
            hash = mod(hash * 33 + str(:,i), 2^32-1); 
        end
    case 'sdbm'
        hash = zeros(size(str,1),1);
        for i=1:size(str,2), 
            hash = mod(hash * 65599 + str(:,i), 2^32-1);
        end
    otherwise
        error('string_hash:inputs','unknown type');
end


