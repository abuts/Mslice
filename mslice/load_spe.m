function data=load_spe(spe_filename)

% function data=load_spe(spe_filename)
%
%   >> data = load_spe(file)
%
%   file    Name of a single spe file to be loaded, incluiding the path, e.g. c:\temp\my_file.spe 
%         *OR*
%           String that gives two file names, in which case load difference between two spe files
%           The format is:
%               <path>diff(<file1>,<file2>)
%
%            or <path>diff(<file1>,<file2>,ebar_opt)
%           
%           where
%            <path>      Optional path if both files are in the same folder (in which case do not
%                       give the path as part of the file names <file1> and <file2>
%            ebar_opt    Describes how the error bars are to be added:
%                ebar_opt= [0,0]    error bars set to zero
%                        = [1,0]    error bars taken from first file only
%                        = [0,1]    error bars taken from second file only
%                        = [1,1]    error bars added in quadrature
%
%           e.g. 'c:\temp\diff(hello.spe,there.spe)' => 
%               f1='c:\temp\hello.spe', f2='c:\temp\there.spe', ebar_opt=[]
%
%           e.g. '\diff('c:\temp\hello.spe,'d:\blobby\there.spe,[1,0])' => 
%               f1='c:\temp\hello.spe', f2='d:\blobby\there.spe', ebar_opt=[1,0]         
%
%   >> data = load_spe
%   
%
% loads data from an ASCII .spe file   
% returns data.en (1,ne)[meV]    
%             .det_group (ndet,1) 
%             .det_theta (ndet,1)[radians] total scattering angle of each detector 
%             (to be superseded by angles from the .phx file if using function builspe(spe_filename,phx_filename,...))
%             .S (ndet,ne)[intensity in units as given by data.axislabel(4,:)] 
%             .ERR (ndet,ne) [errors of .S, same units]
%             .filename [string] = spe_filename
%             where ne = number of points along the energy axis, 
%                   ndet = number of detector groups

% R.C. 24-July-1998
% 6-August-1998 incorporate field .det_group and .title
%
% *** ISIS changes
% TGP April 2008
%    Allow file input of form <path>diff(<file1>,<file2>) or <path>diff(<file1>,<file2>,ebar_opt)
%    to be interpreted as difference between two spe files
%

% === if no input parameter given, return
if ~exist('spe_filename','var'),
   help load_spe;
   return
end

% Determine if a single file or file difference to be read
% ----------------------------------------------------------
[spe_filename1,spe_filename2,ebars]=parse_spe_name(spe_filename);
if ~isempty(spe_filename2)   % must be a difference that is required
    data=load_spe(spe_filename1);   % take advantage of recursive function calls in matlab
    data2=load_spe(spe_filename2);
    if isempty(ebars)
        ebars=[1,1];
    end
    if isempty(data) | isempty(data2)
        data=[];
        return
    end
    try
        nulldata=-1e+30;
        index=(data.S(:,1)<=nulldata)|(data2.S(:,1)<=nulldata);   % find masked detectors in one or both .spe files
        data.S=data.S-data2.S;
        if all(ebars==[0,0])
            data.ERR=zeros(size(data.ERR));
        elseif all(ebars==[0,1])
            data.ERR=data2.ERR;
        elseif all(ebars==[1,1])
            data.ERR=sqrt(data.ERR.^2+data2.ERR.^2);
        end
        % Put nulldata with 0 error bar in output data set for detectors masked in either of the datasets
        data.S(index,:)=nulldata;
        data.ERR(index,:)=0;
        return
    catch
        display ('Problem taking difference between spe files. Check thay are commensurate')
        data=[];
        return
    end
end
[pathname,name,ext]=fileparts(spe_filename);  
hdf_file_str=spe_hdf_filestructure();
name=[name,ext];
if strcmpi(ext,hdf_file_str.spe_hdf_file_ext)
    try %try hdf5
        fields={hdf_file_str.data_field_names{1:3}};
        [data.en,data.S,data.ERR]=read_hdf_fields(strtrim(spe_filename),fields);
    %     spe_data=spe(spe_filename);
    %     data.S  = spe_data.S;
    %     data.ERR= spe_data.ERR;    
    %     data.en = spe_data.en;    
        data.en=data.en';
        [ndet,ne]=size(data.S);
        data.det_theta=ones(ndet,1);
        libisis_failed=false;  
    catch
        libisis_failed=true;    
    end
else    
  libisis_failed=true;        
end

if libisis_failed
% Single file only; leave load_spe untouched from this point onwards
% -------------------------------------------------------------------
filename=deblank(spe_filename); % remove blancs from beginning and end of spe_filename
filename=fliplr(deblank(fliplr(filename)));
% === if error opening file, return
fid=fopen(filename,'rt');
if fid==-1,
   disp(['Error opening file ' filename ' . Data not read.']);
   data=[];
   return
end
fclose(fid);

try % fortran algorithm
   [data.S,data.ERR,data.en]=load_spe_df(filename);
   disp(['Fortran loading of .spe file : ' filename]);      
   [ndet,ne]=size(data.S);
   disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);   
   data.det_theta=ones(ndet,1);
