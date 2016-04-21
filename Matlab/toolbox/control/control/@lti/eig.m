function v = eig(sys)
%EIG  Find the poles of an LTI system.
%
%   P = EIG(SYS)  returns the poles of SYS  (P is a column vector).
%
%   For state-space models, the poles are the eigenvalues of the A 
%   matrix or the generalized eigenvalues of the (A,E) pair in the 
%   descriptor case.
%
%   See also  DAMP, ESORT, DSORT, PZMAP, TZERO.

%       Author(s): A. Potvin, 3-1-94, 11-10-95, P. Gahinet, 5-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $  $Date: 2002/04/10 05:51:07 $

% Call POLE
v = pole(sys);

% end ../@lti/eig.m
