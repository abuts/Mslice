classdef source_dest < handle
   % class defining source& target folder for herbert to mslice copying 

   properties(Dependent)
        source_folder;
        dest_folder;
   end
   properties(Access=private)
      source_folder_=''
      dest_folder_ = ''
   end
   
   methods(Static)
        function obj = instance()
            persistent unique_source_dest;
            if isempty(unique_source_dest)
                obj = source_dest();
                unique_source_dest = obj;
            else
                obj = unique_source_dest;
            end
        end

   end
   
   methods % Public Access
       function source = get.source_folder(obj)
         source = obj.source_folder_;
      end
      function dest = get.dest_folder(obj)
         dest = obj.dest_folder_;
      end
      
      function set_source_folder(obj, path)
         if ispc
            path = lower(path);
         end
         obj.source_folder_ = path;
      end
      function set_dest_folder(obj, path)
         if ispc
            path = lower(path);
         end
         obj.dest_folder_ = path;
      end
      function set_defaults(newObj)
            % Initialise your custom properties.
            % root path to source files (path to herbert)
            upath = get(mslice_config,'last_unittest_path');
            if isempty(upath)
                path= fileparts(which('herbert_init.m'));
                if isempty(path)
                    error('FILE_DESCRIPTOR:invalid_argument','Herbert unit tests have to be on Matlab search path for this method to work');
                end
            else
                path = upath(1:end-numel('_test\matlab_xunit\xunit'));
            end         
            if ispc
                path = lower(path);
            end
            
            newObj.source_folder_ = path;
           % root folder of destination files (mslice root)
            mpath = fileparts(which('mslice_init.m'));
            if isempty(mpath)
                error('FILE_DESCRIPTOR:invalid_parameters','Mslice has to be present on Matlab search path for this method to work');
            end
            if ispc
                mpath(1) = lower(mpath(1));
            end
            
            newObj.dest_folder_ = mpath;
          
          
      end

      
   end
   methods(Access=private)
       function newObj = source_dest()
            newObj.set_defaults()
       end   
   end

end
