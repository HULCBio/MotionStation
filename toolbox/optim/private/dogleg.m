function [d,quadObj,normd,normdscal,illcondition] = ...
     dogleg(nvar,nfnc,F,JAC,grad,Delta,d,invJAC,broyden, ...
     scalMat,mtxmpy,varargin);
%DOGLEG approximately solves the trust region subproblem using the dogleg approach.
%
%   DOGLEG finds an approximate solution d to the problem:
%
%     min_d      f + g'd + 0.5*d'Bd
%
%     subject to ||Dd|| <= Delta
%
%   where g is the gradient of f, B is a Hessian approximation of f, D is a 
%   diagonal scaling matrix and Delta is a given trust region radius.    

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/02/07 19:13:34 $
%   Richard Waltz, June 2001
%
% NOTE: The scaling matrix D above is called scalMat in this routine.

illcondition = 0;

% Initialize local arrays.
dCauchy   = zeros(nvar,1);
dGN       = zeros(nvar,1);
gradscal  = zeros(nvar,1);
gradscal2 = zeros(nvar,1);
JACvec    = zeros(nfnc,1);

% Compute scaled gradient and other scaled terms.
gradscal = grad./scalMat;
gradscal2 = gradscal./scalMat;
normgradscal = norm(gradscal);

if normgradscal >= eps

  % First compute the Cauchy step (in scaled space).
  dCauchy = -(Delta/normgradscal)*gradscal;
  JACvec = feval(mtxmpy,JAC,gradscal2,1,varargin{:});
  denom = Delta*JACvec'*JACvec;
  tauterm = normgradscal^3/denom;
  tauC = min(1,tauterm);
  dCauchy = tauC*dCauchy;

  % Compute quadratic objective at Cauchy point.
  JACvec = feval(mtxmpy,JAC,dCauchy./scalMat,1,varargin{:});  % compute JAC*d
  objCauchy = gradscal'*dCauchy + 0.5*JACvec'*JACvec;

  normdCauchy = min(norm(dCauchy),Delta);

else

  % Set Cauchy step to zero step and continue.
  objCauchy = 0;
  normdCauchy = 0;

end  

if Delta - normdCauchy < eps;

  % Take the Cauchy step if it is at the boundary of the trust region.
  d = dCauchy; quadObj = objCauchy;

else

  condition = condest(JAC);
  if condition > 1.0e10, illcondition = 1; end

  if condition > 1.0e15

    % Take the Cauchy step if Jacobian is (nearly) singular. 
    d = dCauchy; quadObj = objCauchy;

  else

    % Compute the Gauss-Newton step (in scaled space).
    if broyden
      dGN = -invJAC*F;
    else
      ws = warning('off');
      dGN = -JAC\F;
      warning(ws);
    end
    dGN = dGN.*scalMat;     % scale the step
    
    if any(~isfinite(dGN))  

      % Take the Cauchy step if the Gauss-Newton step gives bad values.
      d = dCauchy; quadObj = objCauchy;
    else

      normdGN = norm(dGN);
      if normdGN <= Delta

        % Compute quadratic objective at Gauss-Newton point.
        JACvec = feval(mtxmpy,JAC,dGN./scalMat,1,varargin{:});  % compute JAC*d
        objGN = gradscal'*dGN + 0.5*JACvec'*JACvec;

        if ~illcondition
          % Take Gauss-Newton step if inside trust region and well-conditioned.
          d = dGN; quadObj = objGN; 
        else
          % Compare Cauchy step and Gauss-Newton step if ill-conditioned.
          if objCauchy < objGN
            d = dCauchy; quadObj = objCauchy;
          else
            d = dGN; quadObj = objGN;
          end
        end        

      else

        % Find the intersect point along dogleg path.

        Delta2 = Delta^2;
        normdCauchy2 = min(normdCauchy^2,Delta2);
        normdGN2 = normdGN^2;
        dCdGN = dCauchy'*dGN;
        dCdGNdist2 = max((normdCauchy2+normdGN2-2*dCdGN),0);

        if dCdGNdist2 == 0
          tauI = 0;
        else 
          tauI = (normdCauchy2-dCdGN + sqrt((dCdGN-normdCauchy2)^2 ...
                + dCdGNdist2*(Delta2-normdCauchy2))) / dCdGNdist2;
        end

        d = dCauchy + tauI*(dGN-dCauchy);

        % Compute quadratic objective at intersect point.
        JACvec = feval(mtxmpy,JAC,d./scalMat,1,varargin{:});  % compute JAC*d
        objIntersect = gradscal'*d + 0.5*JACvec'*JACvec;        

        if ~illcondition
          % Take Intersect step if well-conditioned.
          quadObj = objIntersect; 
        else
          % Compare Cauchy step and Intersect step if ill-conditioned.
          if objCauchy < objIntersect
            d = dCauchy; quadObj = objCauchy;
          else
            quadObj = objIntersect;
          end
        end            

      end
    end
  end    
end

% The step computed was the scaled step.  Unscale it.
normdscal = norm(d);
d = d./scalMat;
normd = norm(d);




