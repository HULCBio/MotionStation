function shading(arg1, arg2)
%SHADING Color shading mode.
%   SHADING controls the color shading of SURFACE and PATCH objects.
%   SURFACE and PATCH objects are created by the functions SURF, MESH,
%   PCOLOR, FILL, and FILL3. 
%
%   SHADING FLAT sets the shading of the current graph to flat.
%   SHADING INTERP sets the shading to interpolated.
%   SHADING FACETED sets the shading to faceted, which is the default.
%
%   Flat shading is piecewise constant; each mesh line segment or
%   surface patch has a constant color determined by the color value
%   at the end point of the segment or the corner of the patch which
%   has the smallest index or indices.
%
%   Interpolated shading, which is also known as Gouraud shading, is
%   piecewise bilinear; the color in each segment or patch varies linearly
%   and interpolates the end or corner values.
%
%   Faceted shading is flat shading with superimposed black mesh lines.
%   This is often the most effective and is the default.
%
%   SHADING(AX,...) uses axes AX instead of the current axes.
%
%   SHADING is an M-file that sets the EdgeColor and FaceColor properties
%   of all SURFACE objects in the current axes. It sets them to the
%   correct values that depend upon whether the SURFACE objects are
%   representing meshes or surfaces.
%
%   See also HIDDEN, SURF, MESH, PCOLOR, FILL, FILL3, SURFACE, PATCH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.18 $  $Date: 2002/04/15 04:27:41 $

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
		error('Shading methods are flat, faceted, and interp.');
	end
end

fc = get(ax,'color');
if strcmpi(fc,'none')
  fc = get(gcf,'color');
end
kids = [findobj(ax,'type','surface'); findobj(ax,'type','patch')];
imesh = [];
isurf = [];
itext = [];
for i = 1:length(kids)
  face = get(kids(i),'facecolor');
  if strcmp(face,'none')
    imesh = [imesh ; kids(i)];
  elseif strcmp(face,'texturemap')
    itext = [itext; kids(i)];
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

if (strcmp(type, 'flat'))
  if ~isempty(isurf), set(isurf,'facecolor','flat','edgecolor','none'); end
  if ~isempty(imesh), set(imesh,'edgecolor','flat'); end
  if ~isempty(itext), set(itext,'edgecolor','none'); end
elseif (strcmp(type, 'interp'))
  if ~isempty(isurf), set(isurf,'facecolor','interp','edgecolor','none'); end
  if ~isempty(imesh), set(imesh,'edgecolor','interp'); end
  if ~isempty(itext), set(itext,'edgecolor','interp'); end
elseif (strcmp(type,'faceted'))
  if ~isempty(isurf), set(isurf,'facecolor','flat','edgecolor','black'); end
  if ~isempty(imesh), set(imesh,'edgecolor','flat'); end
  if ~isempty(itext), set(itext,'edgecolor','black'); end
else
  error('Shading methods are flat, faceted, and interp.');
end
