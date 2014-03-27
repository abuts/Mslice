classdef funcCopier
    %Class to copy specified dependent functions/methods from Herbert to
    % mslice
    %
    %
    %   $Rev: 268 $ ($Date: 2014-03-13 14:11:31 +0000 (Thu, 13 Mar 2014) $)
    %
    
    
    properties
        mslice_folder;
        herbert_folder;
        files_2copy_list;
    end
    
    methods
        function obj=funcCopier()
        end
        function this= init(this)
            obj.mslice_folder= fileparts(which('mslice_init'));
            obj.herbert_folder= fileparts(which('herbert_init'));
            if isempty(obj.mslice_folder) || isempty(obj.herbert_folder)
                error('FUNC_COPIED:constructor',...
                    'both herbert and mslice have to be on a data search path for this class to work');
            end
            obj.files_2copy_list = containers.Map;
        end
        function save_list(this,filename)
            nStrings = this.files_2copy_list.Count;
            if nStrings==0; return ;   end
            
            fh=fopen(filename,'w+');
            if fh<0; error('FUNC_COPIER:save_list',' can not open file %s to write data',filename); end
            fprintf(fh,'func_name;checksum; herbert_path; mslice_path\n');
            func_names = this.files_2copy_list.keys;
            for i=1:nStrings
                func = func_names{i};
                data2save = this.files_2copy_list(func);
                fprintf(fh,'%s;%d;%s;%s\n',func,data2save{1},data2save{2},data2save{3});
            end
            fclose(fh);
        end
        function this=load_list(this,filename)
            fh=fopen(filename,'r');
            if fh<0; error('FUNC_COPIER:save_list',' can not open file %s to read data',filename); end
            
            this.files_2copy_list = containers.Map;
            % scip header
            fgetl(fh);
            line = fgetl(fh);
            while ischar(line)
                rez = strsplit(line,';');
                rez{2} = str2double(rez{2});
                this.files_2copy_list(rez{1})=rez(2:end);
                line=fgetl(fh);
            end
            fclose(fh);            
        end
    end
    
end

