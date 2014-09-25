classdef file_descriptor_tester<file_descriptor
    % class used to test file descriptor 
    %
    % To do that it overloads herbert and mslice folder locations, 
    % which describe source and destination
    % to mslice test folder and tmp folder correspondingly
    properties(Dependent)
    end
    methods(Static)
        function path = root_source_path()
            % path to mslice, which replaces herbert for the test class
            path = fileparts(which('mslice_init.m'));
        end
        function mpath = root_dest_path()
            mpath = tempdir();
        end
        
    end
    methods
        function this=file_descriptor_tester(varargin)
            this= this@file_descriptor(varargin{:});
        end
        
    end
    
end