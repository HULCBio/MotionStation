function [a,b,c,d] = dtf2ss(num, den)
%DTF2SS Discrete transfer function to state-space conversion.
%   [A,B,C,D] = DTF2SS(NUM,DEN)  calculates the state-space representation:
%
%       x(n+1) = Ax(n) + Bu(n)
%         y(n) = Cx(n) + Du(n) 
%
%   of the system:
%               NUM(z) 
%       H(s) = -------
%               DEN(z)
%
%   from a single input.  Vector DEN must contain the coefficients of the 
%   denominator in ascending  powers of z^-1 (constant first).  
%   Uses the Signal Processing Toolbox representation of a discrete
%   transfer function and therefore pads with trailing zeros
%   for unassigned coefficients.
%   Matrix NUM must contain the 
%   numerator coefficients with as many rows as there are outputs y.  The
%   A,B,C,D matrices are returned in controller canonical form.   

%   A.C.W.Grace 4-5-90  
%   Revised ACWG 5-29-91, AFP 4-5-94
%
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

[dn,dm] = size(den);
[nn,nm] = size(num);

% Pad numerator and denominator with trailing zeros if necessary
dm_nm = dm-nm;
num = [num zeros(nn,dm_nm)];
den = [den zeros(dn,-dm_nm)];

% Let tf2ss sort everything else out
[a,b,c,d] = tf2ss(num,den);

% end dtf2ss
