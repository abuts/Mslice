classdef test_checksum<TestCase
    %Test func copier functionality
    
    properties
        out_folder;
    end
    
    methods
        function this = test_checksum(name)
            this= this@TestCase(name);
            this.out_folder = tempdir();
        end
        
        
        function test_calc_checksum(this)
            source_file = 'source_1_test.m';
            
            hash=calc_checksum(source_file);
            assertEqual(int32(619497790),hash);
            
            
%             %fields = {'mslice_config','use_mex'}; %funcCopier.fieldsModified();
%             [hash,changes_present]=calc_checksum(source_file);
%             
%             assertTrue(changes_present);
%             assertEqual(8990,sum);
            
            
            
        end
        
        
        function test_check_for_changes(this)
            
        end
    end
end