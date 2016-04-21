function hout=surfl(varargin)
%SURFL  3-D shaded surface with lighting.
%   SURFL(...) is the same as SURF(...) except that it draws the surface
%   with highlights from a light source.
%
%   SURFL(Z), SURFL(X,Y,Z), SURFL(Z,S), and SURFL(X,Y,Z,S) are all 
%   legal. S, if specified, is the three vector S = [Sx,Sy,Sz]
%   that specifies the direction of the light source. S can also be
%   specified in view coordinates, S = [AZ,EL].
%
%   SURFL(...,'light') produces a colored lighted surface using
%   the LIGHT object.  This produces different results than the
%   default lighting method, SURFL(...,'cdata'), which changes the
%   color data for the surface to be the reflectance of the surface.
%
%   H = SURFL(...) returns surface and light handles.
%
%   The shading is based on a combination of diffuse, specular and 
%   ambient lighting models.
%
%   The default value for S is 45 degrees counterclockwise from
%   the current view direction.  Use CLA, HOLD ON, VIEW(AZ,EL),
%   SURFL(...), HOLD OFF to plot the lighted surface with view
%   direction (AZ,EL).
%
%   The relative contributions due to ambient light, diffuse
%   reflection, specular reflection, and the specular spread
%   coefficient can be set by using five arguments
%   SURFL(X,Y,Z,S,K) where K=[ka,kd,ks,spread].
%
%   Relies on the ordering of points in the X,Y, and Z matrices
%   to define the inside and outside of parametric surfaces.
%   Try SURFL(X',Y',Z') if you don't like the results of
%   this function.  Due to the way surface normal vectors are
%   computed, SURFL requires matrices that are at least 3-by-3.
%
%   See also SURF, SHADING.

%   Clay M. Thompson 4-24-91, 6-5-96
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2002/10/24 02:11:02 $

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,6,nargs));

nin = nargs;

if isstr(args{end})
  if strcmp(args{end},'light'),
    useLight = 1;
  elseif strcmp(args{end},'cdata')
    useLight = 0;
  else
    error(sprintf('Unknown lighting method "%s".',args{end}));
  end
  nin = nin-1;
else
  useLight = 0;
end
    
if nin==1,    % Define x,y
  z = args{1};
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);
elseif nin==2,
  z = args{1};
  s = args{2};
  [m,n] = size(z);
  [x,y] = meshgrid(1:n,1:m);
elseif nin>=3,
  [x, y, z] = deal(args{1:3});
end
if nin>=4, s = args{4}; end
if nin==5, k = args{5}; end

if isstr(z) | isstr(x)
   error('Must be 1, 3 or 4 numeric input arguments.')
end

if nin<5 % Define default weighting coefficients
  k = [.55,.6,.4,10]; % Ambient,diffuse,specular,spread
end 
if length(k)~=4,
  error('Weighting vector k must have four components.');
end

[msg,x,y,z] = xyzchk(x,y,z); if ~isempty(msg), error(msg); end
if any(size(z)<[3 3]), error('X, Y, and Z must be at least 3-by-3.'); end

stencil=ones(2,2)/4;

if isempty(cax)
    cax = gca;
end
next = lower(get(cax,'NextPlot'));
if ~ishold(cax), view(cax,3); end    % Set graphics system for 3-D plot
[vaz,vel] = view(cax);
vaz = vaz*pi/180; vel = vel*pi/180; % Convert to radians

if (nin==1) | (nin==3), % Use default S
  phi = 45*pi/180;
  s = zeros(1,3);
  s(1) = cos(vaz)*sin(phi)+sin(vaz)*cos(vel)*cos(phi);
  s(2) = sin(phi)*sin(vaz)-cos(vaz)*cos(vel)*cos(phi);
  s(3) = sin(phi)*sin(vel);
else
  if (length(s)~=2) & (length(s)~=3),
    error('S must be specified using [AZ,EL] or [Sx,Sy,Sz].');
  end
end

ms = length(s(:));
if ms==2, % Compute source direction from [AZ,EL]
  az = s(1)*pi/180; el = s(2)*pi/180; % Convert to radians
  s = zeros(1,3);
  s(1) =  sin(az)*cos(el);
  s(2) = -cos(az)*cos(el);
  s(3) =  sin(el);
end

if useLight
  h = surf(cax,x,y,z);
  hl = light('position',s,'Color',[1 1 1],'Style','infinite','parent',cax);

  set(h,'AmbientStrength',k(1),'DiffuseStrength',k(2), ...
      'SpecularStrength',k(3),'SpecularExponent',k(4));
else

  % Determine plot scaling factors for a cube-like plot domain.
  h = surf(cax,x,y,z);
  a = [get(cax,'xlim') get(cax,'ylim') get(cax,'zlim')];
  Sx = a(2)-a(1);
  Sy = a(4)-a(3);
  Sz = a(6)-a(5);
  scale = max([Sx,Sy,Sz]);
  Sx = Sx/scale; Sy = Sy/scale; Sz = Sz/scale;

  % Compute surface normals.  Rely on ordering to define inside or outside.
  xx = x/Sx; yy = y/Sy; zz = z/Sz;
  [nx,ny,nz] = surfnorm(xx,yy,zz);

  % Compute Lambertian shading + specular + ambient light
  R = (k(1)+k(2)*diffuse(nx,ny,nz,s)+ ...
      k(3)*specular(nx,ny,nz,s,[vaz,vel]*180/pi,k(4)))/ sum(k(1:3));

  % Set reflectance of the surface
  set(h,'cdata',R);
  caxis(cax,[0,1]);     % Set color axis range.
  hl = [];
end

if nargout > 0
   hout = [h hl];
end
