classdef test_mcopy_and_rename<TestCase
    %Test mcopy_and_remame functionality
    
    properties
        out_folder;
    end
    
    methods
        function this = test_mcopy_and_rename(varargin)
            if nargin>0
                name=varargin{1};
            else
                name= mfilename('class');
            end
            this= this@TestCase(name);
            
            this.out_folder = tempdir();
        end
        function text=build_testfun_text(this,filename)
            
            [fp,fname,ext] = fileparts(filename);
            
            text = [sprintf('function rez=%s(a,b,c)\n',fname),...
                sprintf('# a Comment\n'),...
                sprintf('# b Comment\n'),...
                sprintf('a=b+c\n'),...
                sprintf('something else %s\n',fname),...
                sprintf('aaaa \n'),...
                sprintf('classfef %s<bla_bla\n',fname),...
                sprintf('end\n\n')];
        end
        function clean_result(this,filename)
            
            fclose all;   
            if exist(filename,'file')
                delete(filename);
            end
        end
        
        function test_mcopy(this)
            source_filename = 'testfun.m';
            targ_filename = 'festfun_msl.m';
            
            source = this.build_testfun_text(source_filename);
            target = this.build_testfun_text(targ_filename);
            
            targ_file =  fullfile(this.out_folder,targ_filename);
            source_file = fullfile(this.out_folder,source_filename);
            
            fh = fopen(source_file,'w');
            
            cl1 = onCleanup(@()clean_result(this,source_file));
            fwrite(fh,source);
            fclose(fh);
            
            mcopy_and_rename(source_file,this.out_folder,targ_filename);
            
            assertEqual(2,exist(targ_file,'file'));
%            
            fh1=fopen(targ_file,'r');
            cl2 = onCleanup(@()clean_result(this,targ_file));
            
            rez  = '';
            line = fgets(fh1);
            while ischar(line)
                rez=[rez,line];
                line=fgets(fh1);                
            end
            fclose(fh1);
            
            assertEqual(rez,target);
        end
        
        
    end
    
end

