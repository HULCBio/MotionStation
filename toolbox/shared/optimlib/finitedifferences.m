function [gradf,cJac,NEWLAMBDA,OLDLAMBDA,s] = finitedifferences(xCurrent,...
                  xOriginalShape,funfcn,confcn,lb,ub,fCurrent,cCurrent,...
                  YDATA,DiffMinChange,DiffMaxChange,typicalx,finDiffType,...
                  variables,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,varargin)
%FINITEDIFFERENCES computes the finite-difference gradients of the
% objective and constraint functions.
%
% This is a helper function.

%  [gradf,cJac,NEWLAMBDA,OLDLAMBDA,s] = FINITEDIFFERENCES(xCurrent, ... 
%                  xOriginalShape,funfcn,confcn,lb,ub,fCurrent,cCurrent, ...
%                  YDATA,DiffMinChange,DiffMaxChange,typicalx,finDiffType, ...
%                  variables,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s, ...
%                  varargin)
% computes the finite-difference gradients of the objective and
% constraint functions.
%
%  gradf = FINITEDIFFERENCES(xCurrent,xOriginalShape,funfcn,[],lb,ub,fCurrent,...
%                  [],YDATA,DiffMinChange,DiffMaxChange,typicalx,finDiffType,...
%                  variables,[],[],[],[],[],[],varargin)
% computes the finite-difference gradients of the objective function.
%
%
% INPUT:
% xCurrent              Point where gradient is desired
% xOriginalShape        Shape of the vector of variables supplied by the user
%                       (The value of xOriginalShape is NOT used)
% funfcn, confcn        Cell arrays containing info about objective and 
%                       constraints
% lb, ub                Lower and upper bounds
% fCurrent, cCurrent    Values at xCurrent of the function and the constraints 
%                       to be differentiated. Note that fCurrent can be a scalar 
%                       or a vector. 
% DiffMinChange, 
% DiffMaxChange         Minimum and maximum values of perturbation of xCurrent 
% finDiffType           Type of finite difference desired (only forward 
%                       differences implemented so far)
% variables             Variables w.r.t which we want to differentiate. Possible 
%
% LAMBDA,NEWLAMBDA,
% OLDLAMBDA,POINT,
% FLAG,s                Parameters for semi-infinite constraints
% varargin              Problem-dependent parameters passed to the objective and 
%                       constraint functions
%
% OUTPUT:
% gradf                 If fCurrent is a scalar, gradf is the finite-difference 
%                       gradient of the objective; if fCurrent is a vector,
%                       gradf is the finite-difference Jacobian  
% cJac                  Finite-difference Jacobian of the constraints
% NEWLAMBDA,
% OLDLAMBDA,s           Parameters for semi-infinite constraints

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:27:16 $

[fNumberOfRows,fNumberOfColumns] = size(fCurrent);

% Make sure that fCurrent is either a scalar or a column vector
% (to ensure that the given fCurrent and the computed fplus 
% will have the same shape)
if fNumberOfColumns ~= 1
   fCurrent(:) = fCurrent;
else
   functionIsScalar = (fNumberOfRows == 1);
end

numberOfVariables = length(xCurrent); 

% nonEmptyLowerBounds = true if lb is not empty, false if it's empty;
% analogoulsy for nonEmptyUpperBound
nonEmptyLowerBounds = ~isempty(lb);
nonEmptyUpperBounds = ~isempty(ub);

% Make sure xCurrent and typicalx are column vectors so that the 
% operation max(abs(xCurrent),abs(typicalx)) won't error
xCurrent = xCurrent(:); typicalx = typicalx(:);
% Value of stepsize suggested in Trust Region Methods, Conn-Gould-Toint, section 8.4.3
CHG = sqrt(eps)*sign(xCurrent).*max(abs(xCurrent),abs(typicalx));
%
% Make sure step size lies within DiffminChange and DiffMaxChange
%
CHG = sign(CHG+eps).*min(max(abs(CHG),DiffMinChange),DiffMaxChange);
len_cCurrent = length(cCurrent);
cJac = zeros(len_cCurrent,numberOfVariables);  % For semi-infinite

if nargout < 3
   NEWLAMBDA=[]; OLDLAMBDA=[]; s=[];
   if nargout == 1
      cJac=[];
   end
end

% allVariables = true/false if finite-differencing wrt to one/all variables
allVariables = false;
if ischar(variables)
   if strcmp(variables,'all')
      variables = 1:numberOfVariables;
      allVariables = true;
   else
      error('optimlib:finitedifferences:InvalidVariables', ...
            'Unknown value of input ''variables''.')
   end
end

% Preallocate gradf for speed 
if functionIsScalar
   gradf = zeros(numberOfVariables,1);
