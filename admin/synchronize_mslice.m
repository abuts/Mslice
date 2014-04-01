function fc=synchronize_mslice(varargin)
% function to synchronize mslice functions, which come from herbert with
% its source
%
%
%   $Rev$ ($Date$)
%


fc=funcCopier();

fc=fc.load_list('herbert_dependent.lst');

if nargin>0
    herbert_prog = varargin{1};
    mslice_folder = varargin{2};
    fc=fc.add_dependency(herbert_prog,mslice_folder);
    fc.save_list('herbert_dependent.lst');
end

fc=fc.check_dependencies();
fc=fc.copy_dependencies();


