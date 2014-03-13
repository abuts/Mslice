function [p,ux,uy,uz,file,filename,type,store,plotcmd,range,lims]= slice_1d_parse(data,varargin)
% Parse the input arguments
%
%   >> [p,ux,uy,uz,file,filename,type,store,plotcmd,range,lims]= slice_1d_parse(data,varargin)
%
% Valid input arguments are:
%   >> mslice_1d                            % slice with current values in GUI
%   >> mslice_1d (u1, u2, u3)               % slice, changing values
%
%   Determines which is the cut direction as being the instance of u1,
%  u2 or u3 that has three elements
%   e.g.  >> mslice_1d([0.4,0.6],[-0.1,0.1],[-0.5,2,95]);
%  has the third projection axis as the cut direction
%
% Optional additional arguments:
% ------------------------------
%   >> mslice_1d (..., 'file')              % prompt for a file name to write results
%   >> mslice_1d (..., 'file', filename)    % write results to named file
%   >> mslice_1d (..., 'type', cut_type)    % cut type:
%               'mfit'      Full pixel info. with labels (DEFAULT)
%               'xye'       x-y-e data
%               'cut'       Full pixel info., no labels
%               'smh'       Bristol format
%               'hkl'
%
%   >> mslice_1d (..., 'noplot')            % turn off plotting
%   >> mslice_1d (..., 'plot')              % plot (DEFAULT)
%   >> mslice_1d (..., 'over')              % plot over
%   >> mslice_1d (..., 'range', [i_min,i_max])  % intensity range for plot
%
%   >> mslice_1d (..., 'store')             % store background

% T.G.Perring   Feb 2009

typelist={'cut','xye','smh','mfit','hkl'};  % options for single crystal sample (all analysis_mode and det_type)
file_typedefault='mfit';
nonfile_typedefault='xye';

narg=numel(varargin);

ien=find(data.u(:,4),1); if isempty(ien), ien=0; end    % index of energy axis (=0 if none are energy)

% Get binning and integration ranges
if narg>=3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
    ibeg=4;
    if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
        u1=varargin{1}; u2=varargin{2}; u3=varargin{3};
        n1=numel(u1); n2=numel(u2); n3=numel(u3);
        if (n1==3||(n1==1 && ien==1)) && n2==2 && n3==2
            p=1;
            if ien==1
                [ux,mess]=make_ebins(u1,data.en);
                if ~isempty(mess), error(mess), end
            else
                ux=u1;
            end
            uy=u2; uz=u3;
        elseif n1==2 && (n2==3||(n2==1 && ien==2)) && n3==2
            p=2;
            if ien==2
                [ux,mess]=make_ebins(u2,data.en);
                if ~isempty(mess), error(mess), end
            else
                ux=u2;
            end
            uy=u3; uz=u1;
        elseif n1==2 && n2==2 && (n3==3||(n3==1 && ien==3))
            p=3;
            if ien==3
                [ux,mess]=make_ebins(u3,data.en);
                if ~isempty(mess), error(mess), end
            else
                ux=u3;
            end
            uy=u1; uz=u2;
        else
            error('Check number and type of arguments')
        end

    else
        error('Check number and type of arguments')
    end
else
    ibeg=1;
    p=[]; ux=[]; uy=[]; uz=[];
end

% Get options
file=false;
filename='';
type='';
store=false;
plotcmd='';
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
        elseif strmatch(lower(varargin{ibeg}),'over')
            plotcmd='over';
            ibeg=ibeg+1;
        elseif strmatch(lower(varargin{ibeg}),'range')
            range=true;
            ibeg=ibeg+1;
            if ibeg<=narg && isnumeric(varargin{ibeg}) && numel(varargin{ibeg})==2
                lims=sort(varargin{ibeg});
                ibeg=ibeg+1;
            else
                error('Check number and type of arguments')
            end
        elseif strmatch(lower(varargin{ibeg}),'store')
            store=true;
            ibeg=ibeg+1;
        elseif strmatch(lower(varargin{ibeg}),'file')
            file=true;
            ibeg=ibeg+1;
            if ibeg<=narg && ischar(varargin{ibeg}) && isempty(strmatch(lower(varargin{ibeg}),...
                    {'plot','noplot','over','file','type','range','store'}))
                filename=varargin{ibeg};
                ibeg=ibeg+1;
            end
        elseif strmatch(lower(varargin{ibeg}),'type')
            ibeg=ibeg+1;
            if ibeg<=narg && ischar(varargin{ibeg}) && isempty(strmatch(lower(varargin{ibeg}),...
                    {'plot','noplot','over','file','type','range','store'}))
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
        disp('Choosing default output file type as Mfit .cut')
        type=file_typedefault;
    else
        type=nonfile_typedefault;
    end
end
