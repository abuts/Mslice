function slice_out = slice_ave (slice, axis, val_lo, val_hi)

%  Averages a slice over the range val_lo to val_hi on the named axis and
% propagates over the whole slice.
%
%   >> slice_out = slice_ave (slice, axis)
%
%   >> slice_out = slice_ave (slice, axis, val_lo, val_hi)
%
% Input: (all are required)
%   slice           Slice data structure of form produced by slice_spe (mslice function)
%   axis            'x' or 'y'
%   val_lo          Lower limit for averaging
%   val_hi          Upper limit for averaging
%
% Output:
%   slice_out
%
%
% T.G.Perring Sept 2006

slice_out = slice;

% Get bin centres and the true data range, transposing so want to take vertical stripe from data
if strcmp(axis,'x')
    val = 0.5*(slice.vx(2:end)+slice.vx(1:end-1));
    signal = slice.intensity(1:end-1,1:end-1);
elseif strcmp(axis,'y')
    val = 0.5*(slice.vy(2:end)+slice.vy(1:end-1));
    signal = slice.intensity(1:end-1,1:end-1)';
else
    disp('Axis label must be ''x'' or ''y'' in slice_ave');
end

if nargin==2
    val_lo=val(1);
    val_hi=val(end);
elseif nargin==4
    if val_hi<val_lo
        temp=val_hi;
        val_hi=val_lo;
        val_lo=temp;
    end
else
    disp('Check number of arguments to slice_ave')
end

% average those counts in range that are not NaN
ival=find(val>=val_lo&val<=val_hi); % range of indicies
if ~isempty(ival)
    signal = signal(:,ival(1):ival(end));
    ind = ~isnan(signal);   % elements of signal to sum
    signal(~ind)=0;         % set the other elements to zero for ease of summing
    npnt=sum(ind,2);    % number of elements
    npnt(npnt==0)=NaN; % to avoid warning message in divide by npnt
    signal = sum(signal,2)./npnt;
    signal = repmat(signal,1,length(val));
else
    signal = nan(size(signal));
end

% Fill output array
if strcmp(axis,'x')
    slice_out.intensity(1:end-1,1:end-1)=signal;
elseif strcmp(axis,'y')
    slice_out.intensity(1:end-1,1:end-1)=signal';
end

