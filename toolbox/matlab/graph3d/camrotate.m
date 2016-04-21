function [pos, newUp]=camrotate(a,b,dar,up,dt,dp,coordsys,direction)
%CAMROTATE Camera rotation utility function.
%
%   [pos, newUp]=CAMROTATE(a,b,dar,up,dt,dp,coordsys,direction)
%
%   Utility function for rotating point a (and upvector up) 
%      around point b or line containing b.
%   If coordsys is 'camera' rotation is around point b.
%   If coordsys is 'data' rotation is around a line defined by 
%      point b and direction.
%   
%   See also CAMORBIT, CAMPAN and CAMLIGHT.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:28:15 $

v = (b-a)./dar;
r = crossSimple(v, up./dar);
u = crossSimple(r, v);

dis = norm(v);
v = v/dis;
r = r/norm(r);
u = u/norm(u);

if coordsys(1)=='d' %data
  if ischar(direction)
    if direction(1)=='x'
      direction=[1 0 0];
    elseif direction(1)=='y'
      direction=[0 1 0];
    else  % direction(1)=='z'
      direction=[0 0 1];
    end
  end
  haxis = direction/norm(direction);
else
  haxis = u;
end

vaxis = r;

deg2rad = pi/180;

alph = dt*deg2rad;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = haxis(1);
y = haxis(2);
z = haxis(3);
rotH = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
  x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
  x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

alph =-dp*deg2rad;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = vaxis(1);
y = vaxis(2);
z = vaxis(3);
rotV = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
  x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
  x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

rotHV = rotV*rotH;

newV = -v*rotHV;
newUp = u*rotHV;
pos=b+newV*dis.*dar;
newUp=newUp.*dar;



% simple cross product
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);
