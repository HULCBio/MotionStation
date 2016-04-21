function [x,Resnorm,FVAL,EXITFLAG,OUTPUT,LAMBDA,JACOB,msg] = cflsqcurvefit(FUN,x,XDATA,YDATA,LB,UB,fitopt,varargin)
%CFLSQCURVEFIT Solves non-linear least squares problems.
%   CFLSQCURVEFIT solves problems of the form:
%   min  sum {(FUN(X,XDATA)-YDATA).^2}  where X, XDATA, YDATA and the values 
%    X                                  returned by FUN can be vectors or 
%                                       matrices.
%
%   X=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA) starts at X0 and finds
%   coefficients X to best fit the nonlinear functions in FUN 
%   to the data YDATA (in the least-squares sense). FUN accepts inputs 
%   X and XDATA and returns a vector (or matrix) of function values F, 
%   where F is the same size as YDATA, evaluated at X and XDATA. 
%   NOTE: FUN should return FUN(X,XDATA) and not the sum-of-squares 
%   sum(FUN(X,XDATA).^2)). (FUN(X,XDATA) is summed and squared 
%   implicitly in the algorithm.) 
%
%   X=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB) defines a set of lower and upper
%   bounds on the design variables, X, so that the solution is in
%   the range LB <= X <= UB.  Use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above.
%
%   X=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS) minimizes with the default
%   parameters replaced by values in the structure OPTIONS, an argument
%   created with the OPTIMSET function.  See OPTIMSET for details.  Used
%   options are Display, TolX, TolFun, DerivativeCheck, Diagnostics, Jacobian,
%   JacobMult, JacobPattern, LineSearchType, LevenbergMarquardt, MaxFunEvals,
%   MaxIter, DiffMinChange and DiffMaxChange, LargeScale, MaxPCGIter, 
%   PrecondBandWidth, TolPCG, TypicalX. Use the Jacobian option to specify 
%   that FUN also returns a second output argument J that is 
%   the Jacobian matrix at the point X. If FUN returns a vector F of m 
%   components when X has length n, then J is an m-by-n matrix where J(i,j) 
%   is the partial derivative of F(i) with respect to x(j). (Note that the 
%   Jacobian J is the transpose of the gradient of F.)
%
%   X=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS,P1,P2,..) passes the 
%   problem-dependent parameters P1,P2,... directly to the function FUN: 
%   FUN(X,XDATA,P1,P2,...).  Pass empty matrices for OPTIONS to use the 
%   default values.
%
%   [X,RESNORM]=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,...) returns the value of the
%   squared 2-norm of the residual at X: sum {(YDATA - FUN(X,XDATA)).^2}.
%
%   [X,RESNORM,RESIDUAL]=CFLSQCURVEFIT(FUN,X0,...) returns the value of residual,
%   YDATA - FUN(X,XDATA), at the solution X. 
%
%   [X,RESNORM,RESIDUAL,EXITFLAG]=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,...) returns 
%   a string EXITFLAG that describes the exit condition of CFLSQCURVEFIT.  
%   If EXITFLAG is:
%      > 0 then CFLSQCURVEFIT converged to a solution X.
%      0   then the maximum number of function evaluations was reached.
%      < 0 then CFLSQCURVEFIT did not converge to a solution.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT]=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
%   returns a structure OUTPUT with the number of iterations taken in 
%   OUTPUT.iterations, the number of function evaluations in OUTPUT.funcCount, 
%   the algorithm used in OUTPUT.algorithm, the number of CG iterations (if used) in 
%   OUTPUT.cgiterations, and the first-order optimality (if used) in 
%   OUTPUT.firstorderopt.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA]=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
%   returns the set of Lagrangian multipliers, LAMBDA, at the solution: 
%   LAMBDA.lower for LB and LAMBDA.upper for UB.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN]=CFLSQCURVEFIT(FUN,X0,XDATA,YDATA,...)
%   returns the Jacobian of FUN at X.
%
%   Examples
%     FUN can be specified using @:
%        xdata = [5;4;6];
%        ydata = 3*sin([5;4;6])+6;
%        x = cflsqcurvefit(@myfun, [2 7], xdata, ydata)
%
%   where MYFUN is a MATLAB function such as:
%
%       function F = myfun(x,xdata)
%       F = x(1)*sin(xdata)+x(2);
%
%   FUN can also be an inline object:
%
%       fun = inline('x(1)*sin(xdata)+x(2)','x','xdata');
%       x = cflsqcurvefit(fun,[2 7], xdata, ydata)
%
%   See also FIT.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.10.2.2 $  $Date: 2004/02/01 21:43:18 $

%   The default algorithm when OPTIONS.LargeScale = 'off' is the 
%   Levenberg-Marquardt method with a mixed quadratic and cubic line search procedure.  
%   A Gauss-Newton method is selected by setting OPTIONS.LargeScale='off' and 
%   OPTIONS.LevenbergMarquardt='off'. 
%

% ------------Initialization----------------
defaultopt = struct('Display','final','LargeScale','on', ...
   'TolX',1e-6,'TolFun',1e-6,'DerivativeCheck','off',...
   'Diagnostics','off',...
   'Jacobian','off','JacobMult',[],...% JacobMult set to [] by default
   'JacobPattern','sparse(ones(Jrows,Jcols))',...
   'MaxFunEvals','100*numberOfVariables',...
   'DiffMaxChange',1e-1,'DiffMinChange',1e-8,...
   'PrecondBandWidth',0,'TypicalX','ones(numberOfVariables,1)',...
   'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
   'TolPCG',0.1,'MaxIter',400,...
   'LineSearchType','quadcubic','LevenbergMarquardt','on'); 
% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
   return
end

 if nargin < 7, fitopt = [];
   if nargin < 6, UB = [];
      if nargin < 5, LB = [];
         if nargin < 4, 
            error('curvefit:cflsqcurvefit:wrongNumArgs', ...
                  'LSQCURVEFIT requires four input arguments');
         end, end, end, end
if nargout > 5
   computeLambda = 1;
else 
   computeLambda = 0;
end

% convert FITOPTIONS to OPTIMOPTIONS
pvlist = {};
switch lower(fitopt.Algorithm)
case 'trust-region'
    Jrows = length(XDATA);
    Jcols = length(x);
    pvlist(end+1:end+6) = {'LargeScale','on','JacobPattern',ones(Jrows,Jcols),'PrecondBandWidth',Inf};
case 'levenberg-marquardt'
    pvlist(end+1:end+4) = {'LargeScale','off','LevenbergMarquardt','on'};
case 'gauss-newton'
    pvlist(end+1:end+4) = {'LargeScale','off','LevenbergMarquardt','off'};
otherwise
    error('curvefit:cflsqcurvefit:invalidAlgorithm', ...
          'Not a valid Algorithm value.');
end
options = optimset(getallfields(fitopt), pvlist{:});

% XDATA put at the end so it's bundled with varargin in lsqncommon
caller = 'lsqcurvefit';
[x,Resnorm,FVAL,EXITFLAG,OUTPUT,LAMBDA,JACOB,msg] = ...
   lsqncommon(FUN,x,YDATA,LB,UB,options,defaultopt,caller,...
              computeLambda,XDATA,varargin{:});

FVAL = -FVAL;  % so that FVAL = YDATA - F(X,...);  