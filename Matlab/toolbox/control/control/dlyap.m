function X = dlyap(A, B, C, E)
%DLYAP  Solve discrete Lyapunov equations.
%
%   X = DLYAP(A,Q) solves the discrete Lyapunov matrix equation:
%
%       A*X*A' - X + Q = 0
%
%   X = DLYAP(A,B,C) solves the Sylvester equation:
%
%       A*X*B - X + C = 0
%
%   X = DLYAP(A,Q,[],E) solves the generalized discrete Lyapunov equation:
%
%       A*X*A' - E*X*E' + Q = 0
%
%   See also DLYAPCHOL, LYAP.

%	J.N. Little 2-1-86, AFP 7-28-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12.4.2 $  $Date: 2002/11/11 22:21:12 $
%  DLYAP is based on the SLICOT routines SB03MD, SG03AD, and SB04QD.

ni = nargin;
error(nargchk(2,4,ni))
if ~isnumeric(A) || ~isnumeric(B) || ...
      (ni>2 && ~isnumeric(C)) || (ni>3 && ~isnumeric(E))
   error('DLYAP expects double arrays as inputs.')
end
if ni<4
   E = [];
elseif ~isequal(B,B')
   error('Second argument Q must be symmetric when E matrix is specified.')
elseif ~isreal(A) || ~isreal(B) || ~isreal(E)
   error('Cannot solve equation with complex data and E matrix.')
end
   
% Balancing (minimize spectrum distorsions in Hess/Schur/QZ factorizations)
try
   if ni==3
      [sA,pA,A] = balance(A);
      [sB,pB,B] = balance(B);
      C(pA,pB) = lrscale(C,1./sA,sB);  % TA\C*TB
   else
      [A,E,s,p] = aebalance(A,E);
      B(p,p) = lrscale(B,1./s,1./s);  % T\B/T'
   end
end

% Solve equation
try
   if ni==3
      % Sylvester equation A*X*B-X+C=0
      % Call SLICOT routine SB04QD or complex equivalent
      X = sylvslv('D',A,-B,C);
      X = lrscale(X(pA,pB),sA,1./sB);  % TA*X/TB
   else
      if isequal(B,B')
         % Lyapunov equation A*X*A'-X+B=0 or A*X*A'-E*X*E'+B=0
         % Call SLICOT routine SB03MD (E=[]) or SG03AD (descriptor, real)
         X = lyapslv('D',A,E,-B);
      else
         % Sylvester equation A*X*A'-X+B=0 with B non symmetric
         % Call SLICOT routine SB04QD or complex equivalent
         X = sylvslv('D',A,-A',B);
      end
      X = lrscale(X(p,p),s,s);  % T*X*T' using T(:,p)=diag(s)
   end
catch
   rethrow(lasterror)
end