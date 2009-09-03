function [slice_d,slice_full]=mslice_2d (varargin)
% Make a slice in single crystal, PSD mode. Uses the current viewing axes.
% Must have previously performed a 'calculate projections' in mslice.
%
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
%
% Examples
% =========
%   >> mslice_2d
%   >> mslice_2d ('file','c:\temp\aaa.slc','noplot')                % save to file, no plotting
%   >> mslice_2d([-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'surf')    % surface plot
%   >> wref=mslice_2d([-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'file','c:\temp\aaa.slc','plot',2,'range',[0,0.5]);

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
[p,ux,uy,uz,file,filename,plotcmd,nsmooth,range,lims]= slice_2d_parse(data,varargin{:});

% Set values in GUI
if ~isempty(p)
    ms_setvalue('slice_z',p)
    ms_setvalue('slice_bin_vx',ux(2))
    ms_setvalue('slice_vx_min',ux(1))
    ms_setvalue('slice_vx_max',ux(3))
    ms_setvalue('slice_bin_vy',uy(2))
    ms_setvalue('slice_vy_min',uy(1))
    ms_setvalue('slice_vy_max',uy(3))
    ms_setvalue('slice_vz_min',uz(1))
    ms_setvalue('slice_vz_max',uz(2))
else
    % If a plot axis is energy, treat gui values as in slice_2d_parse i.e. zero bin, or empty limits
    % If error trying to do so, then just use values in the gui.
    ien=find(data.u(:,4),1); if isempty(ien), ien=0; end    % index of energy axis (=0 if none are energy)
    iperp=get(findobj(fig,'Tag','ms_slice_z'),'Value');     % index of viewing axis that is perpendicular to slice
    if ien~=0     % one of the axes is energy
        ix=ien-iperp; if ix<=0, ix=ix+3; end     % this happens to give ix=1 if ux is energy, ix=2 if uy is energy, ix=3 if integration is energy
        if ix==1
            uin=[ms_getvalue('slice_vx_min'),ms_getvalue('slice_bin_vx'),ms_getvalue('slice_vx_max')];
            [uin,mess,unchanged]=make_ebins(uin,data.en);
            if isempty(mess) && ~unchanged
                ms_setvalue('slice_bin_vx',uin(2))
                ms_setvalue('slice_vx_min',uin(1))
                ms_setvalue('slice_vx_max',uin(3))
            end
        elseif ix==2
            uin=[ms_getvalue('slice_vy_min'),ms_getvalue('slice_bin_vy'),ms_getvalue('slice_vy_max')];
            [uin,mess,unchanged]=make_ebins(uin,data.en);
            if isempty(mess) && ~unchanged
                ms_setvalue('slice_bin_vy',uin(2))
                ms_setvalue('slice_vy_min',uin(1))
                ms_setvalue('slice_vy_max',uin(3))
            end
        end
    end
end

if ~isempty(nsmooth)
    ms_setvalue('slice_nsmooth',nsmooth)
end
if range
    ms_setvalue('slice_i_min',lims(1))
    ms_setvalue('slice_i_max',lims(2))
end

% Make slice, and write to file if file present
if ~file
    if ~isempty(plotcmd)
        [slice_d_tmp,slice_full_tmp]=ms_slice_write ('$nofile', plotcmd);
%         slice_d_tmp=ms_slice (plotcmd);
    else
        [slice_d_tmp,slice_full_tmp]=ms_slice_write ('$nofile');
%         slice_d_tmp=ms_slice;
    end
else
    if isempty(filename)
        filename = ms_putfile_full('*.slc');
        if isempty(filename)
            error('No output file name given')
        end
    end
    if ~isempty(plotcmd)
        [slice_d_tmp,slice_full_tmp]=ms_slice_write (filename, plotcmd);
    else
        [slice_d_tmp,slice_full_tmp]=ms_slice_write (filename);
    end
end

% Output, if requested
if nargout>0
    slice_d=slice_d_tmp;
end
if nargout>1
    slice_full=slice_full_tmp;
end
