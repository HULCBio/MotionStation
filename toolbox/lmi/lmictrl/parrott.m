% [gmin,x]=parrott(a,b,c,rx,cx,g);
%
% Given matrices A,B,C and G > 0, computes a matrix X such that
%
%	   	 || A   B ||
%    	   	 ||       ||	 <  G
%		 || C   X ||2
%
% (the 2-norm is the largest singular value norm). This problem
% is solvable if and only if
%				               T   T
%    G >=  GMIN := MAX ( || (A , B) || , || (A , C ) || )
%
% Input:
%   A,B,C      real matrices of compatible dimensions.
%	       A can be the empty matrix [].
%   RX,CX      row and column dimensions of XMIN (optional if A
%	       is not empty)
%   G          target value for the norm (GMIN by default)
%
% Output:
%   GMIN       least achievable norm
%   X          solution given by
%                                   2      T  -1  T
%     			X  = - C ( G  I - A A)   A B


% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [gmin,x]=parrott(a,b,c,rx,cx,g);


TOLA=sqrt(mach_eps);
% threshold used to discard near singularities in gs I - A'*A

[ra,cb]=size(b); [rc,ca]=size(c);
if ra>0, nab=norm([a b]); else nab=0; end
if ca>0, nac=norm([a;c]); else nac=0; end
gmin=max(nab,nac);


if nargin < 6,
  g=gmin;
elseif g < gmin,
  x=[]; return
end



% MONITOR LIMIT CASES
if ra==0 | ca == 0,    % A is empty
  if nargin < 5,
     error('The dimensions RX,CX of X must be specified when A=[]');
  else
     x=zeros(rx,cx);
  end

else
  % COMPUTE X IN NONTRIVIAL CASES
  if g == 0,
     x=zeros(rc,cb);
  else
     x=[c,zeros(rc,ra)]*pinv([g*eye(ca),a';a,g*eye(ra)],TOLA)*...
          [zeros(ca,cb);b];
  end

end
