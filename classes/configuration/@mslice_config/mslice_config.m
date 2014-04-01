classdef mslice_config<config_base
    % Class holds Mslice saveable configuration -- child of config_base
    %
    %
    % $Revision$ ($Date$)
    %
    
    properties(Dependent,SetAccess=private)
        MSliceDir  % -- calculated: Mslice folder
        SampleDir  % -- calculated: folder with msp configuration files which define GUI
    end
    properties(Dependent)
        MspDir     % folder with msp files which describe mslice configurations
        MspFile='crystal_psd.msp' % default msp file
        DataDir    % data files (spe files)
        PhxDir     % phx files (detector angular positions)
        cut_OutputDir   % defauld folder to save cuts.
        slice_font_size=10
        cut_font_size=10
        use_mex=true    % try to use mex if found
        force_mex_if_use_mex=false % fail if mex files do not work
        
        % if to set on Matlab path Herbert/Maltab unit test harness
        init_tests=false;
        % the path to the unit tests folders used last time when unit tests
        % were enabled.
        last_unittest_path;
    end
    
    properties(Access=protected)
        MSliceDir_=[] % -- calculated: Mslice folder
        SampleDir_=[] % -- sealed: folder with msp configuration files
        MspDir_     % folder with msp files which describe mslice configurations
        MspFile_='crystal_psd.msp' % default msp file
        DataDir_    % data files (spe files)
        PhxDir_     % phx files (detector angular positions)
        cut_OutputDir_   % defauld folder to save cuts -- defaults calculated by constructor from Mslice path

        slice_font_size_  =  10
        cut_font_size_    =  10
        use_mex_          =  true    % try to use mex if found
        force_mex_if_use_mex_=false % fail if mex files do not work
        %
        init_tests_  =  false        
        last_unittest_path_=''
        
    end
    properties(Constant,Access=private)
        saved_properties_list_={'MspDir','MspFile','DataDir','PhxDir',...
            'cut_OutputDir','slice_font_size','cut_font_size'...
            'use_mex','force_mex_if_use_mex','init_tests','last_unittest_path'};
    end
    
    methods
        function obj=mslice_config()
            % constructor
            obj=obj@config_base(mfilename('class'));
            if isdeployed
                obj.MSliceDir_=pwd;
                obj.SampleDir=fullfile(obj.MSliceDir_,'Data');
            else
                obj.MSliceDir_  = fullfile(fileparts(which('mslice_init.m')),'applications','mslice_gui');
                obj.SampleDir_  = fullfile(fileparts(which('mslice_init.m')),'Data');
            end
            obj.DataDir_      = obj.SampleDir_;
            obj.PhxDir_       = obj.SampleDir_;
            
            obj.MspDir_       = obj.SampleDir_;
            ms_path = strrep(userpath(),';','');
            if isempty(ms_path)
                ms_path = pwd;
            end
            obj.cut_OutputDir_=ms_path;
            
            
        end
        function dir = get.MSliceDir(this)
            dir= this.MSliceDir_;
        end
        function dir = get.SampleDir(this)
            dir= this.SampleDir_;
        end
        %-----------------------------------------------------------------
        % overloaded getters
        function use = get.MspDir(this)
            use = get_or_restore_field(this,'MspDir');
        end
        function use = get.MspFile(this)
            use = get_or_restore_field(this,'MspFile');
        end
        function use = get.DataDir(this)
            use = get_or_restore_field(this,'DataDir');
        end
        function use = get.PhxDir(this)
            use = get_or_restore_field(this,'PhxDir');
        end
        function use = get.cut_OutputDir(this)
            use = get_or_restore_field(this,'cut_OutputDir');
        end
        function use = get.init_tests(this)
            use = get_or_restore_field(this,'init_tests');
        end
        function use = get.slice_font_size(this)
            use = get_or_restore_field(this,'slice_font_size');
        end
        function use = get.cut_font_size(this)
            use = get_or_restore_field(this,'cut_font_size');
        end
        function use = get.use_mex(this)
            use = get_or_restore_field(this,'use_mex');
        end
        function use = get.force_mex_if_use_mex(this)
            use = get_or_restore_field(this,'force_mex_if_use_mex');
        end
        function path=get.last_unittest_path(this)
            path = get_or_restore_field(this,'last_unittest_path');
        end
        %-----------------------------------------------------------------
        % overloaded setters
        function this = set.MspDir(this,val)
            if ~ischar(val), error('MSLICE_CONFIG:set_MspDir',' folder name to store msp files has to be a string'), end
            config_store.instance().store_config(this,'MspDir',val);
        end
        function this = set.MspFile(this,val)
            if ~ischar(val), error('MSLICE_CONFIG:set_MspFile',' msp files name  has to be a string'), end
            config_store.instance().store_config(this,'MspFile',val);
        end
        function this = set.DataDir(this,val)
            if ~ischar(val), error('MSLICE_CONFIG:set_DataDir',' folder name to store data files has to be a string'), end
            config_store.instance().store_config(this,'DataDir',val);
        end
        function this = set.PhxDir(this,val)
            if ~ischar(val), error('MSLICE_CONFIG:set_PhxDir',' folder name to store PhxDir files has to be a string'), end
            config_store.instance().store_config(this,'PhxDir',val);
        end
        function this = set.cut_OutputDir(this,val)
            if ~ischar(val), error('MSLICE_CONFIG:set_cut_OutputDir',' folder name to store cut files has to be a string'), end
            config_store.instance().store_config(this,'cut_OutputDir',val);
        end
        
        function this = set.slice_font_size(this,val)
            if val<4 || val > 44; error('MSLICE_CONFIG:set_slice_font_size',' slice font size should be in range 4-44 points'); end
            config_store.instance().store_config(this,'slice_font_size',val);
        end
        
        function this = set.cut_font_size(this,val)
            if val<4 || val > 44; error('MSLICE_CONFIG:set_cut_font_size',' cut font size should be in range 4-44 points'); end
            config_store.instance().store_config(this,'cut_font_size',val);
        end
        
        function this = set.use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            config_store.instance().store_config(this,'use_mex',use);
        end
        function this = set.force_mex_if_use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            config_store.instance().store_config(this,'force_mex_if_use_mex',use);
        end
        
        function this = set.init_tests(this,val)
            [enable,xunit_path]=process_xunit_tests_path(this,val);
            if enable
                config_store.instance().store_config(this,'init_tests',enable,...
                    'last_unittest_path',xunit_path);
            else
                config_store.instance().store_config(this,'init_tests',enable);
            end
            
        end
        function this = set.last_unittest_path(this,path)
            % The path is set automatically when
            % enable_unit_tests is executed and herbert is present on the
            % path (at least once);
            % this function is to set a path to unit tests without touching
            % herbert 
            if ~isempty(path)
                if exist(fullfile(path,'assertEqual.m'),'file')
                    config_store.instance().store_config(this,'last_unittest_parh',path);
                else
                    warning('MSLICE_CONFIG:set_last_unittest_path',' path %s is not a path to unit tests. nothing has been set',path);
                end
            end
        end
        
        
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = this.saved_properties_list_;
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
        
    end
end