function ms_save_msp(file)

% function ms_save_msp;
   
% ==== select .msp file to save parameters to by browsing through the directory structure =====
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp('No Control widow opened, no data to be saved');
   return;
end


% === if no <filename> given select file by browsing
if ~exist('file','var')||isempty(file)||~ischar(file),
	cancel=ms_putfile('MspDir','MspFile','*.msp','Select file (.msp) to save Control Window parameters');
	%==== if cancel button pressed then return, do not save any .msp file
	if cancel,
		return
    end
    msp_dir    =get(mslice_config,'MspDir');
    msp_file   =get(mslice_config,'MspFile');
	newfile=fullfile(msp_dir,msp_file);
else
   newfile=file;
end

ext='msp';
% === put extension .msp by default ===
[paht,fname,fext]=fileparts(deblank(newfile));

if isempty(fext)|| (length(fext)==1 && fext=='.')	% no file extension, i.e. crystal_psd or crystal_psd.
   newfile=[fname,'.',ext];
else
   newfile=[fname,fext];
end

% ==== get default .msp parameter file 
h_samp=findobj(h_cw,'Tag','ms_sample');
if isempty(h_samp),
   disp(['Sample type could not be determined. Parameter file not saved.']);
end
samp=get(h_samp,'Value');
if samp==1,
   % === single crystal sample
   h_analysis_mode=findobj(h_cw,'Tag','ms_analysis_mode');
   if isempty(h_analysis_mode),
      disp(['Could not determine analysis mode for single crystal data. Parameter file not saved.']);
      return;
   end
   analmode=get(h_analysis_mode,'Value');
   if analmode==1,
	   h_det_type=findobj(h_cw,'Tag','ms_det_type');
   	if isempty(h_det_type),
      	disp(['Could not determine whether PSD or non-PSD detectors. Parameter file not saved.']);
      	return;
   	end
   	det_type=get(h_det_type,'Value');
    if det_type==1
   	   % ==== PSD type detectors
      	DefaultMspFile='crystal_psd.msp';
   	elseif det_type==2,
      	% === non-PSD (conventional detectors)
      	DefaultMspFile='crystal_no_psd.msp';
   	else
      	disp('Only PSD (det_type=1) and non-PSD (det_type=2) detector types allowed.');
      	disp('Parameter file not saved');
      	return;
    end
   elseif analmode==2,
      % ==== single crystal sample analysed in powder mode
      DefaultMspFile='crystal_as_powder.msp';
   else
    	disp(['Only single-crystal- and powder-mode (analysis_mode=1,2) allowed.']);
     	disp('Parameter file not saved');
    	return;
	end      
elseif samp==2,
   % === powder sample 
	DefaultMspFile='powder.msp';   
else
   disp('Wrong sample type. Only single crystal(1) and powder(2) allowed.');
	return;   
end

default=fullfile(get(mslice_config,'SampleDir'),DefaultMspFile);

% ==== open both the default .msp file and new file as ASCII text files 
f1=fopen(default,'rt');
if (f1==-1),
   disp(['Error opening default parameter file ' default]);
   disp('Parameter file not saved.');
   return;
end

f2=fopen(fullfile(msp_dir,newfile),'wt');
if (f2==-1),
   disp(['Error opening selected parameter file ' newfile]);
   disp(['in folder: ' msp_dir]);   
   disp('Parameter file not saved.');
   return;
end
% identify fields which are moved to mslice configuration file and should
% not be written into msp file
msl_fields=get(mslice_config,'all');
msl_fields = msl_fields.mslice_config;

% === write parameters line by line to the newfile mirroring structure of default file
t=fgetl(f1);	% read one line of the default file
while (ischar(t)&(~isempty(t(~isspace(t))))),	% until reaching the end of the defauilt file do ...
   pos=findstr(t,'=');
   field=t(1:pos-1);   
   fieldname=field(~isspace(field));	% obtain true fieldname by removing white spaces from field
   if isfield(msl_fields,fieldname)
       if strcmp(fieldname,'MspFile')
        fprintf(f2,'%s%2s%s\n',field,'= ',newfile);
       else
        fprintf(f2,'%s%2s%s\n',field,'= ','compartibility field moved into mslice_config and left here for compartibility with previous mslice version'); 
       end
   else
        h=findobj('Tag',['ms_' fieldname]);
        if isempty(h),
            disp(['Field ms_' fieldname ' not defined. Check ' default ' parameter file.']);
            fclose(f1);
            fclose(f2);
            return;
        end
        % if object is popupmenu or checkbox its value is stored in the 'Value' property, otherwise in 'String' 
        if strcmp(get(h,'Style'),'popupmenu')|strcmp(get(h,'Style'),'checkbox'),
            value=num2str(get(h,'Value'));
    %   	disp(['ms_' field ' has ''Value'' property ' value]);   
        else
          value=get(h,'String');
          value=deblank(value);	% remove trailing blanks from both beginning and end
          value=strtrim(value); 
    %      disp(['ms_' field ' has ''String'' property ' value]); 
        end 
        fprintf(f2,'%s%2s%s\n',field,'= ',value);        
   end

   t=fgetl(f1);
end
fclose(f1);
fclose(f2);
disp(['Saved parameters to file ' newfile]);