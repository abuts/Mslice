function data=load_spe(spe_filename)
% function data=load_spe(spe_filename)
% Load data from any supported data file
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
% MODIFIED TO WORK WITH HERBERT:
%
% $Revision: 225 $ ($Date: 2012-03-09 19:35:46 +0000 (Fri, 09 Mar 2012) $)
%
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
    if isempty(data) || isempty(data2)
        data=[];
        return
    end
    try
        index=(isnan(data.S))|isnan(data2.S);   % find masked detectors in one or both .spe files
        data.S=data.S-data2.S;
        if all(ebars==[0,0])
            data.ERR=zeros(size(data.ERR));
        elseif all(ebars==[0,1])
            data.ERR=data2.ERR;
        elseif all(ebars==[1,1])
            data.ERR=sqrt(data.ERR.^2+data2.ERR.^2);
        end
        % Put nulldata with 0 error bar in output data set for detectors masked in either of the datasets
        data.S(index)=NaN;
        data.ERR(index)=0;
        return
    catch
        display ('Problem taking difference between spe files. Check they are commensurate')
        data=[];
        return
    end
end
%
% Load single SPE file in any format supported
%
filename=strtrim(spe_filename);

loader   = loaders_factory.instance().get_loader(filename);
defines = loader.defined_fields();

ndet     = loader.n_detectors;
[data.S,data.ERR,data.en]=loader.load_data();


[path,filename,fext] = fileparts(loader.file_name);
data.filename=[filename,fext];
data.filedir=path;

data.det_group=(1:ndet)';
data.det_theta=ones(ndet,1);

if ismember('psi',defines)
    data.psi = loader.psi;
end
if ismember('Ei',defines)
    data.Ei = loader.Ei;
end

data.total_ndet=ndet;
%
