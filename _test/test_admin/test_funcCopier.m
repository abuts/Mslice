classdef test_funcCopier<TestCase
    %Test func copier functionality
    
    properties
        out_folder;
    end
    
    methods
        function this = test_funcCopier(name)
            this= this@TestCase(name);
            this.out_folder = tempdir();
        end
        
        function test_save_restore_list(this)
            fc=funcCopier();
            fc.files_2copy_list = containers.Map;
            testFile = fullfile(this.out_folder,'test_save_restore_list_file.txt');
            fc.files_2copy_list('fun1.m')={256,'here1','there1'};
            fc.files_2copy_list('fun2.m')={326,'here2','there2'};            
            fc.save_list(testFile);
            
            fc1=funcCopier();
            fc1=fc1.load_list(testFile);
            nStrings = fc1.files_2copy_list.Count;
            keys = fc1.files_2copy_list.keys;
            for i=1:nStrings
                key = keys{i};
                assertEqual(fc.files_2copy_list(key),fc1.files_2copy_list(key ));
            end
            if exist(testFile,'file')
                delete(testFile);
            end
        end
        
        function test_add_hfun(this)
            %works only if herbert is 
        end
        
    end
    
end

