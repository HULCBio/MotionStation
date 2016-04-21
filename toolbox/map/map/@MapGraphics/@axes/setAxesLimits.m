function setAxesLimits(this,bbox)
%SETAXESLIMITS Set extent of axes
%
%   SETAXESLIMITS(BBOX) sets the extent of the axes to the bounding box BBOX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:58 $

x = squeeze(bbox(:,1,:)); % 2-by-n with all the x-bounds
y = squeeze(bbox(:,2,:)); % 2-by-n with all the y-bounds

round = true;
if round
  set(this,'XLim',roundinterval([min(x(:)) max(x(:))]),...
           'YLim',roundinterval([min(y(:)) max(y(:))]));
else
  set(this,'XLim',[min(x(:)) max(x(:))],...
           'YLim',[min(y(:)) max(y(:))]);
end

%--------------------------------------------------------------------------------

function y = roundinterval( x )

% Round out an interval: Let d be the length of the interval divided by 10.
% Find f, the closest value to d of the form 10^n, 2 * 10^n, or 5 * 10^n.
% Subtract f from min(x) and round down to the nearest multiple of f.
% Add f to max(x) and round up to the nearest multiple of f.

% Need to catch d == 0.

d = abs(x(2)-x(1))/10;
e = [1 2 5 10] * 10^(floor(log10(d)));
[m i] = min(abs(e - d));
f = e(i);
y = f * [floor(min(x)/f - 1) ceil(max(x)/f + 1)];
