function camlookat(h)
%CAMLOOKAT Move camera and target to view specified objects.
%   CAMLOOKAT(H)  views the objects in vector H.
%   CAMLOOKAT(AX) views the objects which are children of axes AX.
%   CAMLOOKAT     views the objects which are children current axes.
%   
%   CAMLOOKAT moves the camera position and camera target preserving 
%   the relative view direction and camera view angle.  The object 
%   (or objects) being viewed roughly fill the axes position 
%   rectangle.
%
%   See also CAMORBIT, CAMPAN, CAMZOOM, CAMROLL, CAMPOS.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/10 23:26:46 $

if nargin == 0
  h = gca;
end

if length(h) == 0
  return
else
  for k = 1:length(h)
    if ~ishandle(h(k)) | h(k) == 0
      error('H must be a vector of axes children or an axes')
    end
    
    ax = ancestor(h(k), 'axes');

    if isempty(ax)
      error('H must be a vector of axes children or an axes')
    end
  end
end

bounds = objbounds(h);

if isempty(bounds)
  return
end

if ~iscameraobj(ax)
  return
end

dar = daspect(  ax);
cp  = campos(   ax);
ct  = camtarget(ax);
cva = camva(    ax);

cp = cp./dar;
ct = ct./dar;

camd = (cp-ct);
camd = camd/norm(camd);

ct = sum(reshape(bounds,2,3)/2)./dar;
cp = ct + camd;

tancva = 1/tan(cva*pi/180/2);

% For all 8 points on the 3D bounding box, first find the point on
% the view ray in the plane of the boxpoint and the view
% direction. Then, calculate the distance between the view ray and
% the boxpoint. Finally, calculate a new camperaposition.
% Evaluate the 8 solutions by using the one which is furthest along
% the view ray.
for j = 0:7
  boxpt = [bounds(1+~~bitand(j,1)) bounds(3+~~bitand(j,2)) bounds(5+~~bitand(j,4))]./dar;
  linept = lineplaneintersect(cp, ct, boxpt, camd);
  newcp(j+1,:) = linept + pttolinedist(boxpt, cp, ct)*tancva*camd;
  
  ev(j+1) = sum(camd.*newcp(j+1,:));
end

index = find(ev == max(ev));
cp = newcp(index(1),:);

camtarget(ax,ct.*dar);
campos(ax,cp.*dar);
camva(ax, cva);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pt = lineplaneintersect(p1, p2, planept, planenorm)
% finds the point of intersection between a line and a plane
d = -sum(planept.*planenorm);
e1 = sum(p1.*planenorm) + d;
e2 = sum(p2.*planenorm) + d;

diff = p2-p1;
w = e1/(e1-e2);

pt = p1+w*diff;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = pttolinedist(v,l1,l2)
%finds the distance between a point and a line
a = l2-l1;
n = crossSimple(v-l1, l1-l2);
d = sqrt(sum(n.*n)/sum(a.*a));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = iscameraobj(haxes)
% Checking if the selected axes is for a valid object to perform camera functions on.

val = ~isappdata(haxes,'NonDataObject');
