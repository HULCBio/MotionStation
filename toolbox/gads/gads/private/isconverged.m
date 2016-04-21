function [X,EXITFLAG,FVAL,msg,run] = isconverged(stopOutput,stopPlot,verbosity,Iter,maxIter,FunEval,maxFun,MeshSize,minMesh, ...
    infMessage,nextIterate,how,deltaX,deltaF,TolFun,TolX,X,EXITFLAG,FVAL,run)
%ISCONVERGED Checks several conditions of convergence. 
% 	
% 	STOP: A flag passed by user to stop the iteration (Used from OutPutFcn)
% 	
% 	VERBOSITY: Level of display
% 	
% 	ITER, MAXITER: Current Iteration and maximum iteraion allowed respectivley
% 	
% 	FUNEVAL,MAXFUN: Number of function evaluation and maximum iteraion
% 	allowed respectively
% 	
% 	MESHSIZE,MINMESH; Current mesh size used and minimum mesh size
% 	allowed respectively
% 	
% 	INFMESSAGE: Has function reached -inf value (if yes then stop)
% 	
% 	NEXTITERATE: Next iterate is stored in this structure nextIterate.x 
%   and nextIterate.f

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.15.6.2 $  $Date: 2004/03/09 16:15:51 $
%   Rakesh Kumar

X(:) = nextIterate.x;
FVAL = nextIterate.f;
msg = '';
if verbosity > 1
    fprintf('%5.0f    %5.0f   %12.4g  %12.4g     %s\n',Iter, FunEval,  MeshSize, nextIterate.f,how);
end

%User interruption
if stopOutput || stopPlot
    msg = sprintf('%s','Stop requested.');
    if verbosity > 0
        fprintf('%s\n',msg);
    end
    EXITFLAG = -1;
    run = false;
    return;
end
if ~isempty(infMessage)
    msg = sprintf('%s','Optimization terminated: ');
    msg = [msg, sprintf('%s','objective function has reached -Inf value (objective function is unbounded below).')];
    if verbosity > 0
        fprintf('%s\n',msg);
    end
    EXITFLAG = 1;
    run = false;
    return;
end
    
%Convergence check
if MeshSize < minMesh && (deltaF < TolFun || deltaX < TolX)
    EXITFLAG = 1; 
    run  = false;
    msg = sprintf('%s','Optimization terminated: ');
    msg = [msg,sprintf('%s%12.5g%s', 'current mesh size', MeshSize, ' is less than ''TolMesh''.')];
    if verbosity > 0
      fprintf('%s\n',msg);
    end
    return;
end

%X and Fun tolerances will be used only when iteration is successful and
%Meshsize is of the order of TolX/TolFun.
if ~strcmpi(how,'Mesh refined') && ((MeshSize < TolX || MeshSize < TolFun) ...
                                && (deltaF < TolFun || deltaX < TolX))
    EXITFLAG = 1; 
    run  = false;
    msg = sprintf('%s','Optimization terminated: ');
    if deltaX < TolX && MeshSize < TolX 
        msg = [msg, sprintf('%s%12.5e%s', 'current tolerance on X ', deltaX, ' is less than ''TolX''.')];
    else
        msg = [msg, sprintf('%s%12.5e%s', 'current tolerance on f(X) ',deltaF, ' is less than ''TolFun''.')];
    end
    if verbosity > 0
         fprintf('%s\n',msg);
    end
   return;
end

if Iter > maxIter
    EXITFLAG = 0; 
    run  = false;
    msg = sprintf('%s', 'Maximum number of iterations exceeded: ');
    msg = [msg,sprintf('%s', 'increase OPTIONS.MaxIter.')];
    if verbosity > 0
        fprintf('%s\n',msg);    
    end
    return;
end

if FunEval >= maxFun
    EXITFLAG = 0; 
    run  = false;
    msg = sprintf('%s', 'Maximum number of function evaluations exceeded: ');
    msg = [msg, sprintf('%s', 'increase OPTIONS.MaxFunEvals.')];
    if verbosity > 0
        fprintf('%s\n',msg);
    end
    return;
end

