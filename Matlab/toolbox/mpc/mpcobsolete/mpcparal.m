function [aa,bb,cc,dd] = mpcparal(a1,b1,c1,d1,a2,b2,c2,d2)

%MPCPARAL  Parallel connection of two state-space systems.
%	[A,B,C,D] = MPCPARAL(A1,B1,C1,D1,A2,B2,C2,D2)  produces a state-space
%	system consisting of the parallel connection of systems 1 and 2
%	such that Y = Y1 + Y2.  The resulting system is:
%		 .
%		|x1| = |A1 0| |x1| + |B1 0| |u1|
%		|x2|   |0 A2| |x2| + |0 B2| |u2|
%
%		|y| = y1+y2 = |C1 C2| |x1| + |D1 D2| |u1|
%				                    |x2|           |u2|
%
%NOTE:  Same as old version of PARALLEL in the Control Toolbox.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

[ma1,na1] = size(a1);
[md1,nd1] = size(d1);
[ma2,na2] = size(a2);
[md2,nd2] = size(d2);
aa = [a1 zeros(ma1,na2);zeros(ma2,na1) a2];
bb = [b1 zeros(ma1,nd2);zeros(ma2,nd1) b2];
cc = [c1 c2];
dd = [d1 d2];