elseif allVariables % vector-function and gradf estimates full Jacobian 
   gradf = zeros(fNumberOfRows,numberOfVariables); 
else % vector-function and gradf estimates one column of Jacobian
   gradf = zeros(fNumberOfRows,1);
end
   
for gcnt=variables
   if gcnt == numberOfVariables, 
      FLAG = -1; 
   end
   temp = xCurrent(gcnt);
   xCurrent(gcnt)= temp + CHG(gcnt);
         
   if (nonEmptyLowerBounds && isfinite(lb(gcnt))) || (nonEmptyUpperBounds && isfinite(ub(gcnt)))
      % Enforce bounds while finite-differencing.
      % Need lb(gcnt) ~= ub(gcnt), and lb(gcnt) <= temp <= ub(gcnt) to enforce bounds.
      % (If the last qpsub problem was 'infeasible', the bounds could be currently violated.)
      if (lb(gcnt) ~= ub(gcnt)) && (temp >= lb(gcnt)) && (temp <= ub(gcnt)) 
          if  ((xCurrent(gcnt) > ub(gcnt)) || (xCurrent(gcnt) < lb(gcnt))) % outside bound ?
              CHG(gcnt) = -CHG(gcnt);
              xCurrent(gcnt)= temp + CHG(gcnt);
              if (xCurrent(gcnt) > ub(gcnt)) || (xCurrent(gcnt) < lb(gcnt)) % outside other bound ?
                  [newchg,indsign] = max([temp-lb(gcnt), ub(gcnt)-temp]);  % largest distance to bound
                  if newchg >= DiffMinChange
                      CHG(gcnt) = ((-1)^indsign)*newchg;  % make sure sign is correct
                      xCurrent(gcnt)= temp + CHG(gcnt);

                      % This warning should only be active if the user doesn't supply gradients;
                      % it shouldn't be active if we're doing derivative check 
                      warning('optimlib:finitedifferences:StepReduced', ...
                             ['Derivative finite-differencing step was artificially reduced to be within\n', ...
                              'bound constraints. This may adversely affect convergence. Increasing distance between\n', ...
                              'bound constraints, in dimension %d to be at least %0.5g may improve results.'], ...
                              gcnt,abs(2*CHG(gcnt)))
                  else
                      error('optimlib:finitedifferences:DistanceTooSmall', ...
                          ['Distance between lower and upper bounds, in dimension %d is too small to compute\n', ...
                           'finite-difference approximation of derivative. Increase distance between these\n', ...
                           'bounds to be at least %0.5g.'],gcnt,2*DiffMinChange)
                  end          
              end
          end
      end
   end % of 'if isfinite(lb(gcnt)) || isfinite(ub(gcnt))'
   
   xOriginalShape(:) = xCurrent;
   if strcmp(funfcn{2},'fseminf')
      fplus = feval(funfcn{3},xOriginalShape,varargin{3:end});
   else          
      fplus = feval(funfcn{3},xOriginalShape,varargin{:});
   end   
   % YDATA: Only used by lsqcurvefit, which has no nonlinear constraints
   % (the only type of constraints we do finite differences on: bounds 
   % and linear constraints do not require finite differences) and thus 
   % no needed after evaluation of constraints
   if ~isempty(YDATA)    
      fplus = fplus - YDATA;
   end
   % Make sure it's in column form
   fplus = fplus(:);

   if functionIsScalar
      gradf(gcnt,1) =  (fplus-fCurrent)/CHG(gcnt);
   elseif allVariables % vector-function and gradf estimates full Jacobian 
      gradf(:,gcnt) = (fplus-fCurrent)/CHG(gcnt);
   else % vector-function and gradf estimates only one column of Jacobian
      gradf = (fplus-fCurrent)/CHG(gcnt);
   end

   if ~isempty(cJac) % Constraint gradient required
      % This is necessary in case confcn is empty, then in the comparison 
      % below confcn{2} would be out of range
      if ~isempty(confcn{1}) 
         if strcmp(confcn{2},'fseminf')
            [ctmp,ceqtmp,NPOINT,NEWLAMBDA,OLDLAMBDA,LOLD,s] = ...
               semicon(xOriginalShape,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,varargin{:});
         else
            [ctmp,ceqtmp] = feval(confcn{3},xOriginalShape,varargin{:});
         end
         cplus = [ceqtmp(:); ctmp(:)];
      end
      % Next line used for problems with varying number of constraints
      if len_cCurrent~=length(cplus) && isequal(funfcn{2},'fseminf')
         cplus=v2sort(cCurrent,cplus); 
      end      
      if ~isempty(cplus)
         cJac(:,gcnt) = (cplus - cCurrent)/CHG(gcnt); 
      end           
   end
    xCurrent(gcnt) = temp;
end % for 








