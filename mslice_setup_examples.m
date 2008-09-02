function mslice_setup_examples
% Run Radu's mslice utility to change the paths in the example .msp files

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('mslice_setup_examples'));
    cd(rootpath)
    % Now get to the main mslice directory unless deployed as application
    if ~isdeployed
    cd mslice
    else
        cd ..
        cd ..
    end
    root_new=pwd;
    
    display(['line 18 reached - got into the directory  ' root_new])
   
    % Get the root directory for the examples from wherever the mslice installation was copied
    % Assumes mslice root directory contains msp files that between them give the root directory
    filename=dir('*.msp');
    for ifile=1:length(filename)
        fid=fopen(filename(ifile).name,'rt');
        root_old='';
        temp='';
        while isempty(root_old) & ischar(temp)
            temp=fgetl(fid);
            if strfind(temp,'MspDir')==1
                pos=strfind(temp,'=');
                root_old=fliplr(deblank(fliplr(deblank(temp(pos+1:end)))));
            end
        end
        fclose(fid);
        if ~isempty(root_old) && ~isdeployed
            pos=strfind(root_old,'\mslice');
            root_old = root_old(1:pos(end)+6);
            break
        elseif ~isempty(root_old)
            
            display(root_old)
            root_old = root_old(1:(end-1));
            display(root_old)
            
            break
        end
    end
    if ~isempty(root_old)
        updatemsp(root_new,'xye',[root_old filesep],[root_new filesep]);
        updatemsp([root_new filesep 'HET'],'xye',[root_old filesep],[root_new filesep]);
        updatemsp([root_new filesep 'IRIS'],'xye',[root_old filesep],[root_new filesep]);
        updatemsp([root_new filesep 'MARI'],'xye',[root_old filesep],[root_new filesep]);
        updatemsp([root_new filesep 'MAPS'],'xye',[root_old filesep],[root_new filesep]);
    else
        error('Problems changing paths in exmaple .msp files')
    end

    cd(start_dir);
    disp('Succesfully changed all paths in example .msp files.')

catch
    disp('Problems changing paths in example .msp files.')
    cd(start_dir);
end
