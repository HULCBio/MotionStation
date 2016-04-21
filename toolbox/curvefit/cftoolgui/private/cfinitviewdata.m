function [xname, yname, wname, method, span, degree] = cfinitviewdata(dataset)
% CFINITVIEWDATA is a helper function for the cftool GUI. 

% Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:39:55 $

ds = handle(dataset);

xname = ds.xname;
yname = ds.yname;
wname = ds.weightname;

source = ds.source;

if isempty(source)
    method = '';
    span = '';
    degree = '';
	return;
end

source = source(end,:);

mthd = source{4};

switch (mthd)
	case 'moving'
		method = xlate('Moving Average');
	case 'lowess'
		method = xlate('Lowess (linear fit)');
	case 'loess'
		method = xlate('Loess (quadratic fit)');
	case 'sgolay'
		method = xlate('Savitzky-Golay');
	case 'rlowess'
		method = xlate('Robust Lowess (linear fit)');
	case 'rloess'
		method = xlate('Robust Loess (quadratic fit)');
	otherwise
		method = xlate('Unknown method');
end

span = num2str(source{3});
if strcmp(mthd, 'sgolay')
    degree = num2str(source{5});
else
    degree = '';
end





