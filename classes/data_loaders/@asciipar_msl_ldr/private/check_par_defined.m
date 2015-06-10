function fields = check_par_defined(this)
% method checks what fields in the structure are defined from the fields
% the par file should define.
%
% $Revision: 338 $ ($Date: 2014-01-17 14:35:43 +0000 (Fri, 17 Jan 2014) $)
%

df = this.par_can_define();
if ~isempty(this.par_file_name)
    fields  = df;   
else
    % find the fields which are defined by the file structure. 
    is_def = @(field)(is_field_def(this,field));
    def_fiels = cellfun(is_def,df);
    fields    = df(def_fiels);       
end


function is=is_field_def(struct,field)
    is = true;
    if isempty(struct.(field))
        is = false;
    end
