function cut_d=mslice_1d (varargin)
% Make a cut from single crystal, PSD mode. Uses the current viewing axes.
% Must have previously performed a 'calculate projections' in mslice.
%
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
% Currently works only for single crystal PSD mode

% Check mslice running
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig)
   error('Control Window not active. Return.');
end

% Check that the mode is correct
if ~(strcmpi(ms_getvalue('analysis_mode'),'single crystal') && strcmpi(ms_getvalue('det_type'),'PSD'))
    error('Function currently only works for single crystal, PSD mode')
end

% Check data is loaded
data=get(fig,'UserData');
if isempty(data)
    error('Load data first, then do slice')
end
if isstruct(data)
    if ~isfield(data,'S')||isempty(data.S),
        error('Loaded data set has no intensity matrix. Load data again.')
    elseif ~isfield(data,'v')||isempty(data.v),
        error('Calculate projections first and then take slices.')
    end
else
    error('Loaded data set has wrong type. Load data again')
end

% Parse the input arguments
[p,ux,uy,uz,file,filename,type,store,plotcmd,range,lims]= slice_1d_parse(data,varargin{:});

% Set values in GUI
if ~isempty(p)
    ms_setvalue('cut_x',p)
    ms_setvalue('cut_bin_vx',ux(2))
    ms_setvalue('cut_vx_min',ux(1))
    ms_setvalue('cut_vx_max',ux(3))
    ms_setvalue('cut_vy_min',uy(1))
    ms_setvalue('cut_vy_max',uy(2))
    ms_setvalue('cut_vz_min',uz(1))
    ms_setvalue('cut_vz_max',uz(2))
else
    % If cut axis is energy, treat gui values as in slice_1d_parse i.e. zero bin, or empty limits
    % If error trying to do so, then just use values in the gui
    if strcmp(strtrim(ms_getvalue('cut_x')),'Energy')   % energy axis
        uin=[ms_getvalue('cut_vx_min'),ms_getvalue('cut_bin_vx'),ms_getvalue('cut_vx_max')];
        [uin,mess,unchanged]=make_ebins(uin,data.en);
        if isempty(mess) && ~unchanged
            ms_setvalue('cut_bin_vx',uin(2))
            ms_setvalue('cut_vx_min',uin(1))
            ms_setvalue('cut_vx_max',uin(3))
        end
    end
end
if range
    ms_setvalue('cut_i_min',lims(1))
    ms_setvalue('cut_i_max',lims(2))
end

% Make cut, and write to file if requested

% Store current file information, so we can return if ~file
cut_OutputType_prev=ms_getvalue('cut_OutputType');
cut_OutputFile_prev=ms_getvalue('cut_OutputFile');
cut_OutputDir_prev=ms_getvalue('cut_OutputDir');

itype=strmatch(type,{'none','cut','xye','smh','mfit','hkl'});
ms_setvalue('cut_OutputType',itype)

if file && isempty(filename)
    filename = ms_putfile_full('*.cut');
    if isempty(filename)
        error('No output file name given')
    end
end
[cutpath,cutname,cutext]=fileparts(filename);
if isempty(cutext), cutext='.cut'; end  % default extension

if ~file
    ms_setvalue('cut_OutputDir','')
    ms_setvalue('cut_OutputFile','$full')
else
    ms_setvalue('cut_OutputDir',[cutpath,filesep])
    ms_setvalue('cut_OutputFile',[cutname,cutext])
end

if store && ~strcmp(strtrim(ms_getvalue('cut_x')),'Energy')  % for some reason, there is an extra space on the default label for energy
    error('Currently can only extract ''background'' data from cuts along the energy axis')
end

if ~isempty(plotcmd)
    if store
        cut_d_tmp=ms_cut('store_bkg_E',plotcmd);
    else
        cut_d_tmp=ms_cut(plotcmd);
    end
else
    if store
        cut_d_tmp=ms_cut('store_bkg_E');
    else
        cut_d_tmp=ms_cut;
    end
end

% Return file information if ~file
if ~file
    ms_setvalue('cut_OutputType',cut_OutputType_prev);
    ms_setvalue('cut_OutputFile',cut_OutputFile_prev);
    ms_setvalue('cut_OutputDir',cut_OutputDir_prev);
end

% Output, if requested
if nargout>0
    cut_d=cut_d_tmp;
end
