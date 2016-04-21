function adapteq_graphics(...
    yPayload0, yErr0, BER0, ...
    yPayload, yErr, BER, ...
    err, weights, simName, block);
% Graphics function for Communications Toolbox equalization demo.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/20 23:15:04 $

% Make figure tag same as graphics function name.
figTag = mfilename;

% Initialize graphics.
fig = findobj('type', 'figure', 'tag', figTag);
if isempty(fig)
   fig = newFigure(figTag);
end
ax = getappdata(fig, 'axes');
txt = getappdata(fig, 'txt');

% Plot results.
if nargin>0
    firstPlot = (block==1);
    if firstPlot, set(fig, 'name', simName); end
    plotConst(yPayload0, yErr0, ax.rxconst, firstPlot);
    plotConst(yPayload, yErr, ax.eqconst, firstPlot);
    plotLearnCurve(err, ax.learncurve, firstPlot);
    plotWeights(weights, ax.weights, firstPlot);
    setText(txt.ber0, 'BER=', BER0);
    setText(txt.ber, 'BER=', BER);
    setText(txt.blockcount, ['Block ' num2str(block)], []);
end

drawnow

%--------------------------------------------------------------------------
function fig = newFigure(figTag);

fig = figure(...
  'Tag', figTag,...
  'Name', 'Adaptive Equalizer Simulation', ...
  'IntegerHandle', 'off', ...
  'NumberTitle', 'off', ...
  'Renderer', 'zbuffer', ...
  'Toolbar', 'None');
 
% Constellations
ax.rxconst = createAxes(fig, 'rxconst', 'Received constellation');
ax.eqconst = createAxes(fig, 'eqconst', 'Equalized constellation');
set([ax.rxconst ax.eqconst], ...
    'plotboxaspect', [1 1 1], ...
    'xlim', [-2 2], 'ylim', [-2 2], ...
    'xtick', -2:2, ...
    'ytick', -2:2);

% Weights
ax.weights = createAxes(fig, 'weights', 'Equalizer weights');
set(ax.weights, 'XTick', [], 'XGrid', 'off');

% Learning curve
ax.learncurve = createAxes(fig, 'learncurve', 'Equalizer learning curve');
ylim(ax.learncurve, [-30 0]);
xlabel(ax.learncurve, 'Symbol index');
ylabel(ax.learncurve, '|e|^2 (dB)');

% Text
txt.ber0 = createText(ax.rxconst, 'BER=', 'ber0');
txt.ber = createText(ax.eqconst, 'BER=', 'ber');
txt.blockcount = createText(ax.eqconst, 'Block', 'blockcount');

% Store handles
setappdata(fig, 'axes', ax);
setappdata(fig, 'txt', txt);

loadPositions(fig);

%--------------------------------------------------------------------------
function plotConst(y, y_be, ax, firstPlot);

x1 = real(y);
y1 = imag(y);
x2 = real(y_be);
y2 = imag(y_be);

if firstPlot
    initAxes(ax);
    plot(x1, y1, '.', x2, y2, 'ro');
else
    c = get(ax, 'child');
    set(c(2), 'xdata', x1, 'ydata', y1);
    set(c(1), 'xdata', x2, 'ydata', y2);   
end

%--------------------------------------------------------------------------
function plotLearnCurve(e, ax, firstPlot);

y = 10*log10(abs(e).^2);

if firstPlot
    initAxes(ax);
    plot(y, '-');
    axis([0 length(e) -30 0]);
else
    c = get(ax, 'child');
    set(c, 'ydata', y);
end

%--------------------------------------------------------------------------
function plotWeights(w, ax, firstPlot);

% Number of weights
L = length(w);

% y-values for real and imaginary parts of weights
wStem = zeros(1, L*3);
wStem(2:3:end) = w;
yr = real(wStem);
yi = imag(wStem);

if firstPlot
    
    initAxes(ax);
    
    % x-domain for bar plot
    n = 1:L;  % Weight index
    x = [n; n; n];  
    x = x(:).';

    % Stem plots
    h.real = plot(x, yr, 'b-', 'linewidth', 2);
    hold on
    h.imag = plot(x, yi, 'm-', 'linewidth', 1);
    
    % Axis
    axis([0 L+1 -1 1]);
    
    % Legend
    %legend([h.real, h.imag], 'Real', 'Imag');

    % Assign handles to axes userdata.
    set(ax, 'userdata', h);
    
else
    
    h = get(ax, 'userdata');
    set(h.real, 'ydata', yr);
    set(h.imag, 'ydata', yi);

end

%--------------------------------------------------------------------------
% Auxiliary graphics functions
%--------------------------------------------------------------------------
function loadPositions(fig);
% Load position MAT file
figTag = get(fig, 'tag');
matFile = [figTag '.mat'];
if exist(matFile)
    load(matFile);
    f = fieldnames(hgPositions);
    pos = struct2cell(hgPositions);
    for n = 1:length(f)
        obj = findobj(fig, 'tag', f{n});
        set(obj, 'position', pos{n});
    end 
end

%--------------------------------------------------------------------------
function h = createAxes(parent, tag, theTitle);
fontSize = 8;
h = axes(...
    'Parent', parent, ...
    'Tag', tag, ...
    'FontSize', fontSize, ...
    'Box', 'on', ...
    'XGrid', 'on', ...
    'YGrid', 'on');
title(h, theTitle);

%--------------------------------------------------------------------------
function h = createText(parent, str, tag);
fontSize = 8;
h = text(...
    'Parent', parent, ...
    'String', str, ...
    'Tag', tag, ...
    'FontSize', fontSize, ...
    'FontWeight', 'bold');

%--------------------------------------------------------------------------
function initAxes(ax);
axes(ax)
c = get(ax, 'child');
for i=1:length(c)
    if ~strcmp(get(c(i), 'type'), 'text')
        delete(c(i));
    end
end
hold on

%--------------------------------------------------------------------------
function setText(h, str, val);
if ~isempty(val)
    set(h, 'string', [str num2str(val, '%0.2g')]);
else
    set(h, 'string', str);
end
