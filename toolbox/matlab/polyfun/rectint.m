function out = rectint(A, B)
%RECTINT Rectangle intersection area.
%   AREA = RECTINT(A,B) returns the area of intersection of the
%   rectangles specified by position vectors A and B.  
%
%   If A and B each specify one rectangle, the output AREA is a scalar.
%
%   A and B can also be matrices, where each row is a position vector.
%   AREA is then a matrix giving the intersection of all rectangles
%   specified by A with all the rectangles specified by B.  That is, if A
%   is M-by-4 and B is N-by-4, then AREA is an M-by-N matrix where
%   AREA(P,Q) is the intersection area of the rectangles specified by the
%   Pth row of A and the Qth row of B.
%
%   Note:  A position vector is a four-element vector [X,Y,WIDTH,HEIGHT],
%   where the point defined by X and Y specifies one corner of the
%   rectangle, and WIDTH and HEIGHT define the size in units along the x-
%   and y-axes respectively.
%
%   Class support for inputs A,B: 
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/03/02 21:48:03 $

leftA = A(:,1);
bottomA = A(:,2);
rightA = leftA + A(:,3);
topA = bottomA + A(:,4);

leftB = B(:,1)';
bottomB = B(:,2)';
rightB = leftB + B(:,3)';
topB = bottomB + B(:,4)';

numRectA = size(A,1);
numRectB = size(B,1);

leftA = repmat(leftA, 1, numRectB);
bottomA = repmat(bottomA, 1, numRectB);
rightA = repmat(rightA, 1, numRectB);
topA = repmat(topA, 1, numRectB);

leftB = repmat(leftB, numRectA, 1);
bottomB = repmat(bottomB, numRectA, 1);
rightB = repmat(rightB, numRectA, 1);
topB = repmat(topB, numRectA, 1);

out = (max(0, min(rightA, rightB) - max(leftA, leftB))) .* ...
    (max(0, min(topA, topB) - max(bottomA, bottomB)));
