function [ab,bb,cb,m,T] = dbalreal(a,b,c)
%DBALREAL Discrete balanced state-space realization and model reduction.
%   [Ab,Bb,Cb] = DBALREAL(A,B,C) returns a balanced state-space 
%   realization of the system (A,B,C).
%
%   [Ab,Bb,Cb,M,T] = DBALREAL(A,B,C) also returns a vector M 
%   containing the diagonal of the gramian of the balanced realization
%   and matrix T, the similarity transformation used to convert 
%   (A,B,C) to (Ab,Bb,Cb).  If the system (A,B,C) is normalized 
%   properly, small elements in gramian M indicate states that can be
%   removed to reduce the model to lower order.
%
%   See also DMODRED, BALREAL and MODRED.

%   J.N. Little 3-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:34:49 $

error(nargchk(3,3,nargin));
[sys,m,Ti,T] = balreal(ss(a,b,c,zeros(size(c,1),size(b,2)),-1));
[ab,bb,cb] = ssdata(sys);

% end dbalreal
