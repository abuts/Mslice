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
            %             fc=funcCopier('test');
            %             fc.files_2copy_list =struct();
            %             testFile = fullfile(this.out_folder,'test_save_restore_list_file.txt');
            %             fc.files_2copy_list.fun1=struct('fname','fun1','checksum',256,'source','here1','dest','there1','copy',false,'modified',false);
            %             fc.files_2copy_list.fun2=struct('fname','fun2','checksum',326,'source','here2','dest','there2','copy',false,'modified',false);
            %             fc.files_2copy_list.fun3=struct('fname','fun3','checksum',26,'source','here3','dest','there4','copy',false,'fext','.ss','modified',false);
            %
            %             fc.save_list(testFile);
            %
            %             fc1=funcCopier('test');
            %             fc1=fc1.load_list(testFile);
            %             keys = fieldnames(fc1.files_2copy_list);
            %
            %             nStrings = numel(keys);
            %             for i=1:nStrings
            %                 key = keys{i};
            %                 assertEqual(fc.files_2copy_list.(key),fc1.files_2copy_list.(key ));
            %             end
            %             if exist(testFile,'file')
            %                 delete(testFile);
            %             end
        end
        function tearDown(this)
            source_dest.instance().set_defaults();
        end
        
        function test_add_hfun(this)
            
            fc=funcCopier('test');
            fc.mslice_folder = this.out_folder;
            fc.herbert_folder = fileparts(mfilename('fullpath'));
            test_target='ttt_folder';
            
            
            fc=fc.add_dependency('test_funcCopier.m',test_target);
            
            assertTrue(isfield(fc.files_2copy_list,'test_funcCopier_m'));
            data2copy= fc.files_2copy_list.test_funcCopier_m;
            assertEqual(test_target,data2copy.short_dest_path);
            
            target_folder = fullfile(fc.mslice_folder,test_target);
            file = fullfile(target_folder,'test_funcCopier.m');
            
            cl1 = onCleanup(@()rmdir(target_folder,'s'));
            fc.copy_dependencies();
            
            assertTrue(exist(target_folder,'dir')==7);            
            assertTrue(exist(file,'file')==2);
        end
        
        function test_add_hfolder(this)

            
            fc=funcCopier('test');
            fc.mslice_folder = this.out_folder;
            fc.herbert_folder = fileparts(mfilename('fullpath'));
            fc.herbert_folder = fileparts(fc.herbert_folder);
            test_target='ttt_folder';
            target_folder = fullfile(this.out_folder,test_target);
            
            fc=fc.add_dependency('test_herbert_IO',test_target);
            
            assertTrue(isfield(fc.files_2copy_list,'atest_herbert_IO_MAP11014_nxspe'));
            descriptor = fc.files_2copy_list.atest_herbert_IO_MAP11014_nxspe;
            %assertEqual(test_target,descriptor.dest);
            assertEqual('MAP11014',descriptor.dest_name);
            assertEqual('MAP11014.nxspe',descriptor.dest_fname);
            
            cl = onCleanup(@()rmdir(target_folder,'s'));
            
            fc.copy_dependencies();
            
            file = fullfile(descriptor.dest_path,'MAP11014.nxspe');
            assertTrue(exist(file,'file')==2);
        end
        
        %
    end
    
end
