function this = set_consistent_array(this,field_name,value)
% set consistent data array
% and break connection between the class and data file -- currently
% disabled
%
%
% $Revision$ ($Date$)
%

if isempty(value)
    if isempty(this.file_name)
        this=this.delete();
    else
        this.S_stor=[];
        this.ERR_stor=[];
    end
    return
end

this.(field_name) = value;
%this.data_file_name_stor = '';

if ~strcmp(field_name,'en_stor')
    this.n_detindata_stor = size(value,2);
end