catch % matlab algorithm  
   disp([' fortran can not read spe data, error: ',lasterr]);    
   disp(['Matlab loading of .spe file : ' filename]);         
   fid=fopen(filename,'rt');
   % === read number of detectors and energy bins
   ndet=fscanf(fid,'%d',1);   % number of detector groups 
   ne=fscanf(fid,'%d',1);  % number of points along the energy axis
   temp=fgetl(fid);	% read eol
   disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);
   drawnow;

   % === read 2Theta scattering angles for all detectors
   temp=fgetl(fid);	% read string '### Phi Grid'
   det_theta=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
   det_theta=det_theta(1:ndet)*pi/180;  % leave out last value and transform degrees --> radians
   temp=fgetl(fid);	% read eol character of the Phi grid table
   temp=fgetl(fid);	% read string '### Energy Grid'
   en=fscanf(fid,'%10f',ne+1); % read energy grid
   en=(en(2:ne+1)+en(1:ne))/2; % take median values, centres of bins

   S=zeros(ndet,ne);
   ERR=S;
   for i=1:ndet,
      temp=fgetl(fid);
      %while isempty(temp)|isempty(findstr(temp,'### S(Phi,w)')),
      temp=fgetl(fid);			% get rid of line ### S(Phi,w)
      %end
      temp=fscanf(fid,'%10f',ne);
      S(i,:)=transpose(temp);
      temp=fgetl(fid);
      %while isempty(temp),
      %   temp=fgetl(fid),			
      %end
      temp=fgetl(fid);
      temp=fscanf(fid,'%10f',ne);
      ERR(i,:)=transpose(temp);   
   end
   fclose(fid);

   % BUILD UP DATA STRUCTURE 
   data.en=en';
   data.det_theta=det_theta(:);
   if exist('det_dtheta','var'),
      data.det_dtheta=det_dtheta;
   end
   data.S=S;
   data.ERR=ERR;
end
end

data.det_group=(1:ndet)';
data.filename=name;
data.filedir=pathname;
data.total_ndet=ndet;


%==========================================================================================
function [filename1,filename2,ebar_opt]=parse_spe_name (string)
% Determine if file has form <path>diff(<file1>,<file2>) or <path>diff(<file1>,<file2>,ebar_opt)
% Used in the generalisation of load_spe to enable differnece between two spe files to be read
% 
%   >> [filename1,filename2,ebar_opt]=parse_spe_name (string)
%
%   If does not have the form <path>diff(<file1>,<file2>) or <path>diff(<file1>,<file2>,ebar_opt)
%  then f1 is returned as the input string, and f2 and ebar_opt are left blank
%
% e.g. 'c:\temp\diff(hello.spe,there.spe)' => 
%   f1='c:\temp\hello.spe', f2='c:\temp\there.spe', ebar_opt=[]
%
% e.g. '\diff('c:\temp\hello.spe,'d:\blobby\there.spe,[1,0])' => 
%   f1='c:\temp\hello.spe', f2='d:\blobby\there.spe', ebar_opt=[1,0]
%
%
% T.G.perring April 2008

k=strfind(lower(string),'diff(');
if ~isempty(k)  % assume must have the form suitable for file differencing
    try
        if k~=1
            filepath=string(1:k-1);
        else
            filepath='';
        end
        string=string(k+5:end-1);   % strip out the contents of diff(...)
        k=strfind(string,',');
        if length(k)==1 % no ebar_opt
            filename1=[filepath,string(1:k-1)];
            filename2=[filepath,string(k+1:end)];
            ebar_opt=[];
        else    % *MUST* have ebar_opt if format is correct
            filename1=[filepath,string(1:k(1)-1)];
            filename2=[filepath,string(k(1)+1:k(2)-1)];
            ebar_opt=str2num(string(k(2)+1:end));
        end
    catch
        filename1=string;
        filename2='';
        ebar_opt=[];
    end
else
    filename1=string;
    filename2='';
    ebar_opt=[];
end
