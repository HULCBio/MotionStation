function [x4,y4] = perpxy(x1,y1,x2,y2,x3,y3)
%PERPXY Utility routine for RLOCUS.
%       [X4,Y4] = PERPXY(X1,Y1,X2,Y2,X3,Y3) outputs a point which 
%       is the nearest point to [x3,y3] on the straight line formed 
%   between [x1,x2] and [x2,y2].  RE: from basic geometry, [X4,y4]
%       will be perpendicular to line.
%   E.g.
%                         .[x1,y1]
%                          
%
%       
%                          .[x4,y4]
%           .[x3,y3]
%                 
%
%                           .[x2,y2]
%
%       i.e. (x3-x4)*(x1-x2) + (y3-y4)*(y1-y2) = 0
%            (x1-x4)*(y4-y2) - (x4-x2)*(y1-y4) = 0
 
%   A.C.W.Grace 7-9-90, Revised 3-25-93
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:50 $

% Cater for the case when the line has infinite gradient:
tol = 1e6*eps;
xeq=abs(x1-x2)<tol;   

x12=(x1-x2)+tol*(xeq);   % For speed, let's hope x1-x2 ~= tol*(xeq)
y12=(y1-y2);

x4=(x12.*(-x3.*x12-y3.*y12) + y12.*(x1.*y2-x2.*y1))./(-x12.*x12 - y12.*y12);

y4=(x1.*y2 + x4.*y12 - x2.*y1)./(x12);

y4=y4.*(~xeq)+y3.*(xeq);

% end perpxy
