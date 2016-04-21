function hline = freqplotter(ax, W, H, xunits, xscale, lco, lso)
%FREQPLOTTER Plot the frequency data
%   AX - Handle to an axes
%   W - frequency info
%   H - Y info
%   xunits (Hz, kHz, etc)
%   xscale (log vs linear)

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/13 00:31:48 $

error(nargchk(3,7,nargin));
if nargin < 4, xunits = 'rad/sample'; end
if nargin < 5, xscale = 'linear'; end
if nargin < 6, lco    = [1:length(W)]; end
if nargin < 7, lso    = repmat({'-'}, 1, length(W)); end

hline = [];

np = get(ax, 'NextPlot'); set(ax, 'NextPlot', 'Add');
for indx = 1:length(H),
    hline = [hline; line(W{indx}, H{indx}, ...
        'Parent', ax, ...
        'Color', getcolorfromindex(ax, lco(indx)), ...
        'LineStyle', lso{indx})];
end

if ~all(isnan([W{1}(1) W{1}(end)])),
    set(ax, 'XLim', [W{1}(1) W{1}(end)]);
end

set(ax, ...
    'XScale', xscale, ...
    'NextPlot', np);
xlabel4ax(ax, getfreqlbl(xunits));

% [EOF]
