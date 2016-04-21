function os = itermsg(itermeth,tol,maxit,i,flag,iter,relres)
%ITERMSG   Displays the final message for iterative methods.
%   ITERMSG(TOL,MAXIT,I,FLAG,ITER,RELRES)
%
%   See also BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, SYMMLQ, QMR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/15 04:11:41 $

if (flag ~= 0)
   if (length(i) == 2) % gmres
      os = sprintf([itermeth ' stopped at outer iteration %d (inner iteration %d) without converging' ...
            ' to the desired tolerance %0.2g'],i(1),i(2),tol);
   elseif (fix(i) ~= i) % bicgstab
      os = sprintf([itermeth ' stopped at iteration %.1f without converging' ...
            ' to the desired tolerance %0.2g'],i,tol);
   else
      os = sprintf([itermeth ' stopped at iteration %d without converging' ...
            ' to the desired tolerance %0.2g'],i,tol);
   end
end

switch(flag)
   
case 0,
   if (iter == 0)
      if isnan(relres)
         os = sprintf(['The right hand side vector is all zero ' ...
               'so ' itermeth '\nreturned an all zero solution ' ...
               'without iterating.']);
      else
         os = sprintf(['The initial guess has relative residual %0.2g' ...
               ' which is within\nthe desired tolerance %0.2g' ...
               ' so ' itermeth ' returned it without iterating.'], ...
            relres,tol);
      end
   else
      if (length(iter) == 2) % gmres
         os = sprintf([itermeth ' converged at outer iteration %d (inner iteration %d) to a solution' ...
               ' with relative residual %0.2g'],iter(1),iter(2),relres);
      elseif (fix(iter) ~= iter) % bicgstab
         os = sprintf([itermeth ' converged at iteration %.1f to a solution' ...
               ' with relative residual %0.2g'],iter,relres);      
      else
         os = sprintf([itermeth ' converged at iteration %d to a solution' ...
               ' with relative residual %0.2g'],iter,relres);
      end
   end
   
case 1,
   os = [os sprintf('\nbecause the maximum number of iterations was reached.')];
   
case 2,
   os = [os sprintf(['\nbecause the system involving the' ...
            ' preconditioner was ill conditioned.'])];
   
case 3,
   os = [os sprintf('\nbecause the method stagnated.')];
   
case 4,
   os = [os sprintf(['\nbecause a scalar quantity became too' ...
            ' small or too large to continue computing.'])];
case 5,
   os = [os sprintf(['\nbecause the preconditioner' ...
            ' is not symmetric positive definite.'])];
   
end

if (flag ~= 0)
   if (length(iter)==2) % gmres
      os = [os sprintf(['\nThe iterate returned (number %d(%d))' ...
               ' has relative residual %0.2g'],iter(1),iter(2),relres)];
   elseif (fix(iter) ~= iter) % bicgstab
      os = [os sprintf(['\nThe iterate returned (number %.1f)' ...
               ' has relative residual %0.2g'],iter,relres)];      
   else
      os = [os sprintf(['\nThe iterate returned (number %d)' ...
               ' has relative residual %0.2g'],iter,relres)];
   end
end

disp(os)