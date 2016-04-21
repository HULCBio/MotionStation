function [maximum,err]=quad2(pts)
%QUAD2  Quadraticly interpolates three points to find the maximum value.
%   QUAD2(PTS) interpolates the 3 element vector PTS to find the maximum.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/02/07 19:13:49 $

c=pts(1);
ab=[-1 0.5; 2 -0.5]*(pts(2:3)-c*ones(2,1));
stepmin=-ab(2)/(2*ab(1));
maximum=ab(1)*stepmin^2+ab(2)*stepmin+c;
