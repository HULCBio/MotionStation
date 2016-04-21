function r = sf_mandel_gui(varargin)
% sf_mandel_gui(varargin)
% Centralized control of mandelbrot fixed point demo.
%
% sf_mandel_gui()                - setup the display
% sf_mandel_gui(i,dc,fc)         - register color of i, dc color line for double image, fc color line for fixpt image.
% sf_mandel_gui('update')        - redisplay the image.
% sf_mandel_gui('pixel width')   - return width of image in pixels
% sf_mandel_gui('pixel height')  - return height of image in pixels
% sf_mandel_gui('colors')        - return number of colors
% sf_mandel_gui('real width')    - return actual width
% sf_mandel_gui('real height')   - return actual height
% sf_mandel_gui('real left')     - return actual left coordinate
% sf_mandel_gui('real top')      - return actual top coordinate

%	 Frederick Smith
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:53:05 $

persistent initialized
persistent pix_w pix_h num_colors;
persistent real_w real_h real_left real_top;
persistent fig img_fix img_dbl;
persistent data_fix data_dbl;
persistent waiting;
persistent name;
r = [];

if(isempty(initialized))
   initialized = 1;
   name = 'Fixed-point Mandelbrot Demo';
   waiting = 0;   
   num_colors = 128;   
   pix_w = 150;
   pix_h = 150;
   real_w = 3;
   real_h = 3;
   real_left = -2;
   real_top = 1.5;
   
   data_fix = uint8(zeros(pix_h,pix_w));
   data_dbl = uint8(zeros(pix_h,pix_w));
   
end

if nargin == 0
   % Initialize the gui.

   waiting = 0;   

   data_fix = uint8(zeros(pix_h,pix_w));
   data_dbl = uint8(zeros(pix_h,pix_w));

   [fig,img_fix,img_dbl] = newFig(name,data_fix,data_dbl);
   set(fig,'Colormap',jet(num_colors));
   
elseif nargin == 1
   % String inputs
   switch varargin{1}
   case 'enter_wait',
      waiting = 1;
   case 'exit_wait',
      waiting = 0;
   case 'close',
      closeFig(name);
   case 'pixel height',
      r = pix_h; 
      return;
   case 'pixel width',
      r = pix_w;
      return;
   case 'colors',
      r = num_colors;
      return;
   case 'real width',
      if ishandle(img_dbl)
         a = get(img_dbl,'parent');
         set(get(a,'Title'),'String',sprintf('width = %g',real_w));
      end
      
      r = real_w;
      return;
   case 'real height',
      r = real_h;
      return;
   case 'real left',
      r = real_left;
      return;
   case 'real top',
      r = real_top;
      return;
   case 'update',
      if ishandle(img_fix) & ishandle(img_dbl)
         set(img_fix,'Cdata',data_fix);
         set(img_dbl,'Cdata',data_dbl);
      else
         error('Image handles are no longer available. Aborting.');
      end
   case 'ButtonDown',
      if(waiting ~= 0)
         a = gca;
         point1 = get(a,'CurrentPoint');
         finalRect = rbbox;
         point2 = get(a,'CurrentPoint');
         
         if(~isequal(point1,point2))
            x1 = point1(1,1);
            y1 = point1(1,2);
            x2 = point2(1,1);
            y2 = point2(1,2);
            
            if x1 > x2
               tmp = x1;
               x1 = x2;
               x2 = tmp;
            end
            
            if y1 > y2
               tmp = y1;
               y1 = y2;
               y2 = tmp;
            end
            
            real_left = (x1 * real_w / pix_w) + real_left;
            real_top = real_top - (y1 * real_h / pix_h) ;
            real_w = ((x2 - x1) / pix_w) * real_w;
            real_h = ((y2 - y1) / pix_h) * real_h;
            
            % Enforce correct aspect ratio.
            real_h = (size(data_fix,2) / size(data_fix,1)) * real_w;
            
            triggerMode = get_param('sf_mandelbrot_fixpt/Trigger','value');
            if strcmp(triggerMode,'1')
               set_param('sf_mandelbrot_fixpt/Trigger','value','0');
            else
               set_param('sf_mandelbrot_fixpt/Trigger','value','1');
            end
         end
      end
   otherwise,
      error('Unrecognized case');
   end
elseif nargin == 3
   i = varargin{1};
   v2 = varargin{2};
   v3 = varargin{3};
   data_dbl(i,:) = uint8(v2(1:pix_w));
   data_fix(i,:) = uint8(v3(1:pix_w));
else
   error('Unrecognized input');
end;

function closeFig(name)

% If a figure with this name already exists just make that the figure.
% Otherwise create a new figure.
objs = findobj(0,'Type','figure','Name',name);

if(~isempty(objs))
   close(objs(1));
end

function [fig,img_f,img_d] = newFig(name,data_f,data_d)

closeFig(name);

fig = figure('Name',name,'Visible','off');

as = [axes('Parent',fig), axes('Parent',fig)];
names = { 'Fixed-point'; 'Double' };
data = { data_f; data_d };

set(fig,'Units','pixels');

for i = 1:length(as)
   imgs(i) = image(data{i}, ...
      'Parent', as(i), ...
      'CDataMapping','direct', ...
      'EraseMode','none', ...
      'ButtonDownFcn','sf_mandel_gui ButtonDown;');
   
   set(as(i),'Units','pixels');
   ap = get(as(i),'Position');
   ap(3) = size(data{i},1);
   ap(4) = size(data{i},2);
   set(as(i),'Position',ap, ...
      'XTickLabel',[], ...
      'YTickLabel',[]);
   set(get(as(i),'XLabel'),'String',names{i});
   
end

ap = [ get(as(1),'Position') ; get(as(2),'Position') ];

rw = ap(1,3) + ap(2,3);
rh = max(ap(1,4),ap(2,4));

dy = .1 * max(rh,rw);
dx = dy;

w = rw + 3 * dx;
h = rh + 2 * dy; 

set(as(1),'Position',[ dx dy ap(1,3) ap(1,4) ]);
set(as(2),'Position',[ (2*dx + ap(1,3)) ...
      dy ap(2,3) ap(2,4) ]);

units = get(0,'Units');
set(0,'Units','pixels');
scr = get(0,'ScreenSize');
set(0,'Units',units);

pos = zeros(1,4);
pos(1) = 0.01 * scr(3);
pos(2) = (0.96 * scr(4)) - h;
pos(3) = w;
pos(4) = h;

set(fig,'Position',pos,...
   'Resize','off', ...
   'MenuBar','none', ...
'ToolBar','none');

img_f = imgs(1);
img_d = imgs(2);

set(fig,'Visible','on');
