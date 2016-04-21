function [a,b,c,d] = seriesm(a1,b1,c1,d1,a2,b2,c2,d2)
%SERIES Series connection of two state-space systems.
%	[A,B,C,D] = SERIESM(A1,B1,C1,D1,A2,B2,C2,D2)  produces an
%	aggregate state-space system with the outputs of system 1 connected
%	to the inputs of system 2.  An error results if there are different
%	numbers of rows in (C1,D1) than columns in (B2,D2).

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

[ma1,na1] = size(a1);
[ma2,na2] = size(a2);
a = [a1 zeros(ma1,na2); b2*c1 a2];
b = [b1; b2*d1];
c = [d2*c1 c2];
d = d2*d1;