function d1=subtract_speBOSE(T1,T2,file1,file2,file)
% function subtracts boze corrected spe or nxspe files.
% and saves result to spe or nxspe target file depending on the type of the input files.
% Inputs:
% T1 -- the temperature (in K) of the first dataset to substract from
% T2 -- the temperature (in K) of the second dataset to substact
% file1 -- the known format datafile containing the first dataset.
% file2 -- he known format datafile containing the first dataset.
% file  -- the file name of the dataset to store. The type of the file is equal to type of the input files.
%
% Returns:
% d1 -- the boze corrected data containing in the first file.
% Saves:
% spe or nxspe (depending on the type of the input files) BOSE-corrected
% data file.
%
% Usage examples:
%subtract_speBOSE(7.0,100.0,'MER16285_rings_125_abs.nxspe','MER16289_rings_125_abs.nxspe','test.spe')
%subtract_speBOSE(7.0,100.0,'MER41577_Ei100.00meV_Rings182.nxspe','MER41583_Ei100.00meV_Rings182.nxspe','test1.spe')
%subtract_speBOSE(7.0,50.0,'MER41285_Ei158.00meV_rings18_2abs.nxspe','MER41288_Ei158.00meV_rings18_2abs.nxspe','test2158meV.spe')
%subtract_speBOSE(7.0,50.0,'MER41285_Ei50.00meV_rings18_2abs.nxspe','MER41288_Ei50.00meV_rings18_2abs.nxspe','test2.spe')
%

if ~isnumeric(T1) || isnan(T1) || T1<=0
    error('BOSE:invalid_argument',' First parameter (T1) should be a positive number')
end
if ~isnumeric(T2) || isnan(T2) || T2<=0
    error('BOSE:invalid_argument',' Second parameter (T2) should be a positive number')
end


%data=fromwindow;
[d1,ldr]=load_data(file1); % load spe file1
%d1=buildspe(file1, 'c:\mprogs\mslice\het\rungs_all.phx')
d2=load_data(file2);
%d2=buildspe(file2, 'c:\mprogs\mslice\het\rungs_all.phx')
if any(size(d1.S) ~= size(d2.S))
    error('BOSE:invalid_argument','Input data files are inconsistent')
end

% == locate masked pixels
mask1 = isnan(d1.S);
mask2 = isnan(d2.S);
if all(reshape(~mask1,1,numel(mask1))) && all(reshape(~mask2,1,numel(mask2)))
    sprintf('No masked detectors in either file.');
end

index_masked=mask1 |mask2 ;


%==correct file2 with BOSE_T1 and divided by BOSE_T2
e2=ones(size(d2.det_group))*d2.en;
%e2=ones(size(d2.S),2)*d2.en;

bose1=1-exp(-abs(e2)*11.604/T1);
bose2=1-exp(-abs(e2)*11.604/T2);
d3.S=d2.S.*(bose1./bose2);
d3.ERR=d2.ERR.*(bose1./bose2);
% == subtract intensities
d1.S=d1.S-d3.S;
d1.ERR=sqrt((d1.ERR).^2+(d3.ERR).^2); % adjust errors after subtraction
d1.ERR(index_masked)=0;
if isempty(d1.par)
    d1.S(index_masked) = 1.e+29; % keep masked pixels
    d1.filename = file;
    save_spe(d1,file); % save resulting data to file
else
    %ldr.
    d1.S(index_masked)=NaN;
    ldr.S = d1.S';
    ldr.ERR=d1.ERR';
    [fp,fn] = fileparts(file);
    file = fullfile(fp,[fn,'.nxspe']);
    if exist(file,'file') == 2
        delete(file);
    end
    d1.filename = file;    
    ldr.saveNXSPE(file,d1.Ei,d1.psi);
end

%
function [data,loader] = load_data(filename)
filename=strtrim(filename);

loader   = loaders_msl_factory.instance().get_loader(filename);
defines = loader.defined_fields();

ndet     = loader.n_detectors;
[S,ERR,en]=loader.load_data();

data.S = S';
data.ERR = ERR';
data.en = (en(2:end)+en(1:end-1))'/2;

[path,filename,fext] = fileparts(loader.file_name);
data.filename=[filename,fext];
data.filedir=path;

data.det_group=(1:ndet)';
data.det_theta=ones(ndet,1);

if ismember('psi',defines)
    data.psi = loader.psi;
else
    data.psi = NaN;
end
if ismember('Ei',defines)
    data.Ei = loader.Ei;
end
if ismember('efix',defines)
    data.Ei  = loader.efix;
end

data.total_ndet=ndet;
try
    par = loader.load_par('-getphx');
    data.par = par;
    data.det_group = par(6,:)';
    data.det_theta = par(3,:)';
catch ME
    data.par = [];
end
