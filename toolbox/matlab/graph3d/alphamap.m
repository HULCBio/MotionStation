function [omap] = alphamap(param1, param2, param3)
%ALPHAMAP - Set a figure's AlphaMap property
%
% ALPHAMAP(MATRIX)     - Set the current figure's AlphaMap property to MATRIX.
% ALPHAMAP('default')  - Set the AlphaMap to it's default value.
% ALPHAMAP('rampup')   - Create a linear alphamap with increasing opacity.
% ALPHAMAP('rampdown') - Create a linear alphamap with decreasing opacity.
% ALPHAMAP('vup')      - Create an alphamap transparent in the center, and
%			 linearly increasing to the beginning and end.
% ALPHAMAP('vdown')    - Create an alphamap opaque in the center, and
%			 linearly decreasing to the beginning and end.
% ALPHAMAP('increase') - Modify the alphamap making it more opaque.
% ALPHAMAP('decrease') - Modify the alphamap making it more transparent.
% ALPHAMAP('spin')     - Rotate the current alphamap.
%
% ALPHAMAP(PARAM, LENGTH) - For Parameters which create new maps, create
%                        them with so they are LENGTH long.
% ALPHAMAP(CHANGE, DELTA) - For parameters which change the alphamap, use
%                        DELTA as a parameter.
%
% ALPHAMAP(FIGURE,PARAM) - Set FIGURE's AlphaMap to some PARAMeter.
% ALPHAMAP(FIGURE,PARAM,LENGTH)
% ALPHAMAP(FIGURE,CHANGE)
% ALPHAMAP(FIGURE,CHANGE,DELTA)
%
% AMAP=ALPHAMAP         - Fetch the current alphamap
% AMAP=ALPHAMAP(FIGURE) - Fetch the current alphamap from FIGURE.
% AMAP=ALPHAMAP(PARAM)  - Return the alphamap based on PARAM
% 			  without setting the property.
%
% See also ALPHA, ALIM, COLORMAP.

% MAPSTRINGS=ALPHAMAP('strings') - Return a list of strings which generate
%                         alphamaps.

% $Revision: 1.7 $ $Date: 2002/04/15 04:27:23 $
% Copyright 1984-2002 The MathWorks, Inc.


set_alphamap = 0;
len = size(get(gcf,'AlphaMap'),2);
delta=0;

if nargin > 0
  if ishandle(param1) & strcmp(get(param1, 'type'), 'figure')
    fig = param1;
    if nargin > 1
      param1 = param2;
      set_alphamap = 1;
      if nargin > 2
	len = param3;
	delta = param3;
      end
    else
      omap = get(fig,'AlphaMap');
    end
  else
    fig = gcf;
    if nargin > 0
      set_alphamap = 1;
      if nargin > 1
	len = param2;
	delta = param2;
      end
    else
      omap = get(fig,'AlphaMap');
    end
  end
else
  fig = gcf;

  omap = get(fig,'AlphaMap');
  
  return
end
  
if ischar(len)
  len = eval(len);
end
if ischar(delta)
  delta = eval(delta);
end

if set_alphamap
  if ischar(param1)
    switch param1
     case 'strings'
      map = { 'rampup' 'rampdown' 'vup' 'vdown' };
      set_alphamap = 0;
     case 'rampup'
      map = linspace(0, 1, len);
     case 'rampdown'
      map = linspace(1, 0, len);
     case 'vup'
      map = [linspace(0, 1, ceil(len/2)) linspace(1, 0, floor(len/2))];
     case 'vdown'
      map = [linspace(1, 0, ceil(len/2)) linspace(0, 1, floor(len/2))];
     case 'increase'
      map = get(fig,'AlphaMap');
      if delta == 0
	delta = .1;
      end
      map = map + delta;
      map(map > 1) = 1;
     case 'decrease'
      map = get(fig,'AlphaMap');
      if delta == 0
	delta = .1;
      end      
      map = map - delta;
      map(map < 0) = 0;
     case 'spin'
      map = get(fig,'AlphaMap');
      if delta == 0
	delta = 1;
      end
      if delta > 0
	map = [ map(delta+1:end) map(1:delta) ];
      elseif delta < 0
	delta = - delta;
	map = [ map(end-delta:end) map(1:end-delta-1) ];
      end
     case 'default'
      map = param1;
     otherwise
      error('Unknown alphamap specifier.');
    end
  else
    map = param1;
  end

  if set_alphamap
    if nargout == 1
      omap = map;
    else
      set(fig,'AlphaMap',map);
    end
  else
    omap = map;
  end
  
else
  omap = get(fig,'AlphaMap');
end

