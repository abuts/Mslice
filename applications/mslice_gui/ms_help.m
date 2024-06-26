function ms_help(entry)

% function ms_help(entry)

% === find help text for given entry in the mSlice help file
% === return if no help found or if helpfile not accessible, give warning

% === return if MSlice ControlWindow not active 
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp('No ControlWidow opened, no help available.');
   return;
end
%
helpfile=fullfile(get(mslice_config,'MSliceDir'),'help.txt');	% MSlice help file
if ~exist(helpfile,'file')
   disp(['Could not find help file ' helpfile ]);
   return;
end

fpos=ffind(helpfile,[':' entry]);
if (fpos<0),
   disp(['No help found for entry ' entry]);
   return;
end
fid=fopen(helpfile,'rt');
if (fid<0),
   disp(['Help file ' helpfile ' could not be opened. Check location and path.']);
   return;
end

% === display help in the matlab command window
% help entry ends when a complete row of blanc spaces is encountered
fseek(fid,fpos+1,'bof');
helptxt=[];
helpline=fgetl(fid);
disp(['Help ' entry ]);
while ~isempty(helpline(~isspace(helpline))),
   disp(helpline);
	helpline=fgetl(fid);   
end
drawnow;
fclose(fid);