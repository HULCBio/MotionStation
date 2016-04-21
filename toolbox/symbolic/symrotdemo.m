%SYMROTDEMO Study plane rotations.

%  Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.8 $  $Date: 2002/04/15 03:14:11 $

if any(get(0,'children') == 3), close(3), end
echo on
clc

% Demonstrate Symbolic Math Toolbox.

% Create a symbolic variable named t.

t = sym('t')

pause % Strike any key to continue.

% Create a 2-by-2 matrix representing a plane rotation through an angle t.

G = [ cos(t) sin(t); -sin(t) cos(t)]

pause % Strike any key to continue.
clc

% Compute the matrix product of G with itself.

G*G

pause % Strike any key to continue.

% This should represent a rotation through an angle of 2*t.
% Simplification using trigonometric identities is necessary.

ans = simple(ans)


pause % Strike any key to continue.
clc

% G is an orthogonal matrix; its tranpose is its inverse.

G.'*G

ans = simple(ans)


pause % Strike any key to continue.
clc

% What are the eigenvalues of G?

e = eig(G)

pause % Strike any key to continue.
clc

% Repeatedly apply the simplification rules.

e, for k = 1:4, e = simple(e), end


pause % Strike any key to terminate.
clc
echo off
