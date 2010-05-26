function [is_in_memory,n_this_class,child_structure]=build_child(this,init_child_structure_fun,child_class_name)
%  function builds child class for the class config in a special way
%  providing singleton behaviour for the class config and all child classes 
%
%  The nonstandard behaviour is implemented because all classes are called
%  and referenced by value
%
% USAGE:
% old (compartibility form)
% >> [is_in_memory,n_this_class,child_structure]=build_child(config,@init_child_structure_fun,this_class_name)
% or (newer Matlabs)
%>>  [is_in_memory,n_this_class,child_structure]=config.build_child(@init_child_structure_fun,this_class_name)
%
%  where:
% init_child_structure_fun    is the function with builds default values for the new child
%                             class if this is the first time this class is accessed on this machine;
%                             if these values have already been build and
%                             used before, they will be read from HDD
%
% child_class_name        the name of the child class
% 
% the outputs are:
%
% is_in_memory        -- bolean, identifying if the class has been already
%                        initiated
% n_this_class        -- number of this class in the cell array of global
%                        configurations; if the class has not been
%                        initiated, it is the place where it should be
%                        placed in the cell array of configurations;
% child_structure     -- the structure of the child class, build either
%                        from defaults or read from hdd and will be used as
%                        the basis to construct this class if the class has
%                        not been yet initiated;
%                        
%
%
% $Revision$ ($Date$)
%

global class_names;


% is this class already in memory?
is_this_initiated=ismember(class_names,child_class_name);
    
if any(is_this_initiated)     % class has already been initiated and just needs to be returned;
        is_in_memory=true;
        n_this_class = find(is_this_initiated);
        child_structure='';
else                          % the base class had been initiated but this one not;
    if ~isa(init_child_structure_fun,'function_handle')
        help build_child
        error('CONFIG:build_child',' the second parameter of this funcion in classic notation or first in modern(dot) notation has to be a function handle');
    end
    is_in_memory=false;
        
   [config,n_this_class]= nInstancePlus(this);
    child_structure     = init_child_structure_fun();
   % save-restore config    
    child_structure     = save_restore_config(this,child_structure,child_class_name);    
    
    class_names{n_this_class}   =child_class_name;         
end


