function camroll(arg1, arg2)
%CAMROLL Roll camera.
%   CAMROLL(DTHETA) rolls the camera of the current axes DTHETA
%   degrees clockwise around the line which passes through the camera
%   position and camera target.
%   CAMROLL(AX, DTHETA) uses axes AX instead of the current axes.
%
%   CAMROLL sets the CameraUpVector property of an axes.
%
%   See also CAMORBIT, CAMPAN, CAMZOOM, CAMDOLLY.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:28:13 $

if nargin==1
  ax = gca;
  dtheta = arg1;
elseif nargin==2
  ax = arg1;
  dtheta = arg2;
else
  error('Wrong number of arguments')
end

cpSave  = get(ax, 'cameraposition' );
ctSave  = get(ax, 'cameratarget'   );
upSave  = get(ax, 'cameraupvector' );

if ~righthanded(ax), dtheta = -dtheta; end

v = (ctSave-cpSave);
v = v/norm(v);
alph = (dtheta)*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = v(1);
y = v(2);
z = v(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
       x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
       x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

r = crossSimple(v, upSave);
u = crossSimple(r, v);

newUp = u*rot;
upSave = newUp/norm(newUp);
set(ax, 'cameraupvector', upSave);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);

