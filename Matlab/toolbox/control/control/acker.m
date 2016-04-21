function k = acker(a,b,p)
%ACKER  Pole placement gain selection using Ackermann's formula.
%
%   K = ACKER(A,B,P)  calculates the feedback gain matrix K such that
%   the single input system
%           .
%           x = Ax + Bu 
%
%   with a feedback law of  u = -Kx  has closed loop poles at the 
%   values specified in vector P, i.e.,  P = eig(A-B*K).
%
%   Note: This algorithm uses Ackermann's formula.  This method
%   is NOT numerically reliable and starts to break down rapidly
%   for problems of order greater than 10, or for weakly controllable
%   systems.  A warning message is printed if the nonzero closed-loop
%   poles are greater than 10% from the desired locations specified 
%   in P.
%
%   See also  PLACE.

%   Algorithm is from page 201 of:
%   Kailath, T.  "Linear Systems", Prentice-Hall, 1980.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:22:29 $

error(nargchk(3,3,nargin));
[msg,a,b]=abcdchk(a,b); error(msg);

[m,n] = size(b);
if n ~= 1
    error('System must be single input');
end
p = p(:);       % Make sure roots are in a column vector
[mp,np] = size(p);
[m,n] = size(a);
if (m ~= mp)
    error('Vector P must have SIZE(A) elements');
end

% Form gains using Ackerman's formula
k = ctrb(a,b)\polyvalm(real(poly(p)),a);
k = k(n,:);

% Check results. Start by removing 0.0 pole locations
p = sort(p);
i = find(p ~= 0);
p = p(i);
pc = sort(eig(a-b*k));
pc = pc(i);
if max(abs(p-pc)./abs(p)) > .1
    disp('Warning: Pole locations are more than 10% in error.')
end

% end acker
