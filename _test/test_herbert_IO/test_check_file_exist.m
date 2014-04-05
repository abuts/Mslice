classdef test_check_file_exist<TestCase
    %   Detailed explanation goes here
    
    properties
        test_file_name='test_file.txt';
    end
    
    methods
        function this=test_check_file_exist(name)
            this = this@TestCase(name);
        end
       
        function test_fileexist(this)
            return
            
            fileID = fopen(this.test_file_name,'w');
            fwrite(fileID,this.test_file_name);
            fclose(fileID);
            
            assertEqual(this.test_file_name,check_file_existence(this.test_file_name,'.txt','dir_field','file_field',false));
            delete(this.test_file_name);
            assertEqual('absent_file.txt',check_file_existence('absent_file.txt','.txt','dir_field','file_field',true));
            
            
        end
        %
    end
    
end

