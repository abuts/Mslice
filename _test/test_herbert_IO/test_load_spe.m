classdef test_load_spe<TestCase
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this=test_load_spe(name)
            this = this@TestCase(name);
        end
        function test_parse_spe1nme(this)
            fname='file1';
            [fnp,f2,ebar]  = parse_spe_name(fname);
            assertEqual(fname,fnp);
            assertTrue(isempty(f2));
            assertTrue(isempty(ebar));
        end
        function test_parse_spe2name(this)
            fname='file1';
            fname2='file2';
            [f1,f2,ebar]  = parse_spe_name(['diff(',fname,',',fname2,')']);
            assertEqual(fname,f1);
            assertEqual(fname2,f2);
            assertTrue(isempty(ebar));
        end
        function test_parse_path_nix(this)
            fname='file1';
            fname2='file2';
            path ='/home/user/';
            [f1,f2,ebar]  = parse_spe_name([path,'diff(',fname,',',fname2,')']);
            assertEqual([path,fname],f1);
            assertEqual([path,fname2],f2);
            assertTrue(isempty(ebar));
        end
        function test_parse_path_win(this)
            fname='file1';
            fname2='file2';
            path ='c:\home\user\';
            [f1,f2,ebar]  = parse_spe_name([path,'diff(',fname,',',fname2,')']);
            assertEqual([path,fname],f1);
            assertEqual([path,fname2],f2);
            assertTrue(isempty(ebar));
        end
        function test_parse_path_ebar(this)
            fname='file1';
            fname2='file2';
            path ='/home/user/';
            [f1,f2,ebar]  = parse_spe_name([path,'diff(',fname,',',fname2,',[1,0])']);
            assertEqual([path,fname],f1);
            assertEqual([path,fname2],f2);
            assertEqual([1,0],ebar);
        end
        
        function test_load_ascii(this)
            data=load_spe('MAP11014.SPE');
            assertTrue(isfield(data,'S'));
            assertTrue(isfield(data,'ERR'));
            assertTrue(isfield(data,'en'));
            assertEqual(size(data.S),size(data.ERR));
            assertEqual(numel(data.en),size(data.S,2))
            
        end
        function test_load_spe_h5(this)
            data=load_spe('MAP11020.spe_h5');
            assertTrue(isfield(data,'S'));
            assertTrue(isfield(data,'ERR'));
            assertEqual(size(data.S),size(data.ERR));
            assertEqual(numel(data.en),size(data.S,2))
        end
        function test_load_nxspe(this)
            data=load_spe('MAP11014.nxspe');
            assertTrue(isfield(data,'S'));
            assertTrue(isfield(data,'ERR'));
            assertEqual(size(data.S),size(data.ERR));
            assertEqual(numel(data.en),size(data.S,2))
        end
        function test_load_difnxspe(this)
            data=load_spe('diff(MAP11014.nxspe,MAP11014.spe)');
            assertTrue(isfield(data,'S'));
            assertTrue(isfield(data,'ERR'));
            assertEqual(size(data.S),size(data.ERR));
            assertEqual(numel(data.en),size(data.S,2))
        end
        function test_load_difsph5(this)
            data=load_spe('diff(MAP11020.spe_h5,MAP11020.spe)');
            assertTrue(isfield(data,'S'));
            assertTrue(isfield(data,'ERR'));
            assertEqual(size(data.S),size(data.ERR));
            assertEqual(numel(data.en),size(data.S,2))
        end
        
        %
    end
    
end
