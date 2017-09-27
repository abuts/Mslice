classdef ldr_msl_membased<a_msl_loader
    % class which resembles data file stored to memory and loaded from
    % memory
    %
    % $Revision$ ($Date$)
    %
    % the properties common for all data loaders.
    properties(Dependent)
        % number of detectors in par file or in data file (should be
        % consistent if both are present;
        psi =[];
        efix =[];
    end
    
    properties(Access=protected)
        %
        efix_ = [];
        psi_  = [];
    end
    %
    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext='.mem';
        end
        function descr=get_file_description()
            % avoid description to not to try load this file from GUI
            descr ='';
        end
        
        function [ok,fh] = can_load(file_name)
            % check if the file name is ldr_msl_membased file name and the file can be
            % loaded by ldr_msl_membased class
            %
            %Usage:
            %>>[ok,fh]=ldr_msl_membased.can_load(file_name)
            % Input:
            % file_name -- the name of the file to check
            % Output:
            %
            % ok   -- True if the file can be processed by the loader_ascii
            % fh --  the structure, which describes spe file
            fh=[];
            ok = mem_msl_fs.instance().file_exist(file_name);
        end
        
        function [ndet,en,full_file_name,ei,psi]=get_data_info(file_name)
            % Load header information of previously stored ldr_msl_membased file
            %
            % >> [ndet,en,full_file_name,ei,psi] = ldr_msl_membased.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % en    -- energy bins
            % full_file_name -- the full name (with path) of the source nxpse file
            % ei     -- incident energy
            % psi    -- crystal rotation angle (should be NaN if undefined, but some )
            %
            if ~exist('file_name','var')
                error('MEMFILE:get_data_info',' has to be called with valid file name');
            end
            tf = mem_msl_fs.instance().load_file(file_name);
            ndet = tf.n_detectors;
            ei   = tf.efix;
            en    = tf.en;
            full_file_name = tf.file_name;
            psi = tf.psi;
        end
    end
    
    methods
        % constructor;
        function this=ldr_msl_membased(ldr_msl_membased_name,varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=a_msl_loader();
            %   constructor, which specifies par file name:
            %>>this=a_msl_loader(par_file_name);
            %   copy constructor:
            %>>this=a_msl_loader(other_loader);
            %
            this=this@a_msl_loader(varargin{:});
            if exist('ldr_msl_membased_name','var')
                this= this.init(ldr_msl_membased_name);
            else
                this = this.init();
            end
        end
        function this=init(this,ldr_msl_membased_name,full_par_file_name,varargin)
            %
            this.loader_defines ={'S','ERR','en','efix','psi','det_par','n_detectors'};
            if ~exist('ldr_msl_membased_name','var')
                return
            end
            if exist('full_par_file_name','var') && ~isempty(full_par_file_name)
                this.par_file_name = full_par_file_name;
            end
            
            [this.n_detindata_,this.en_,this.data_file_name_,...
                this.efix_,this.psi_]=ldr_msl_membased.get_data_info(ldr_msl_membased_name);
            if isempty(this.par_file_name)
                this.n_detinpar_ = this.n_detindata_;
            end
            
        end
        %
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names,
            % which are defined by current instance of loader class
            %
            % e.g. loader_ascii defines {'S','ERR','en','n_detectrs} if par file is not defined and
            % {'S','ERR','en','det_par'} if it is defined and loader_nxspe defines
            % {'S','ERR','en','det_par','efix','psi'}(if psi is set up)
            %usage:
            %>> fields= defined_fields(loader);
            %   loader -- the specific loader constructor
            %
            
            % the method returns the cellarray of fields names, which are
            % defined by current ldr_msl_membased
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = check_defined_fields(this);
        end
        function this=set_data_info(this,file_name)
            % method sets internal file information obtained for appropriate file
            % by get_data_info method;
            [this.n_detindata_,this.en_,this.data_file_name_,...
                this.efix_,this.psi_]=this.get_data_info(file_name);
            
        end
        function [det,this]=load_par(this,varargin)
        % loads detectors parameters information 
        %
            if isempty(this.par_file_name)
                mf = mem_msl_fs.instance().load_file(this.file_name);
                this.det_par = mf.det_par;
                det = mf.det_par;
            else
                det=load_par@a_msl_loader(this,varargin{:});
                this.det_par = det;
            end
        end
        function this=save(this,file_name)
            % save ldr_msl_membased into its memory file system
            [dummy,fname,fext]=fileparts(file_name);
            if isempty(fext)
                fext='.mem';
            end
            if strcmp('.mem',fext)
                this.data_file_name_ = [fname,fext];
                %
                
                mem_msl_fs.instance().save_file(fname,this);
            else
                error('MEMFILE:save',' can only save in file with extension .mem and provided with %s',fext);
            end
        end
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR CLASS PROPERTIES     -------------------
        % -----------------------------------------------------------------
        function ef = get.efix(this)
            ef=this.efix_;
        end
        function this = set.efix(this,val)
            this.efix_ = val;
        end
        function psi=get.psi(this)
            psi=this.psi_;
        end
        function this=set.psi(this,val)
            this.psi_=val;
        end
        % -----------------------------------------------------------------
        function [ok,mess,f_name]=check_file_exist(this,new_name)
            % method to check if file with extension correspondent to this loader exists
            [dummy,fn,fext] = fileparts(new_name);
            fbex = this.get_file_extension();
            if strcmp(fbex,fext)
                ok = mem_msl_fs.instance().file_exist(fn);
                if ok
                    mess ='';
                else
                    mess=['file: ',fn,fext,' does not exist'];
                end
                
                f_name = [fn,fext];
            else
                ok=false;
                mess='this loader can process mem files only';
                f_name='';
            end
        end
        
    end
    
end
