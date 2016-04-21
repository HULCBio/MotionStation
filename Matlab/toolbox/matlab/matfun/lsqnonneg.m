function [x,resnorm,resid,exitflag,output,lambda] = lsqnonneg(C,d,x0,options)
%LSQNONNEG Linear least squares with nonnegativity constraints.
%   X = LSQNONNEG(C,d) returns the vector X that minimizes NORM(C*X - d)
%   subject to X >= 0. C and d must be real.
%
%   X = LSQNONNEG(C,d,X0) uses X0 as the starting point if all(X0 > 0);
%   otherwise the default is used. The default start point is the 
%   origin (the default is used when X0==[] or when only two input 
%   arguments are provided). 
%
%   X = LSQNONNEG(C,d,X0,OPTIONS) minimizes with the default optimization
%   parameters replaced by values in the structure OPTIONS, an argument
%   created with the OPTIMSET function.  See OPTIMSET for details.  Used
%   options are Display and TolX. (A default tolerance TolX of 
%   10*MAX(SIZE(C))*NORM(C,1)*EPS is used). 
%   
%   [X,RESNORM] = LSQNONNEG(...) also returns the value of the squared 2-norm of 
%   the residual: norm(C*X-d)^2.
%
%   [X,RESNORM,RESIDUAL] = LSQNONNEG(...) also returns the value of the  
%   residual: C*X-d.
%   
%   [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONNEG(...) returns an EXITFLAG that 
%   describes the exit condition of LSQNONNEG. Possible values of EXITFLAG and
%   the corresponding exit conditions are
%
%    1  LSQNONNEG converged with a solution X.
%    0  Iteration count was exceeded. Increasing the tolerance
%       (OPTIONS.TolX) may lead to a solution.
%  
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONNEG(...) returns a structure
%   OUTPUT with the number of steps taken in OUTPUT.iterations, the type of 
%   algorithm used in OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONNEG(...) returns 
%   the dual vector LAMBDA  where LAMBDA(i) <= 0 when X(i) is (approximately) 0 
%   and LAMBDA(i) is (approximately) 0 when X(i) > 0.
% 
%   See also LSCOV, SLASH.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.5 $  $Date: 2004/04/16 22:07:24 $

% Reference:
%  Lawson and Hanson, "Solving Least Squares Problems", Prentice-Hall, 1974.

defaultopt = struct('Display','notify','TolX','10*eps*norm(C,1)*length(C)');
% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(C,'defaults')
   x = defaultopt;
   return
end

if nargin < 2, 
  error('MATLAB:lsqnonneg:NotEnoughInputs','Not enough input arguments.'); 
end
if ~isreal(C) || ~isreal(d), 
  error('MATLAB:lsqnonneg:ComplexCorD', 'C and d must be real.'); 
end

% Check for non-double inputs
if ~isa(C,'double') || ~isa(d,'double')
  error('MATLAB:lsqnonneg:NonDoubleInput', ...
        'LSQNONNEG only accepts inputs of data type double.')
end

% initialize variables
if nargin < 4
   options = [];
end
printtype = optimget(options,'Display',defaultopt,'fast');
tol = optimget(options,'TolX',defaultopt,'fast');

% In case the defaults were gathered from calling: optimset('fminsearch'):
if ischar(tol) 
   if isequal(lower(tol),'10*eps*norm(c,1)*length(c)')
      tol = 10*eps*norm(C,1)*length(C);
   else
      error('MATLAB:lsqnonneg:OptTolXNotPosScalar',...
            'Option ''TolX'' must be an positive scalar if not the default.')
   end
end

switch printtype
case 'notify'
	verbosity = 1;
case {'none','off'}
   verbosity = 0;
case 'iter'
   warning('MATLAB:lsqnonneg:InvalidDisplayValueIter', ...
       '''iter'' value not valid for ''Display'' parameter for LSQNONNEG.')
   verbosity = 3;
case 'final'
   verbosity = 2;
otherwise
   error('MATLAB:lsqnonneg:InvalidOptParamDisplay',...
         'Bad value for options parameter: ''Display''.');
end

[m,n] = size(C);
P = zeros(1,n);
Z = 1:n;
if nargin > 2
   if isempty(x0)
      x = P';
   else
      % Check for non-double x0
      if ~isa(x0,'double')
        error('MATLAB:lsqnonneg:NonDoubleInput', ...
              'LSQNONNEG only accepts inputs of data type double.')
      end     
      x = x0(:);
      if any(x < 0)
         x = P';
      end
   end
else
   x = P';
end

ZZ=Z;
resid = d-C*x;
w = C'*(resid);

% set up iteration criterion
outeriter = 0;
iter = 0;
itmax = 3*n;
exitflag = 1;

% outer loop to put variables into set to hold positive coefficients
while any(Z) && any(w(ZZ) > tol)
   outeriter = outeriter + 1;
   [wt,t] = max(w(ZZ));
   t = ZZ(t);
   P(1,t) = t;
   Z(t) = 0;
   PP = find(P);
   ZZ = find(Z);
   nzz = size(ZZ);
   CP(1:m,PP) = C(:,PP);
   CP(:,ZZ) = zeros(m,nzz(2));
   z = pinv(CP)*d;
   z(ZZ) = zeros(nzz(2),nzz(1));
   % inner loop to remove elements from the positive set which no longer belong
   while any((z(PP) <= tol))
      iter = iter + 1;
      if iter > itmax
          msg = sprintf(['Exiting: Iteration count is exceeded, exiting LSQNONNEG.', ...
               '\n','Try raising the tolerance (OPTIONS.TolX).']);
         if verbosity 
            disp(msg)
         end
         exitflag = 0;
         output.iterations = outeriter;
         output.message = msg;
         resnorm = sum(resid.*resid);
         x = z;
         lambda = w;
         return
      end
      QQ = find((z <= tol) & P');
      alpha = min(x(QQ)./(x(QQ) - z(QQ)));
      x = x + alpha*(z - x);
      ij = find(abs(x) < tol & P' ~= 0);
      Z(ij)=ij';
      P(ij)=zeros(1,length(ij));
      PP = find(P);
      ZZ = find(Z);
      nzz = size(ZZ);
      CP(1:m,PP) = C(:,PP);
      CP(:,ZZ) = zeros(m,nzz(2));
      z = pinv(CP)*d;
      z(ZZ) = zeros(nzz(2),nzz(1));
   end
   x = z;
   resid = d-C*x;
   w = C'*(resid);
end

lambda = w;
resnorm = sum(resid.*resid);
output.iterations = outeriter;
output.algorithm = 'active-set using svd';
msg = 'Optimization terminated.';
if verbosity > 1
   disp(msg)   
end
output.message = msg;
