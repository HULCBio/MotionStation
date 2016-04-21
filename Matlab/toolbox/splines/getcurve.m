function [xy, spcv] = getcurve 
%GETCURVE  Interactive creation of a cubic (spline) curve.
%
%   [xy, spcv] = getcurve;  asks for a point sequence to be specified
%   by mouse clicks on a grid provided.
%   The points picked are available in the array XY.
%   The spline curve is available in SPCV.
%   A closed curve will be drawn if the first and last point are
%   sufficiently close to each other.
%   Repeated points create a corner in the curve.

%   cb 13mar97, 23mar97, 16nov97, 23nov97, 31jul98, 14jun99
%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
% $Revision: 1.11 $

w = [-1 1 -1 1];  % start with the unit square
clf, axis(w), hold on, grid on

title('Use mouse clicks to pick points INSIDE the gridded area.')
pts = line('Xdata',NaN,'Ydata',NaN,'marker','o','erase','none');

maxpnts = 100; xy = zeros(2,maxpnts);
while 1
   for j=1:maxpnts
      [x,y] = ginput(1);
      if x<w(1)|x>w(2)|y<w(3)|y>w(4), break, end
      xy(:,j) = [x;y];
      if j>1
         set(pts,'Xdata',xy(1,[j-1 j]),'Ydata',xy(2,[j-1 j]))
      else
         set(pts,'Xdata',x,'Ydata',y)
         xlabel('When you are done, click OUTSIDE the gridded area.')
      end
      drawnow
   end
   if j>1, break, end
   xlabel(' You need to click INSIDE the gridded area at least once')
end 

title(' ')
xlabel(' done ')
xy(:,j:maxpnts)=[];
if norm(xy(:,1)-xy(:,j-1))<.05, xy(:,j-1)=xy(:,1); end
set(pts,'Xdata',xy(1,:),'Ydata',xy(2,:),'erase','xor','linestyle','none')
spcv = cscvn(xy); fnplt(spcv), hold off
