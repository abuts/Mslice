function ms_bkgd_sub(wback)
% Subtract named mgenie spectrum from data (must have already performed
% 'Calculate Projections'
%
%   >> ms_bkgd_sub(wback)
%

data=fromwindow;

% Check that the x-axis matches that of the data
en=get(wback,'x');
if length(data.en)~=length(en)
    error('Number of energy bins in data and background do not match')
end

if max(abs(data.en(:)-en(:)))>0.00001
    error('Energy bins of background do not match those of data')
end

y=get(wback,'y');
if any(isnan(y))
    error('One or more data points in background spectrum are NaN')
end

% Perform subtraction
data.S=data.S-repmat(y',size(data.S,1),1);

towindow(data);
