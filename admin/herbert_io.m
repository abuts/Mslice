function herb_io=herbert_io(input_args )
% function switch herbert IO functions on or off and enable native io
% accordingly
%
%should be used mainlty for the testing 
%Usage:
%>>herbert_io -on/-off
%
%

if nargin==0
    herb_io=true;
else
    if ismember('-on',input_args)
        herb_io=true;
    else
        if ismember('-off',input_args)
               herb_io=false;
        else
            herb_io=is_herbert_IO_on();            
            help herbert_io;
            return
        end
    end
end

rootpath = fileparts(which('mslice_init.m'));
if herb_io
    if is_herbert_IO_on(); return; end
    old_path=genpath_special(fullfile(rootpath,'mslice','IO','Native'));
    rmpath(old_path);
    new_path=genpath_special(fullfile(rootpath,'mslice','IO','Herbert'));
    addpath(new_path);
else
    if ~is_herbert_IO_on(); return; end    
    old_path=genpath_special(fullfile(rootpath,'mslice','IO','Herbert'));
    rmpath(old_path);
    new_path=genpath_special(fullfile(rootpath,'mslice','IO','Native'));
    addpath(new_path);
    
end


function is=is_herbert_IO_on()
rd_path = fileparts(which('rundata.m'));
if isempty(rd_path)
    is = false;        
else
    is = true;
end

