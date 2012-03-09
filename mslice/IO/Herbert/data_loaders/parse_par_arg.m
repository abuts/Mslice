function [file_name,file_format]= parse_par_arg(old_file_name,varargin)
% function verifies if input parameters present in varargin redefine the filename correctly 
%
% It is a private function used by load_par methods of all data loaders, which
% helps these methods to identify if the method should return result as the
% horace structure and if the input filename have been redefined in input
% parameters;
%
file_name=old_file_name;
file_format='';

if nargin == 1;    return;
end
%
if nargin>1
   if ~ischar(varargin{1})
       error('PARSE_PAR_ARG:invalid_argument','first argument has to be either file name or a symbol parameter -hor');
   end
   if strncmpi(varargin{1},'-hor',4) 
       file_format='-hor';
       return;
   else
       file_name=varargin{1};
       if nargin==3
            if ~strncmpi(varargin{2},'-hor',4) 
                warning('PARSE_PAR_ARG:invalid_argument',' third argument, if present, has to be the key -hor, assuming -hor');
            end
            file_format='-hor';
       end
   end
end


