function h = nnsfo(id,n,x,y,z)
%NNSFO Neural Network Design utility function.

%  NNSFO(ID, N)
%    ID - Standard object id (string).
%    N  - Name (default = ID).
%  Creates a standard object given one of the following id'ID:
%    Full figure pixel coordinate axis: 'a0'
%    Single large axis:                 'a1'
%    Two small axes:                    'a2','a3'
%    Four small axes:                   'a4','a7'
%    Buttons on side of figure:         'b0',...,'b6'
%    Buttons on bottom of figure:       'b7',...,'b10'
%    Second row of buttons on bottom:   'b11',...,'b14'

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

% DEFAULT

if nargin < 1,error('Call to NNSFO with no arguments.'),end
if nargin < 2,n = id; end

% FIND OBJECT

ID = lower(id);

% STANDARD AXES

if strcmp(ID,'a0')
  obj = 'axis';
  figpos = get(gcf,'position');
  pos = [0 0 figpos(3:4)];
elseif strcmp(ID,'a1')
  obj = 'axis';
  pos = [38 153 377 160];

% TWO SMALL AXES
elseif strcmp(ID,'a2')
  obj = 'axis';
  pos = [48 153 160 160];
elseif strcmp(ID,'a3')
  obj = 'axis';
  pos = [254 153 160 160];

% FOUR SMALL AXES
elseif strcmp(ID,'a4')
  obj = 'axis';
  pos = [48 208 130 130];
elseif strcmp(ID,'a5')
  obj = 'axis';
  pos = [224 208 130 130];
elseif strcmp(ID,'a6')
  obj = 'axis';
  pos = [48 30 130 130];
elseif strcmp(ID,'a7')
  obj = 'axis';
  pos = [224 30 130 130];

% BUTTONS ON RIGHT SIDE

elseif strcmp(ID,'b0')
  obj = 'button';
  pos = [430 302 60 20];
elseif strcmp(ID,'b1')
  obj = 'button';
  pos = [430 266 60 20];
elseif strcmp(ID,'b2')
  obj = 'button';
  pos = [430 230 60 20];
elseif strcmp(ID,'b3')
  obj = 'button';
  pos = [430 194 60 20];
elseif strcmp(ID,'b4')
  obj = 'button';
  pos = [430 158 60 20];
elseif strcmp(ID,'b5')
  obj = 'button';
  pos = [430 122 60 20];
elseif strcmp(ID,'b6')
  obj = 'button';
  pos = [430 86 60 20];

% BUTTONS ON BOTTOM

elseif strcmp(ID,'b7')
  obj = 'button';
  pos = [80 10 60 20];
elseif strcmp(ID,'b8')
  obj = 'button';
  pos = [150 10 60 20];
elseif strcmp(ID,'b9')
  obj = 'button';
  pos = [220 10 60 20];
elseif strcmp(ID,'b10')
  obj = 'button';
  pos = [290 10 60 20];

% BUTTONS ABOVE BOTTOM

elseif strcmp(ID,'b11')
  obj = 'button';
  pos = [80 46 60 20];
elseif strcmp(ID,'b12')
  obj = 'button';
  pos = [150 46 60 20];
elseif strcmp(ID,'b13')
  obj = 'button';
  pos = [220 46 60 20];
elseif strcmp(ID,'b14')
  obj = 'button';
  pos = [290 46 60 20];

% DATA OBJECT

elseif strcmp(ID,'data')
  g = uicontrol('visible','off');
  if nargout, h = g; end
  return
  
% DEFAULT OBJECT

else
  error(['Call to NNFO with unrecognized id: ' id])
end

% CREATE OBJECT

if strcmp(obj,'axis')
  color_order = [nnred; nngreen; nndkblue; [1 0 1]];
  g = axes(...
    'units','points', ...
    'position',pos,...
    'box','on', ...
    'color',nnltyell, ...
    'xcolor',nndkblue, ...
    'ycolor',nndkblue, ...
    'zcolor',nndkblue, ...
    'fontsize',10,...
    'nextplot','add',...
    'colororder',color_order);
  if strcmp(ID,'a0')
    set(g,'xlim',[0 pos(3)],'ylim',[0 pos(4)])
    axis('off')
  end
  if nargin < 3 xlabel('x'); else xlabel(x); end
  if nargin < 4 ylabel('y'); else ylabel(y); end
  if nargin < 5 zlabel('z'); else zlabel(z); end
  set(get(g,'xlabel'),'fontw','bold','color',nndkblue)
  set(get(g,'ylabel'),'fontw','bold','color',nndkblue)
  set(get(g,'zlabel'),'fontw','bold','color',nndkblue)
  title(n);
  set(get(g,'title'),'color',nndkblue,'fontw','bold','fontsize',12)
  view(2);

elseif strcmp(obj,'button')
  g = uicontrol('units','points', ...
                'position',pos, ...
        'callback','disp(''NOT YET IMPLEMENTED'')', ...
                'string',n);
  if strcmp(lower(n),'close')
    set(g,'callback','delete(gcf)')
  end
end

if nargout == 1, h = g; end
