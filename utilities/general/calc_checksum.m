function shash = calc_checksum(source,varargin)
% function calculates checksum of a file by summing all
% non-space ascii character codes in the file
%
%>>summ = calc_checksum(source,);
%
%>>[summ,changes_present] = calc_checksum(source,'S')
%
% source      -- the name of the file to process if no 'S' provided or 
%                the string to hash if it is. 

% 
%
%Returns:
% shash       -- hash  of the data string or the data in the file provided
%
%
% When reading from file, it also omits the srting where svn keyword Revision can be found;
%
%
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%
%


if nargin == 1
    fileID = fopen(source,'r');
    if fileID<0
        error('CALC_CHECKSUM:open_file','Can not open file %s: ',source);
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
else
    S = source;
end
hash = string2hash(S,'djb2');
shash = int64(hash+numel(S));

% return;



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



