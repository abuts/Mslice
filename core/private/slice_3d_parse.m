function [p,ux,uy,uz,file,filename,plotcmd,nsmooth,range,lims]= slice_3d_parse(data,varargin)
% Parse the input arguments
%
%   >> [p,ux,uy,uz,filename,plotcmd,nsmooth,range,lims]= slice_3d_parse(data,varargin)
%
% Valid input arguments are:
%   >> mslice_3d (du)                       % slice with current values in GUI, givuing bin size for the 'perp' axis
%   >> mslice_3d (u1, u2, u3)               % slice, changing values
%
%   e.g.  >> mslice_3d([0.5,0.03,1.5],[-0.1,0.02,0.1],[-0.5,2,95]);
%
% Optional additional arguments:
% ------------------------------
%   >> mslice_3d (..., 'file')              % prompt for a file name to write results
%   >> mslice_3d (..., 'file', filename)    % write results to named file
%
%   >> mslice_3d (..., 'noplot')            % turn off plotting
%
%   >> mslice_3d (..., 'plot')              % plot, with current smoothing (DEFAULT)
%   >> mslice_3d (..., 'plot', nsmooth)     % plot, changing smoothing to current value
%
%   >> mslice_3d (..., 'range', [i_min,i_max])  % intensity range for plot

% T.G.Perring   Feb 2009

narg=numel(varargin);
ien=find(data.u(:,4),1); if isempty(ien), ien=0; end    % index of energy axis (=0 if none are energy)

% Get binning and integration ranges
if narg>=3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
    ibeg=4;
    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
        u1=varargin{1}; u2=varargin{2}; u3=varargin{3};
        n1=numel(u1); n2=numel(u2); n3=numel(u3);
        if (n1==3 || (n1==1 && ien==1)) && (n2==3 || (n2==1 && ien==2)) && (n3==3 || (n3==1 && ien==3))
            p=0;
            ux=u1; uy=u2; uz=u3;
            if ien==1
                [ux,mess]=make_ebins(ux,data.en);
                if ~isempty(mess), error(mess), end
            elseif ien==2
                [uy,mess]=make_ebins(uy,data.en);
                if ~isempty(mess), error(mess), end
            elseif ien==3
                [uz,mess]=make_ebins(uz,data.en);
                if ~isempty(mess), error(mess), end
            end
        else
            error('Check number and type of arguments')
        end
    else
        error('Check number and type of arguments')
    end
elseif narg>=1 && isnumeric(varargin{1}) && isscalar(varargin{1})
    ibeg=2;
    p=[]; ux=[]; uy=[]; uz=varargin{1};
else
    error('Check number and type of arguments')
end

% Get options
file=false;
filename='';
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
            if ibeg<=narg && ischar(varargin{ibeg}) && isempty(strmatch(lower(varargin{ibeg}),{'plot','noplot','file','range'}))
                filename=varargin{ibeg};
                ibeg=ibeg+1;
            end
        else
            error('Check number and type of arguments')
        end
    else
        error('Check number and type of arguments')
    end
end
