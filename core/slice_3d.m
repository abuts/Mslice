function vol_d=slice_3d(data,varargin)
% Make a 3D slice from single crystal, PSD mode. 
% Must have previously done a 'calculate projections' in mslice, and obtain data with fromwindow.
%
%   >> data = fromwindow;
%   >> wout = slice_3d (data, u1, u2, u3)
%
%   e.g.  >> vol_d = slice_3d(data,[0.5,0.03,1.5],[-0.1,0.02,0.1],[-0.5,2,95]);
%
% Optional additional arguments:
% ------------------------------
%   >> wout = slice_3d (..., 'file')              % prompt for a file name to write results
%   >> wout = slice_3d (..., 'file', filename)    % write results to named file
%
%   >> wout = slice_3d (..., 'noplot')            % turn off plotting
%
%   >> wout = slice_3d (..., 'plot')              % plot, with current smoothing (DEFAULT)
%   >> wout = slice_3d (..., 'plot', nsmooth)     % plot, changing smoothing to current value
%
%   >> wout = slice_3d (..., 'range', [i_min,i_max])  % intensity range for plot

% T.G.Perring   Feb 2009
% Currently works only for single crystal PSD mode


% Parse the input arguments
[p,ux,uy,uz,file,filename,plotcmd,nsmooth,range,lims]= slice_3d_parse(data,varargin{:});
if isempty(p)
    error ('Must give binning ranges')
end
if ~isempty(nsmooth)
    disp('Smoothing not yet implemented for 3D volume data - smoothing ignored')
end

% Create volume dataset
vol_d_tmp=vol_spe(data,ux,uy,uz);

% Write to file if required
if file
    error('Writing volume dataset to file not yet implemented')
end

% Now do plotting
if strcmp(plotcmd,'plot')
    if range
        plot_vol (vol_d_tmp, lims(1), lims(2))
    else
        plot_vol (vol_d_tmp)
    end
end

% Output, if requested
if nargout>0
    vol_d=vol_d_tmp;
end
