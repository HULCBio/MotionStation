function pmod=ss2mod(a,b,c,d,minfo,x0,u0,y0,f0)

%SS2MOD Convert a state-space model to MPC mod format
% 	pmod = ss2mod(phi,gam,c,d)
% 	pmod = ss2mod(phi,gam,c,d,minfo)
% 	pmod = ss2mod(phi,gam,c,d,minfo,x0,u0,y0,f0)
%
% Inputs:
%  phi,gam,c,d : state-space matrices
%  minfo       : a ROW vector containing the following information:
%
%           minfo(1) = dt, the sampling period.
%                (2) = n, the system order (dimension of "a").
%                (3) = nu, the number of manipulated inputs.
%                (4) = nd, the number of measured disturbances.
%                (5) = nw, the number of unmeasured disturbances.
%                (6) = nym, the number of measured outputs.
%                (7) = nyu, the number of unmeasured outputs.
%
%  x0,u0,y0,f0 : linearization conditions (optional).  All default
%                to zero.
%
% Output:
%  mod   : model in MPC mod format
%
% See also MOD2SS.
%
%  NOTE:  minfo is optional.  If not supplied or = [], a model
%         is created with dt=1, [n,nu]=size(GAM), nd=nw=0,
%         [nym,n]=size(C), and nyu=0.  If minfo is a scalar, the
%         resulting model will have dt=minfo, [n,nu]=size(GAM),
%         nd=nw=0, [nym,n]=size(C), and nyu=0.
%
%       Thus, unless minfo is supplied, ALL inputs will be defined as
%       MANIPULATED, and ALL outputs will be defined as MEASURED.
%

%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


if nargin == 4
   minfo=1;
elseif nargin < 4
   disp('USAGE:  pmod = ss2mod(phi,gam,c,d,minfo)')
   disp('                         OR')
   disp('        pmod = ss2mod(phi,gam,c,d,minfo,x0,u0,y0,f0)')
   return
end
if isempty(minfo)
   minfo=1;
end

[n,n1]=size(a);
if n ~= n1
   error('PHI matrix must be square')
end
[p,m]=size(d);

[n1,m1]=size(b);
if n1 ~= n
   error('PHI and GAM must have same number of rows')
elseif m1 > 0 & m1 ~= m
   error('GAM and D must have same number of columns')
end

[p1,n1]=size(c);
if n1 ~= n
   error('PHI and C must have same number of columns')
elseif p1 > 0 & p1 ~= p
   error('C and D must have same number of rows')
end

[rows,cols]=size(minfo);
if rows ~= 1
   error('minfo must be a ROW vector')
end
if cols == 1
   minfo(1,2)=n;
   minfo(1,3)=m;
   minfo(1,6)=p;
   minfo(1,7)=0;
elseif cols == 7
   if sum(minfo(1,3:5)) ~= m
      error('sum( minfo(3:5) ) must = number of columns in GAM and D')
   elseif sum(minfo(1,6:7)) ~= p
      error('sum( minfo(6:7) ) must = number of rows in C and D')
   elseif minfo(1,2) ~= n
      error('minfo(2) is inconsistent with size of PHI')
   end
else
   error('Incorrect number of elements in minfo')
end
if any(minfo < 0)
   error('One or more elements of minfo are negative')
end

% If no linearization conditions were supplied, use original
% MOD format and return.

if nargin < 6
   nr=p+n+1;
   nc=max(n+m+1,7);
   pmod=zeros(nr,nc);
   pmod(1,1:7)=minfo;
   pmod(2:nr,2:n+m+1)=[a  b ; c d];
   pmod(2,1)=NaN;
   return
end

% Otherwise, check x0 -- set to default if not supplied.

if isempty(x0)
   x0=zeros(n,1);
else
   x0=x0(:);
   if length(x0) ~= n
      error('Size of X0 inconsistent with size of PHI')
   end
end

% Check u0 -- set to default if not supplied.

if nargin < 7
   u0=zeros(m,1);
elseif isempty(u0)
   u0=zeros(m,1);
else
   u0=u0(:);
   if length(u0) ~= m
      error('Size of U0 inconsistent with number of columns in GAM and D')
   end
end

% Check y0 -- set to default if not supplied.

if nargin < 8
   y0=zeros(p,1);
elseif isempty(y0)
   y0=zeros(p,1);
else
   y0=y0(:);
   if length(y0) ~= p
      error('Size of Y0 inconsistent with number of rows in C and D')
   end
end

% Check f0 -- set to default if not supplied.

if nargin < 9
   f0=zeros(n,1);
elseif isempty(f0)
   f0=zeros(n,1);
else
   f0=f0(:);
   if length(f0) ~= n
      error('Size of F0 inconsistent with size of PHI')
   end
end

% Save in new MOD format (including linearization conditions)

nr=p+n+2;
nc=max(n+m+2,7);
pmod=zeros(nr,nc);
pmod(1,1:7)=minfo;
pmod(2:nr,2:n+m+2)=[a  b  f0 ; c d y0 ; x0' u0' 0];
pmod(2,1)=NaN;

% end of function SS2MOD