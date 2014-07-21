function [p,ux,uy,uz,file,filename,type,plotcmd,nsmooth,range,lims]= slice_2d_parse(data,varargin)
% Parse the input arguments
%
%   >> [p,ux,uy,uz,filename,plotcmd,nsmooth,range,lims]= slice_2d_parse(data,varargin)
%
% Valid input arguments are:
%   >> mslice_2d                            % slice with current values in GUI
%   >> mslice_2d (u1, u2, u3)               % slice, changing values
%
%   Determines which is the perpendicular axis as being the instance of u1,
%  u2 or u3 that has only two elements
%   e.g.  >> mslice_2d([0.5,0.03,1.5],[-0.1,0.1],[-0.5,2,95]);
%  has the second projection axis as the plane perpendicular
%
% Optional additional arguments:
% ------------------------------
%   >> mslice_2d (..., 'file')              % prompt for a file name to write results
%   >> mslice_2d (..., 'file', filename)    % write results to named file
%   >> mslice_1d (..., 'type', cut_type)    % slice type:
%               'slc'       Full pixel info. with labels (DEFAULT)
%               'xye'       x-y-z-e data
%
%   >> mslice_2d (..., 'noplot')            % turn off plotting
%
%   >> mslice_2d (..., 'plot')              % plot, with current smoothing (DEFAULT)
%   >> mslice_2d (..., 'plot', nsmooth)     % plot, changing smoothing to current value
% 
%   >> mslice_2d (..., 'surf')              % surface plot, with current smoothing
%   >> mslice_2d (..., 'surf', nsmooth)     % surface plot, changing smoothing to current value
%
%   >> mslice_2d (..., 'range', [i_min,i_max])  % intensity range for plot

% T.G.Perring   Feb 2009

typelist={'slc','xye'};  % file type options
file_typedefault='slc';
nonfile_typedefault='xye';

narg=numel(varargin);

ien=find(data.u(:,4),1); if isempty(ien), ien=0; end    % index of energy axis (=0 if none are energy)

% Get binning and integration ranges
if narg>=3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
    ibeg=4;
    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
        u1=varargin{1}; u2=varargin{2}; u3=varargin{3};
        n1=numel(u1); n2=numel(u2); n3=numel(u3);
        if n1==2 && (n2==3 || (n2==1 && ien==2)) && (n3==3 || (n3==1 && ien==3))
            p=1;
            ux=u2; uy=u3; uz=u1;
        elseif (n1==3 || (n1==1 && ien==1)) && n2==2 && (n3==3 || (n3==1 && ien==3))
            p=2;
            ux=u3; uy=u1; uz=u2;
        elseif (n1==3 || (n1==1 && ien==1)) && (n2==3 || (n2==1 && ien==2)) && n3==2
            p=3;
            ux=u1; uy=u2; uz=u3;
        else
            error('Check number and type of arguments')
        end

    else
        error('Check number and type of arguments')
    end
    % One of the axes could be energy
    if ien~=0
        ix=ien-p; if ix<=0, ix=ix+3; end     % this happens to give ix=1 if ux is energy, ix=2 if uy is energy, ix=3 if integration is energy
        if ix==1
            [ux,mess]=make_ebins(ux,data.en);
            if ~isempty(mess), error(mess), end
        elseif ix==2
            [uy,mess]=make_ebins(uy,data.en);
            if ~isempty(mess), error(mess), end
        end
    end
else
    ibeg=1;
    p=[]; ux=[]; uy=[]; uz=[];
end

% Get options
file=false;
filename='';
type='';
plotcmd='';
nsmooth=[];
range=false;
lims=[];

while ibeg<=narg
    if ischar(varargin{ibeg})
        if strmatch(lower(varargin{ibeg}),'noplot')
            plotcmd='noplot';
            ibeg=ibeg+1;
        elseif strmatch(lower(varargin{ibeg}),'plot')
            plotcmd='plot';
            ibeg=ibeg+1;
            if ibeg<=narg && isnumeric(varargin{ibeg})
                nsmooth=varargin{ibeg};
                ibeg=ibeg+1;
            else
                nsmooth=[];
            end
        elseif strmatch(lower(varargin{ibeg}),'surf')
            plotcmd='surf';
            ibeg=ibeg+1;
            if ibeg<=narg && isnumeric(varargin{ibeg})
                nsmooth=varargin{ibeg};
                ibeg=ibeg+1;
            else
                nsmooth=[];
            end
        elseif strmatch(lower(varargin{ibeg}),'range')
            range=true;
            ibeg=ibeg+1;
            if ibeg<=narg && isnumeric(varargin{ibeg}) && numel(varargin{ibeg})==2
                lims=sort(varargin{ibeg});
                ibeg=ibeg+1;
            else
                error('Check number and type of arguments')
            end
        elseif strmatch(lower(varargin{ibeg}),'file')
            file=true;
            ibeg=ibeg+1;
            if ibeg<=narg && ischar(varargin{ibeg}) && isempty(strmatch(lower(varargin{ibeg}),{'plot','noplot','surf','file','range'}))
                filename=varargin{ibeg};
                ibeg=ibeg+1;
            end
        elseif strmatch(lower(varargin{ibeg}),'type')
            ibeg=ibeg+1;
            if ibeg<=narg && ischar(varargin{ibeg}) && isempty(strmatch(lower(varargin{ibeg}),{'plot','noplot','surf','file','range'}))
                ind=strmatch(lower(varargin{ibeg}),typelist);
                if ~isempty(ind)
                    type=typelist{ind};
                    ibeg=ibeg+1;
                else
                    error('Invalid output file type')
                end
            else
                error('Check output file type')
            end
        else
            error('Check number and type of arguments')
        end
    else
        error('Check number and type of arguments')
    end
end

% Now do some consistency checks
% ---------------------------------
% Choose default file type if output file requested
if isempty(type)
    if file
        disp('Choosing default output file type as .slc')
        type=file_typedefault;
    else
        type=nonfile_typedefault;
    end
end
