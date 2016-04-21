function fire_show(pixels)

% Copyright 2003 The MathWorks, Inc.

persistent fireData;

if isempty(fireData) | ~ishandle(fireData.img)
    fireData = fire_open(size(pixels,1), size(pixels,2));
end

set(fireData.img,'CData',pixels);
drawnow;

function h = fire_open(WIDTH,HEIGHT)

h.name = 'Fire';

[fig,img] = newFig(h.name,uint8(zeros(HEIGHT,WIDTH)));

h.fig = fig;
h.img = img;
h.ax = get(img,'Parent');

set_palette(h);

function set_palette(h)

nColors = 256;
p = zeros(nColors,3);
% black to red
c = 0;
for i = 1 : nColors/4
  p(i,1) = c/nColors;
  c = c + 4;
end

% red to yellow
c = 0;
for i = nColors/4 + 1 : nColors/2
  p(i,1) = 1;
  p(i,2) = c/nColors;
  c = c + 4;
end

% yellow to white
c=0;
for i = (nColors/2 + 1) : (3 * nColors/4)
  p(i,1) = 1;
  p(i,2) = 1;
  p(i,3) = c/nColors;
  c = c + 4;
end

% white
for i = ((3 * nColors/4) + 1) : nColors
  p(i,1) = 1;
  p(i,2) = 1;
  p(i,3) = 1;
end

colormap(h.ax,p);

function [fig,img] = newFig(name,data)


   
fig = figure('Name',name,'Visible','off', ...
    'DoubleBuffer','off', ...
    'Clipping','off', ...
    'BackingStore','off', ...
    'MenuBar','none', ...
    'ToolBar','none');

as = axes('Parent',fig,'Drawmode','fast', ...
    'XLimMode','manual', ...
    'YLimMode','manual', ...
    'ZLimMode','manual', ...
    'ALimMode','manual');
    
   
img = image(data, ...
             'Parent', as, ...
             'CDataMapping','direct', ...
             'EraseMode','xor');

ylim = [4 (size(data,2) - 3)];
xlim = [1 size(data,1)];
set(as,'Visible','off',...
    'YLim',ylim,...
    'XLim',xlim, ...
    'Position',[0 0 1 1]);

set(fig,'Visible','on');
refresh(fig);

function closeFig(name)

% If a figure with this name already exists just make that the figure.
% Otherwise create a new figure.
objs = findobj(0,'Type','figure','Name',name);

if(~isempty(objs))
   close(objs(1));
end
