function save_spe(data_in,spe_filename)
% Save spe file from mslice data
%   >> save_spe(data_in,spe_filename)
%
%   data_in must have fields
%       .en (1,ne)
%       .S (ndet,ne)
%       .ERR (ndet,ne)
%
%
% Changed by T.G.Perring:
%  Replaces original function of R.Coldea to remove problem of output field size request
%  not being observed by Matlab, and providing fortran call which is tried before writing
%  with Matlab routine
%  Write uses straight copy of algorithms from other applications by TGP. Need to convert format
%  of arrays to match those required by these other functions

% === return if data_in is not an spe data structure with appropriate fields
if ~exist('data_in','var')||isempty(data_in)||~isstruct(data_in)||...
        ~isfield(data_in,'en') ||isempty(data_in.en)  ||...
        ~isfield(data_in,'S')  ||isempty(data_in.S)   ||...
        ~isfield(data_in,'ERR')||isempty(data_in.ERR)
    disp('No data to save.');
    return;
end

% === return if error opening .spe filename
if ~exist('spe_filename','var')||isempty(spe_filename)||~ischar(spe_filename)
    disp('Incorrect filename given. Spe data not saved.');
    help save_spe;
    return;
end

% === reconstruct data with unmasked detectors
data=data_in;
ne=length(data.en);
nulldata=-1e+30;
if isfield(data,'det_group')&&isfield(data,'total_ndet'),
    if data.det_group(end)>data.total_ndet,
        format short g;
        disp(['data structure is incompatible with the total number of detectors' num2str(data.total_ndet)]);
        return;
    end
    ndet=data.total_ndet;
    data.S=nulldata*ones(ndet,ne);
    data.S(data.det_group,:)=data_in.S;
    data.ERR=zeros(ndet,ne);
    data.ERR(data.det_group,:)=data_in.ERR;
else
    % no masked detectors, data probably comes from a command line operation
    ndet=size(data.S,1);
end

% === eliminate spurious NaN or Inf points
index=(isnan(data.S)|isinf(data.S)|isnan(data.ERR)|isinf(data.ERR));
%index=isnan(data.S));	% 
%index=~((data.S(:,1)<=nulldata)|isinf(data.S(:,1))|index);

if sum(index(:))>=1,
    disp(sprintf('%d points with NaN or Inf data. ',sum(index(:))));
    data.S(index)=nulldata;
    data.ERR(index)=0;
end


% Require data to have following fields:
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
data.S=data.S';
data.ERR=data.ERR';
de=data.en(1,2)-data.en(1,1);
data.en=[data.en-de/2,data.en(end)+de/2]';

disp(['Saving .spe file ' spe_filename]);
[ok,mess]=put_spe(data,spe_filename);
if ~ok
    error(mess)
end

disp('--------------------------------------------------------------');

function [ok,mess,filename,filepath]=put_spe(data,file)
% Writes ASCII .spe file
%   >> [ok,mess,filename,filepath]=put_spe(data,file)
%
% The format is described in get_spe. Must make sure get_spe and put_spe are consistent.
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem

% T.G.Perring   15 August 2009

ok=true;
mess='';

null_data = -1.0e30;    % conventional NaN in spe files

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
filename=[name,ext];
filepath=[path,filesep];

% Prepare data for Fortran routine
index=~isfinite(data.S)|data.S<=null_data|~isfinite(data.ERR);
if sum(index(:)>0)
    data.S(index)=null_data;
    data.ERR(index)=0;
end

% Write to file
try
    ierr=put_spe_fortran(file_tmp,data.S,data.ERR,data.en);
    if round(ierr)~=0
        error(['Error writing spe data to ',file_tmp])
        filename='';
        filepath='';
    end
catch
    try     % matlab write
        disp(['Matlab writing of .spe file : ' file_tmp]);
        [ok,mess]=put_spe_matlab(data,file_tmp);
        if ~ok
            error(mess)
            filename='';
            filepath='';
        end
    catch
        ok=false;
        mess=['Error writing spe data to ',file_tmp]';
        filename='';
        filepath='';
    end
end

%======================================================================================================
function [ok,mess]=put_spe_matlab(data,file)
% Writes ASCII .spe file
%   >> [ok,mess,filename,filepath]=put_spe(data,file)
%
% data has following fields:
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true

% T.G.Perring 2 Jan 2008 - based on R.Coldea's save_spe
%
% Corrections to account for IEEE format on non-VMS machines.
% Write spe file. Note that on PC systems, numbers are written with three digits in the exponent
% e.g. -1.234E+007. It turns out that with format %-10.4G that Matlab will always give 4 sig. fig.,
% so that the result is an 11 character string if exponent form is needed. This will cause the spe
% file read routines to break. This is why in the following there is a test for PC (windows) - see
% sprintf documentation
%
% 15 Aug 2009: modified to make write consistent with matlab write as far as can.


ok=true;
mess='';

% It is assumed that before entry have already performed:
% --------------------------------------------------------
% null_data = -1.0e30;    % conventional NaN in spe files
% index=~isfinite(data.S)|data.S<=null_data|~isfinite(data.ERR);
% if sum(index(:)>0)
%     data.S(index)=null_data;
%     data.ERR(index)=0;
% end

% But further changes to S, ERR will be required for the matlab write to work if
% the .spe convention of 10 characters per entry is to be adhered to.
small_data = 1.0e-30;
big_data = 1.0e30;

data.S(data.S>big_data)=big_data;
data.S(abs(data.S)<small_data)=0;
data.ERR(data.ERR>big_data)=big_data;
data.ERR(abs(data.ERR)<small_data)=0;


% Now ready to write:
% --------------------
fid = fopen (file, 'wt');
if (fid < 0)
    ok=false;
    mess=['ERROR: cannot open file ' file];
    return
end

ne=size(data.S,1);
ndet=size(data.S,2);

% === write ndet, ne
fprintf(fid,'%-8d %-8d \n',ndet,ne);    

% === write phi grid (unused)
phi_grid=zeros(1,(ndet+1));
fprintf(fid,'%s\n','### Phi Grid');
fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',phi_grid(:));
if rem(ndet+1,8)~=0,
    fprintf(fid,'\n');
end

% === write energy grid
en_grid=round(data.en*1e5)/1e5;	%truncate at the 5th decimal point
fprintf(fid,'%s\n','### Energy Grid');
fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',en_grid(:));
if rem(ne+1,8)~=0,
  	fprintf(fid,'\n');
end

% === write S(det,energy) and ERR(det,energy)
for i=1:ndet
    fprintf(fid,'%s\n','### S(Phi,w)');
    if ispc
        for j=1:8:ne
            temp = sprintf('%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E',data.S(j:min(j+7,ne),i));
            temp = strrep(strrep(temp, 'E+0', 'E+'), 'E-0', 'E-');
            fprintf(fid,'%s\n',temp);
        end
    else
        fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',data.S(:,i));
        if rem(ne,8)~=0,
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'%s\n','### Errors');
    if ispc
        for j=1:8:ne
            temp = sprintf('%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E',data.ERR(j:min(j+7,ne),i));
            temp = strrep(strrep(temp, 'E+0', 'E+'), 'E-0', 'E-');
            fprintf(fid,'%s\n',temp);
        end
    else
        fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',data.ERR(:,i));
        if rem(ne,8)~=0,
            fprintf(fid,'\n');
        end
    end
end
fclose(fid);
