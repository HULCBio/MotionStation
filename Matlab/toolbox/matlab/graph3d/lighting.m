function lighting(arg1,arg2)
%LIGHTING Lighting mode.
%   LIGHTING controls the lighting of SURFACE and PATCH objects.
%   SURFACE and PATCH objects are created by the functions SURF, MESH,
%   PCOLOR, FILL, and FILL3. 
%
%   LIGHTING FLAT sets the lighting of the current graph to flat.
%   LIGHTING GOURAUD sets the lighting to gouraud.
%   LIGHTING PHONG sets the lighting to phong.
%   LIGHTING NONE turns off lighting.
%   LIGHTING(AX,...) uses axes AX instead of the current axes.
%
%   See also LIGHT, MATERIAL
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 04:28:35 $

error(nargchk(1,2,nargin));
if ischar(arg1)
	% string input (check for valid option later)
	if nargin == 2
		error('First argument must be an axes handle.')
	end
	ax = gca;
    	type = lower(arg1);
else
	% make sure non string is a scalar handle
	if length(arg1) > 1
		error('Axes handle must be a scalar');
	end
	% handle must be a handle and axes handle
	if ~ishandle(arg1) | ~strcmp(get(arg1, 'type'), 'axes')
		error('First argument must be an axes handle.');
	end
	ax = arg1;
	
	% check for string option
	if nargin == 2
		if ischar(arg2)
			type = lower(arg2);
		else
			type = arg2;
		end
	else
		error('Lighting methods are none, flat, gouraud, and phong.');
	end
end

fc = get(ax,'color');
if strcmpi(fc,'none')
  fc = get(gcf,'color');
end
kids = [findobj(ax,'type','surface'); findobj(ax,'type','patch')];
imesh = [];
isurf = [];
for i = 1:length(kids)
  face = get(kids(i),'facecolor');
  if strcmp(face,'none')
    imesh = [imesh ; kids(i)];
  elseif ~isstr(face)
    if (all(face == fc)) 
      imesh = [imesh ; kids(i)];
    else
      isurf = [isurf; kids(i)];
    end
  else
    isurf = [isurf; kids(i)];
  end
end

if (strcmp(type, 'flat') | strcmp(type, 'f') )
	our_set(isurf,'facelighting','flat','edgelighting','none')
	our_set(imesh,'edgelighting','flat','facelighting','none')
elseif (strcmp(type, 'gouraud')) | strcmp(type, 'g') 
	our_set(isurf,'facelighting','gouraud','edgelighting','none')
	our_set(imesh,'edgelighting','gouraud','facelighting','none')
elseif (strcmp(type,'phong') | strcmp(type, 'p') )
	our_set(isurf,'facelighting','phong','edgelighting','none')
	our_set(imesh,'edgelighting','phong','facelighting','none')
elseif (strcmp(type,'none') | strcmp(type, 'n') )
	our_set(isurf,'facelighting','none','edgelighting','none')
	our_set(imesh,'edgelighting','none','facelighting','none')
else
	error('Lighting methods are none, flat, gouraud, and phong.');
end


function our_set(h, p1, v1, p2, v2)

if (~isempty(h))
    set(h, p1, v1, p2, v2)
end

