function fc=synchronize_mslice(varargin)
% function to synchronize mslice functions, which come from herbert with
% its source
%
%
%   $Rev$ ($Date$)
%


fc=funcCopier();



if nargin>0
  fc = build_dependencies_list(fc);
else
   fc=fc.load_list('herbert_dependent.lst');    
end

fc=fc.copy_dependencies();
fc.save_list('herbert_dependent1.lst');

function fc=build_dependencies_list(fc)


fd = file_descriptor('equal_to_tol.m');
fd.short_dest_path = 'utilities/general';
fc=fc.add_dependency(fd);
% herbert_prog = varargin{1};
% mslice_folder = varargin{2};
% fc=fc.add_dependency(herbert_prog,mslice_folder);
% fc.save_list('herbert_dependent.lst');
