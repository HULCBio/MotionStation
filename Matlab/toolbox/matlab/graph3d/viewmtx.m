function a=viewmtx(az,el,phi,target)
%VIEWMTX View transformation matrix.
%   A=VIEWMTX(AZ,EL) returns the 4x4 orthographic transformation 
%   matrix, A, used to project 3-D vectors onto the 2-D plot surface. 
%   Uses the same definition for azimuth and elevation as VIEW, in
%   particular, AZ and EL must be in degrees.  Returns the same 
%   transformation matrix as the commands
%           VIEW(AZ,EL)
%           A = VIEW
%   but doesn't change the current VIEW.
%
%   A=VIEWMTX(AZ,EL,PHI) returns a 4x4 perspective transformation
%   matrix used to project 3-D vectors onto the 2-D plot surface.
%   PHI is the subtended view angle of the normalized plot cube 
%   (in degrees) and controls the amount of perspective distortion:
%           PHI =  0 degrees is orthographic projection
%           PHI = 10 degrees is like a telephoto lens
%           PHI = 25 degrees is like a normal lens
%           PHI = 60 degrees is like a wide angle lens
%   The matrix A can be used to set the view transformation using
%   VIEW(A).
%
%   A=VIEWMTX(AZ,EL,PHI,XC) returns the perspective transformation
%   matrix using XC as the target (or look-at) point within
%   the normalized plot cube.  XC=[xc,yc,zc] specifies the 
%   point (xc,yc,zc) in the plot cube.  The default value is
%   the closest point in the plot cube,
%
%   XC = 0.5+sqrt(3)/2*[cos(EL)*sin(AZ),-cos(EL)*cos(AZ),sin(EL)].
%
%   See also VIEW.

%   Clay M. Thompson 5-1-91
%   Revised 12-17-91, 3-10-92 by CMT
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:27:55 $

error(nargchk(2,4,nargin));

if nargin==2, phi = 0; end
if nargin>2,
   if phi>0,  d = sqrt(2)/2/tan(phi*pi/360); else, phi = 0; end
end

% Make sure data is in the correct range.
el = rem(rem(el+180,360)+360,360)-180; % Make sure -180 <= el <= 180
if el>90,
  el = 180-el;
  az = az + 180;
elseif el<-90,
  el = -180-el;
  az = az + 180;
end
az = rem(rem(az,360)+360,360); % Make sure 0 <= az <= 360

% Convert from degrees to radians.
az = az*pi/180;
el = el*pi/180;

if nargin>3,
  target = target(:);    % Make sure its a vector.
  if length(target)~=3
    error('XC must be a 3-vector of [x,y,z] values.');
  end
else
  target = 0.5 + sqrt(3)/2*[cos(el)*sin(az);-cos(el)*cos(az);sin(el)];
end

% View transformation matrix:
% Formed by composing two rotations:
%   1) Rotate about the z axis -AZ radians
%   2) Rotate about the x axis (EL-pi/2) radians

T = [ cos(az)           sin(az)           0       0
     -sin(el)*sin(az)   sin(el)*cos(az)   cos(el) 0
      cos(el)*sin(az)  -cos(el)*cos(az)   sin(el) 0
      0                 0                 0       1 ];

if nargin==2 | phi==0, a = T; return, end % Return orthographic transformation.

f = d;    % Default focal length.

% Transformation to move origin of object coordinate system to TARGET
O1 = [eye(4,3),T*[-target;1]];

% Perspective transformation
P = [1 0 0 0;
     0 1 0 0;
     0 0 1 0;
     0 0 -1/f d/f];

% The perspective transformation above works because the graphics
% system divides by the homogenous length, w, before mapping to the screen.
% If the homegeous vector is given by V = [x,y,z,w] then the transformed
% point is U = [x/w y/w].

% Using f = d places the image plane through the origin of the object 
% coordinate system, thus projecting the object onto this plane.  Note only
% the x and y coordinates are used to draw the object in the graphics window.

% Form total transformation
a=P*O1*T;





