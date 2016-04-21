function [R,S,E,Flags,OldSyntax] = arecheckin(A,B,Q,varargin)
% Checks input arguments to CARE and DARE.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:13:51 $

% Flags
isFlag = cellfun('isclass',varargin,'char');
Flags = varargin(:,isFlag);
OldSyntax = strncmpi(Flags,'i',1);
Flags(OldSyntax) = {'factor'};
OldSyntax = any(OldSyntax);

% Extra numeric arguments
[n,m] = size(B);
varargin = varargin(~isFlag);
ni = length(varargin);
if ni<1 || isempty(varargin{1})
   R = eye(m);
else
   R = varargin{1};
end
if ni<2 || isempty(varargin{2})
   S = zeros(n,m);
else
   S = varargin{2};
end
if ni<3 || isempty(varargin{3})
   E = eye(n);
else
   E = varargin{3};
end

% Size of A,E,B,S
if any(size(A)~=n)
   error('A must be square and have the same number of rows as B.')
elseif any(size(E)~=n),
   error('E and A must be the same size.')
elseif any(size(S)~=[n m]),
   error('S and B must be the same size.')
end

% Check that Q and R are the correct size and symmetric
if any(size(Q) ~= n),
   error('A and Q must be the same size.')
elseif norm(Q-Q',1) > 100*eps*norm(Q,1),
   error('Q must be symmetric.')
else
   Q = (Q+Q')/2;
end

if any(size(R) ~= m),
   error('R must be a square matrix with as many columns as the B matrix.')
elseif norm(R-R',1) > 100*eps*norm(R,1),
   error('R must be symmetric.')
else
   R = (R+R')/2;
end