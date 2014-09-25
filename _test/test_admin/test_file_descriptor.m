classdef test_file_descriptor<TestCase
    %Test func copier functionality
    
    properties
        out_folder;
        test_folder;
    end
    
    methods
        function this = test_file_descriptor(varargin)
            if nargin>0
                name=varargin{1};
            else
                name= mfilename('class');
            end
            this= this@TestCase(name);
            
            this.out_folder = tempdir();
            this.test_folder=fileparts(which(mfilename('class')));
            source_dest.instance().set_defaults();
        end
        
        function this=test_constructor(this)
            fd = file_descriptor();
            
            assertEqual(fd.target_fname,'.m');
            assertEqual(fd.checksum,int32(0));
            
            %
            mpath = fileparts(which('mslice_init.m'));
            assertEqual(fd.dest_path,mpath);
            assertTrue(isempty(fd.short_dest_path));
            
            hpath = fd.root_source_path();
            assertEqual(fd.source_path,hpath);
            assertTrue(isempty(fd.short_source_path));
            
        end
        function this = test_is_modified(this)
            fd=from_string(file_descriptor,'source_1_test;666;_test/test_admin;0;_test/test_admin;;0;');
            
            [mod,changed,fd_new]=is_modified(fd);
            assertTrue(mod);
            assertTrue(changed);
            
            new_chksum = fd_new.checksum;
            fd1=from_string(file_descriptor,sprintf('source_1_test;%lu;_test/test_admin;0;_test/test_admin;;0;',new_chksum));
            [mod,changed,the_chksum]=is_modified(fd1);
            assertTrue(~mod);
            assertTrue(~changed);
            assertEqual(the_chksum.checksum,new_chksum);
            
        end
        
        
        function this=test_copy_and_modify(this)
            fd= from_string(file_descriptor_tester,'source_1_test;619497790;_test/test_admin;0;-;;0;');
            
            [copy_source,store_dest]=is_modified(fd);
            assertTrue(copy_source);
            assertTrue(~store_dest);
            
            targ_file = fullfile(fd.dest_path,fd.target_fname);
            cl1 = onCleanup(@()delete(targ_file));
            
            fd=fd.copy_and_modify();
            assertEqual(exist(targ_file,'file'),2);
            %
            summm0 = calc_checksum(targ_file);
            assertEqual(fd.checksum,summm0);
            assertEqual(fd.targ_checksum,summm0);
            
            % modified file name
            fd.target_name = 'other_file_name';
            targ_file1 = fullfile(fd.dest_path,fd.target_fname);
            cl1 = onCleanup(@()delete(targ_file1));
            
            fd=fd.copy_and_modify();
            assertEqual(exist(targ_file1,'file'),2);
            
            summm = calc_checksum(targ_file1);
            assertEqual(fd.checksum,summm0);
            assertEqual(summm,int32(2147483647));
            assertEqual(fd.targ_checksum,summm);
            
            % set fields to moidfy
            fd=fd.add_modifiers('mslice_config','other_c');
            fd.target_name = 'other_file_name';
            targ_file2 = fullfile(fd.dest_path,fd.target_fname);
            cl1 = onCleanup(@()delete(targ_file2));
            
            fd=fd.copy_and_modify();
            assertEqual(exist(targ_file2,'file'),2);
            
            summm = calc_checksum(targ_file2);
            assertEqual(summm,int32(547790443));
            assertEqual(fd.targ_checksum,summm);
            
            % set the same name as initial source file
            fd.target_name = '';
            targ_file = fullfile(fd.dest_path,fd.target_fname);            
            cl1 = onCleanup(@()delete(targ_file));
            
            fd=fd.copy_and_modify();
            assertEqual(exist(targ_file,'file'),2);
            
            summm = calc_checksum(targ_file);
            assertEqual(fd.checksum,summm0);
            assertEqual(summm,int32(1504720576));
            assertEqual(fd.targ_checksum,summm);
            
            [source_changed,dest_changed]=is_modified(fd);
            assertTrue(~source_changed);
            assertTrue(~dest_changed);
            
            cl2 = onCleanup(@()rmdir(fd.dest_path,'s'));
        end
        
        function this = test_serialize_deserealize(this)
            her_path=file_descriptor.root_source_path();
            source = fullfile(her_path,'_test/test_admin','source_1_test.m');
            
            fd = file_descriptor(source);
            
            assertEqual(fd.source_name,'source_1_test.m');
            assertEqual(fd.checksum,int32(787349746));
            assertEqual(fd.short_source_path,['_test',filesep,'test_admin']);
            assertEqual(fd.short_dest_path,['_test',filesep,'test_admin']);
            
            
            
            [copy_source,store_dest]=is_modified(fd);
            assertTrue(~copy_source)
            assertTrue(~store_dest)
            
            str = fd.to_string();
            assertEqual(str,'source_1_test;787349746;_test\test_admin;0;_test\test_admin;;;.m');
            
            fd1=from_string(file_descriptor,str);
            [ok,mess]=equal_to_tol(fd,fd1);
            assertTrue(ok,mess);
            
            fd2= from_string(file_descriptor_tester,'source_1_test;619497790;_test\test_admin;0;;;;.m');
            [copy_source,store_dest]=is_modified(fd2);
            assertTrue(copy_source)
            assertTrue(~store_dest)
            
            % set fields to moidfy
            fd2=fd2.add_modifiers('mslice_config','other_c');
            str = fd2.to_string();
            assertEqual(str,'source_1_test;619497790;_test\test_admin;0;;;;.m;1;mslice_config;other_c');
            fd2r = from_string(file_descriptor_tester,str);
            [ok,mess]=equal_to_tol(fd2,fd2r);
            assertTrue(ok,mess);
            
            
            tfolder = fileparts(fd2.short_dest_path);
            cl1 = onCleanup(@()rmdir(fullfile(fd2.root_dest_path,tfolder),'s'));
            
            fd3=fd2.copy_and_modify();
            [copy_source,store_dest]=is_modified(fd3);
            assertTrue(~copy_source)
            assertTrue(~store_dest)
            
            str = fd3.to_string();
            assertEqual(str,'source_1_test;619497790;_test\test_admin;0;;;1504720576;.m;1;mslice_config;other_c');
        end
        
        function test_is_folder_class(this)
            fd=file_descriptor_tester();
            assertTrue(~fd.is_folder_class);
            
            fd.source_name='source_1_test.m';
            assertTrue(~fd.is_folder_class);
            
            folder = this.test_folder;
            fd.source_name=fullfile(folder,'@source_2_tester','source_2_tester.m');
            assertTrue(fd.is_folder_class);
            
        end
        
        function test_class_update(this)
            fd=file_descriptor_tester('source_1_test.m');
            
            tfolder = fileparts(fd.short_dest_path);
            cl1 = onCleanup(@()rmdir(fullfile(fd.root_dest_path,tfolder),'s'));
            
            fd1=fd.copy_and_modify();
            assertEqual(fd,fd1);
            
            fd=file_descriptor_tester();
            
            folder = this.test_folder;            
            fd.source_name=fullfile(folder,'@source_2_tester','source_2_tester.m');            
            
            cl1 = onCleanup(@()rmdir(fullfile(fd.root_dest_path,'_test'),'s'));
            fd1=fd.copy_and_modify();            
            assertEqual(exist(fullfile(fd1.dest_path,fd1.target_fname),'file'),2)
            assertTrue(fd1.checksum==fd1.targ_checksum);            
            
            % check renaming
            fd.target_name = 'other_1class_name';
            [folder_path,folder_name] = fileparts(fd.dest_path);
            assertEqual(folder_name,'@other_1class_name');
            
            cl1 = onCleanup(@()rmdir(fullfile(fd.root_dest_path,'_test'),'s'));
            fd1=fd.copy_and_modify();            
            assertEqual(exist(fullfile(fd1.dest_path,fd1.target_fname),'file'),2)
            assertTrue(fd1.checksum~=fd1.targ_checksum);
            
        end
        function test_fieldnames_to_write(this)
            fields = file_descriptor().get_fieldnames_to_write();
            assertEqual(8,numel(fields));
        end
    end
end

