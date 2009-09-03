function cut_d=slice_1d (data,varargin)
% Make a cut from single crystal, PSD mode.
% Must have previously done a 'calculate projections', and obtain data with fromwindow.
%
%   >> data = fromwindow;
%   >> wout = slice_1d (data, u1, u2, u3)
%
%   Determines which is the cut direction as being the instance of u1,
%  u2 or u3 that has three elements
%   e.g.  >> slice_1d([0.4,0.6],[-0.1,0.1],[-0.5,2,95]);
%  has the third projection axis as the cut direction
%
% Optional additional arguments:
% ------------------------------
%   >> slice_1d (..., 'file')              % prompt for a file name to write results
%   >> slice_1d (..., 'file', filename)    % write results to named file
%   >> slice_1d (..., 'type', cut_type)    % cut type:
%               'mfit'      Full pixel info. with labels (DEFAULT)
%               'xye'       x-y-e data
%               'cut'       Full pixel info., no labels
%               'smh'       Bristol format
%               'hkl'
%
%   >> slice_1d (..., 'noplot')            % no plotting (DEFAULT)
%   >> slice_1d (..., 'plot')              % plot
%   >> slice_1d (..., 'over')              % plot over
%   >> slice_1d (..., 'range', [i_min,i_max])  % intensity range for plot
%
%   >> slice_1d (..., 'store')             % store background

% T.G.Perring   Feb 2009
% Currently works only for single crystal PSD mode


% Parse the input arguments
[p,ux,uy,uz,file,filename,type,store,plotcmd,range,lims]= slice_1d_parse(data,varargin{:});
if isempty(p)
    error ('Must give binning and integration ranges')
end

if file && isempty(filename)
    filename = ms_putfile_full('*.cut');
    if isempty(filename)
        error('No output file name given')
    end
end

% Need to get character string for type needed by cut_spe
internal_type={'none','.cut','.xye','.smh','Mfit .cut','.hkl'};
itype=strmatch(type,{'none','cut','xye','smh','mfit','hkl'});
type=internal_type{itype};

% Set range
if range
    i_min=lims(1); i_max=lims(2);
else
    i_min=''; i_max='';     % plot command will autoscale
end

% Hold 1D plot if 'over' option
if isempty(plotcmd) || strcmp(plotcmd,'noplot')
    noplot=true;
else
    noplot=false;
    if strcmp(plotcmd,'over') && ~isempty(findobj('Tag','plot_cut'))
        figure(findobj('Tag','plot_cut'));
        hold on;
    end
end

% Set parameters for background cut
if store
    if ~strcmp(strtrim(ms_getvalue('cut_x')),'Energy')  % for some reason, there is an extra space on the default label for energy
        error('Currently can only extract ''background'' data from cuts along the energy axis')
    end
    disp('Storing cut as an estimate for an energy-dependent ''background''.');
    disp('Adjusting range and binning along the energy axis to match those of the spe data.');
    ux=[data.en(1),data.en(2)-data.en(1),data.en(end)];
end

% Create cut, writing to file if required, but no plotting yet.
data=cut_extra_fields(data,type);   % add the extra fields needed by some cut scenarios (see code of ms_cut for details)
if file
    cut_d_tmp=cut_spe(data,p,ux(1),ux(3),ux(2),uy(1),uy(2),uz(1),uz(2),i_min,i_max,type,filename,'',noplot);
else
    cut_d_tmp=cut_spe(data,p,ux(1),ux(3),ux(2),uy(1),uy(2),uz(1),uz(2),i_min,i_max,type,'$full','',noplot);
end

% Output, if requested
if nargout>0
    cut_d=cut_d_tmp;
end
