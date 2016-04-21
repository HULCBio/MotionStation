function [ip,pa,pb,dist] = Vector_Vector_Intersection(v1,p1,v2,p2)
%
%  [ip,pa,pb] = Vector_Vector_Intersection(v1,p1,v2,p2)
%
%   Input: line1 defined by vector v1 and point p1 and 
%   line2 defined by vector v2 and point p2. 
%   Output: intersection ip and points pa and pb on shortest line 
%   segment connecting line1 and line2.

%   Solves:
%        pa = p1 + mua (v1) 
%        pb = p2 + mub (v2)
%
%   Author: Louis Ferreira (Louis.Ferreira@sjhc.london.on.ca)
%   Date:   October 11, 2007
%   This is a modified version of a LineLineIntersect function
%   authored by Cristian Dima (csd@cmu.edu) which was a conversion to MATLAB of 
%   the C code posted by Paul Bourke at
%   http://astronomy.swin.edu.au/~pbourke/geometry/lineline3d/



p12 = p1 - p2;

Dp12v2 = p12(1) * v2(1) + p12(2) * v2(2) + p12(3) * v2(3);
Dv2v1 = v2(1) * v1(1) + v2(2) * v1(2) + v2(3) * v1(3);
Dp12v1 = p12(1) * v1(1) + p12(2) * v1(2) + p12(3) * v1(3);
Dv2v2 = v2(1) * v2(1) + v2(2) * v2(2) + v2(3) * v2(3);
Dv1v1 = v1(1) * v1(1) + v1(2) * v1(2) + v1(3) * v1(3);

denom = Dv1v1 * Dv2v2 - Dv2v1 * Dv2v1;

numer = Dp12v2 * Dv2v1 - Dp12v1 * Dv2v2;

mua = numer / denom;
mub = (Dp12v2 + Dv2v1 * mua) / Dv2v2;

pa = p1 + mua * v1;
pb = p2 + mub * v2;
ip = (pa + pb) / 2;
dist = (sum((pa-pb).^2))^0.5  %Euclidean distance