function S = parse_set (this,varargin)
% Check arguments are valid for set methods. Throws an error if a field is not valid or is sealed.
%
%   >> S = parse_set (config_obj, field1, val1, field2, val2, ...)
%   >> S = parse_set (config_obj, struct)
%   >> S = parse_set (config_obj, cellnam, cellval) % cell arrays of field names and values
%   >> S = parse_set (config_obj, cellarray)        % cell array has the form {field1,val1,field2,val2,...}
%
%   >> S = parse_set (config_obj)                   % returns current values
%   >> S = parse_set (config_obj, 'defaults')       % returns default values
%
% For any of the above:
%   >> S = parse_set (config_obj,...)
%
% Input:
% ------
%   config_obj  Configuration object 
%
% Output:
% -------
%   S           Structure whose fields and values are those to be changed
%               in the configuration object
% 
% EXAMPLES:
%   >> S = parse_set (my_config,'a',10,'b','something')
%
%   >> S = parse_set (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% This method is designed for use in custom set methods. See the example in test2_config

% $Revision$ ($Date$)

S = parse_set_internal (this, false, varargin{:});
