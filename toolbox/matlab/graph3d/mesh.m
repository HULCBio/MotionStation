function h = mesh(varargin)
%MESH   3-D mesh surface.
%   MESH(X,Y,Z,C) plots the colored parametric mesh defined by
%   four matrix arguments.  The view point is specified by VIEW.
%   The axis labels are determined by the range of X, Y and Z,
%   or by the current setting of AXIS.  The color scaling is determined
%   by the range of C, or by the current setting of CAXIS.  The scaled
%   color values are used as indices into the current COLORMAP.
%
%   MESH(X,Y,Z) uses C = Z, so color is proportional to mesh height.
%
%   MESH(x,y,Z) and MESH(x,y,Z,C), with two vector arguments replacing
%   the first two matrix arguments, must have length(x) = n and
%   length(y) = m where [m,n] = size(Z).  In this case, the vertices
%   of the mesh lines are the triples (x(j), y(i), Z(i,j)).
%   Note that x corresponds to the columns of Z and y corresponds to
%   the rows.
%
%   MESH(Z) and MESH(Z,C) use x = 1:n and y = 1:m.  In this case,
%   the height, Z, is a single-valued function, defined over a
%   geometrically rectangular grid.
%
%   MESH(...,'PropertyName',PropertyValue,...) sets the value of
%   the specified surface property.  Multiple property values can be set
%   with a single statement.
%
%   MESH(AX,...) plots into AX instead of GCA.
%
%   MESH returns a handle to a surface plot object.
%
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING, HIDDEN and VIEW set figure,
%   axes, and surface properties which affect the display of the mesh.
%
%   Backwards compatibility
%   MESH('v6',...) creates a surface object instead of a surface plot
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   See also SURF, MESHC, MESHZ, WATERFALL.

%-------------------------------
%   Additional details:
%
%   MESH sets the FaceColor property to background color and the EdgeColor
%   property to 'flat'.
%
%   If the NextPlot axis property is REPLACE (HOLD is off), MESH resets 
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and 
%   text objects).

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.14.4.4 $  $Date: 2004/02/01 22:03:09 $

%   J.N. Little 1-5-92
%   Modified 2-3-92, LS.

[v6,args] = usev6plotapi(varargin{:});
[cax,args,nargs] = axescheck(args{:});

user_view = 0;
cax = newplot(cax);
hparent = get(cax,'parent');
fc = get(cax,'color');
if strcmpi(fc,'none')
  if isprop(hparent,'Color')
   fc = get(hparent,'Color');
  elseif isprop(hparent,'BackgroundColor')
   fc = get(hparent,'BackgroundColor');
  end
end

[reg, prop]=parseparams(args);
nargs=length(reg);

error(nargchk(1,4,nargs));
if rem(length(prop),2)~=0,
   error('Property value pairs expected.')
end
   
if nargs == 1
   x=reg{1};
   if v6
       hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
           'FaceLighting','none','EdgeLighting','flat','parent',cax);
   else
       hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
           'FaceLighting','none','EdgeLighting','flat','parent',cax);   
   end
elseif nargs == 2
   [x,y]=deal(reg{1:2});
   if isstr(y), error('Invalid argument.'); end
   [my ny] = size(y);
   [mx nx] = size(x);
   if mx == my & nx == ny
      if v6 
          hh = surface(x,y,'FaceColor',fc,'EdgeColor','flat', ...
                 'FaceLighting','none','EdgeLighting','flat','parent',cax);
      else
          hh = graph3d.surfaceplot(x,y,'FaceColor',fc,'EdgeColor','flat', ...
                 'FaceLighting','none','EdgeLighting','flat','parent',cax);
      end
   else
      if my*ny == 2 % must be [az el]
         if v6
             hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
                          'FaceLighting','none','EdgeLighting','flat','parent',cax);
         else
             hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
                          'FaceLighting','none','EdgeLighting','flat','parent',cax);         
         end
         set(cax,'View',y);
         user_view = 1;
      else
         error('Invalid input arguments.');
      end
   end
elseif nargs == 3
   [x,y,z]=deal(reg{1:3});
   if isstr(y) | isstr(z), error('MATLAB:graph3d:mesh','Invalid argument.'); end
   if min(size(y)) == 1 & min(size(z)) == 1 % old style
      if v6
          hh = surface(x,'FaceColor',fc,'EdgeColor','flat', ...
                       'FaceLighting','none','EdgeLighting','flat','parent',cax);
      else
          hh = graph3d.surfaceplot(x,'FaceColor',fc,'EdgeColor','flat', ...
                       'FaceLighting','none','EdgeLighting','flat','parent',cax);      
      end
      set(cax,'View',y);
      user_view = 1;
   else
      if v6
           hh = surface(x,y,z,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',cax);
      else
           hh = graph3d.surfaceplot(x,y,z,'FaceColor',fc,'EdgeColor','flat', ...
                'FaceLighting','none','EdgeLighting','flat','parent',cax);      
      end
   end
elseif nargs == 4
   [x,y,z,c]=deal(reg{1:4});
   if v6
       hh = surface(x,y,z,c,'FaceColor',fc,'EdgeColor','flat', ...
                   'FaceLighting','none','EdgeLighting','flat','parent',cax);
   else
       hh = graph3d.surfaceplot(x,y,z,c,'FaceColor',fc,'EdgeColor','flat', ...
                   'FaceLighting','none','EdgeLighting','flat','parent',cax);   
   end
end
if ~isempty(prop),
   set(hh,prop{:})       
end 
if ~ishold(cax) && ~user_view
   view(cax,3); grid(cax,'on');
end
if nargout == 1
   h = double(hh);
end
