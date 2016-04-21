% sys = ltisys(a,b,c,d,e)
% sys = ltisys('tf',n,d)
%
% Stores the state-space realization (A,B,C,D,E) of an LTI system
% as the SYSTEM matrix
%
%                       | A+j(E-I)   B   na  |
%             SYS  =    |    C       D    0  |
%                       |    0       0  -Inf |
%
% where  na = size(A,1).  The matrices A through E should be real.
% When omitted, D and E are set to the default values  D=0  and
% E=I.  The values 0 and 1 for E are interpreted as E=0  and  E=I.
%
% SYS = LTISYS(A)  and  SYS = LTISYS(A,E)  specify the autonomous
% systems
%               dx/dt = A x     and     E dx/dt = A x .
%
%
% SISO systems can also be specified via their transfer function
% N(s)/D(s).  The syntax is then   SYS = LTISYS('tf',N,D)  where
% N and D are the vector representation of the polynomials N(s)
% and D(s).
%
%
% See also  LTISS, LTITF, SINFO.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=ltisys(a,b,c,d,e)

if nargin < 1,
  error('usage: sys = ltisys(a,b,c,d,e)  or  sys = ltisys(''tf'',n,d)');
elseif isstr(a),
  if nargin~=3,
    error('For transfer functions, the syntax is  sys = ltisys(''tf'',n,d)');
  end
  [a,b,c,d]=tf2ss(b,c);
  sys=sbalanc(ltisys(a,b,c,d));
  return
elseif size(a,1)~=size(a,2),
  error('A must be square when not a string');
end

if nargin==2, e=b; elseif nargin==3, d=zeros(size(c,1),size(b,2)); end
if any(nargin==[1 3 4]), e=1; end
if nargin<3, b=[]; c=[]; d=[]; end
fulls=~(isempty(b) | isempty(c) | isempty(d));

if size(e)==[1 1],
  e=e*eye(size(a));
elseif any(size(e)~=size(a)),
  error('A and E are not of compatible dimensions');
end

if isempty(a) & isempty(d),
  error('All matrices are empty');
elseif ~isreal([a(:);b(:);c(:);d(:);e(:)]),
  error('A,B,C,D,E must be real matrices');
elseif fulls,
  if size(a,1)~=size(b,1)
    error('A and B are not of compatible dimensions');
  elseif size(a,2)~=size(c,2)
    error('A and C are not of compatible dimensions');
  elseif size(c,1)~=size(d,1)
    error('C and D are not of compatible dimensions');
  elseif size(b,2)~=size(d,2)
    error('B and D are not of compatible dimensions');
  end
end



if nargin<=2,
   sys=a+sqrt(-1)*(e-eye(size(a)));
elseif nargin < 5,
   sys=[a,b;c,d];
else
   sys=[a+sqrt(-1)*(e-eye(size(a))),b;c,d];
end
[rp,cp]=size(sys);

sys(1,cp+1)=size(a,1);
sys(rp+1,cp+1)=-Inf;
