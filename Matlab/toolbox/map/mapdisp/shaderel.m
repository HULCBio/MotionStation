function [rgbindx,rgbmap,clim] = shaderel(X,Y,Z,rgbs,s,cmaplen,clim)

% SHADEREL Construct cdata and colormap for colored shaded relief
%
%
%  [cindx,cimap,clim] = SHADEREL(X,Y,Z,cmap) constructs the colormap and
%  color indices to allow a surface to be displayed in colored shaded relief.
%  The colors are proportional to the magnitude of Z, but modified by shades
%  of gray based on the surface normals, as if the surface were lighted.
%  This representation allows both large and small-scale differences to be
%  seen.  X, Y and Z define the surface.  cmap is the small colormap which
%  will be used as the basis for the output rgbmap colormap.  The number of
%  gray levels is chosen to give a final colormap with a length of less than
%  256.  By default, shading is for a light at an elevation of 45 degrees and
%  an azimuth of 90 (as if the light was an infinite distance away).  cindex
%  is a matrix which can be used as cdata in a surface command.  cimap is the
%  colormap into which the elements of cindx are indices.  clim is a vector
%  of color limits for use in a caxis command.
%
%  [cindx,cimap,clim] = SHADEREL(X,Y,Z,cmap,[azim elev]) places the light at
%  the specified azimuth and elevation.
%
%  [cindx,cimap,clim] = SHADEREL(X,Y,Z,cmap,[azim elev],cmaplen) choses the
%  number of grays to give a cimap of length cmaplen.  If the vector of
%  azimuth and elevation is empty, the default locations are used.
%
%  [cindx,cimap,clim] = SHADEREL(X,Y,Z,cmap,[azim elev],cmaplen,clim) uses
%  the color limits to index Z into cmap, as if a CAXIS command had been
%  used.
%
%
%  See also MESHLSRM, SURFLSRM, COLORMAP, CAXIS, SURFACE, LIGHT


%  Copyright 1996-2003 The MathWorks, Inc.
% Written by:  A. Kim, W. Stumpf
% $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:22:44 $


% check number of arguments and set defaults

if nargin <= 3;             error('Incorrect number of arguments')
     elseif nargin == 4;    s  = [];    cmaplen = [];     clim = [];
     elseif nargin == 5;    cmaplen = [];     clim = [];
     elseif nargin == 6;    clim = [];
end % if



%  Default inputs

if isempty(s);             azim = 90;      elev = 45;
  elseif length(s) ~= 2    error('Light source vector must consist of azimuth and elevation');
  else                     azim = s(1);    elev = s(2);
end

if isempty(cmaplen);       cmaplen = 256;   end

if isempty(clim);          cmin = min(Z(:));     cmax = max(Z(:));
   else;                   cmin = min(clim(:));  cmax = max(clim(:));
end



% set up sizes of colormaps

Nrgbs = length(rgbs(:,1));

if length(cmaplen) > 256; error('Colormap length must be less than 256'); end
if length(Nrgbs)    > 256; error('RGB colormap length must be less than 256'); end


Ngrays = floor(cmaplen/Nrgbs);

imin=0.2; imax=0.8;
grays = imin + (imax-imin)*[0:Ngrays-1]'/(Ngrays-1);


% concatenate progressively darker versions of the input colormap

rgbmap = [];
for n=1:Ngrays
	rgbband = rgbs;
	if grays(n)<=0.5
		rgbband = rgbs.*grays(n)/0.5;
	else
		rgbband = rgbs + (1 - rgbband).*(grays(n)-0.5)/0.5;
	end
	rgbmap = [rgbmap; rgbband];
end

%  Build rgb index matrix


[Nx,Ny,Nz] = surfnorm(X,Y,Z);

d2r = pi/180; theta = elev*d2r; psi = azim*d2r;
St = sin(theta); Ct = cos(theta); Sp = sin(psi); Cp = cos(psi);
g = Nx*Ct*Sp + Ny*Ct*Cp + Nz*St;
clear Nx Ny Nz

gmin = min(min(g));
gmax = max(max(g));

gindx = floor(1 + (g-gmin)*Ngrays/(gmax-gmin));
gindx(find(gindx<1)) = 1;
gindx(find(gindx>Ngrays)) = Ngrays;

zindx = floor(1 + (Z-cmin)*Nrgbs/(cmax-cmin));
zindx(find(zindx>Nrgbs)) = Nrgbs;

rgbindx = Nrgbs*(gindx-1) + zindx;

clim = [1 Nrgbs*Ngrays];
