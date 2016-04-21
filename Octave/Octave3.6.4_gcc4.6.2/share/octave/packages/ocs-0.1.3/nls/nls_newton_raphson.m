## Copyright (C) 2006-2009  Carlo de Falco            
##
## This file is part of:
## OCS - A Circuit Simulator for Octave
##
## OCS is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program (see the file LICENSE); if not,
## see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net> 
## author: Massimiliano Culpo <culpo@math.uni-wuppertal.de>

## -*- texinfo -*-
## @deftypefn{Function File}{[@var{y},@var{numit},@var{resnrm}] =} @
## nls_newton_raphson (@var{y0},@var{RES},@var{JAC},@var{tol},@
## @var{maxit},@var{verbosity},@var{update});
##
## Solve a non-linear system of equations using the Newton-Raphson
## method with damping and return the computed solution vector @var{y}.
##
## The initial guess for the algorithm is set to @var{y0}.
##
## The Jacobian and residual at each step are computed via the function
## handles @var{RES} and @var{JAC}.
##
## The variables @var{tol} and @var{maxit} are the relative tolerance on the
## error of the computed solution and the maximum number of iterations to be
## performed by the algorithm.
##
## The optional parameter @var{verbosity} produce verbose output if non-zero.
##
## The optional function handle @var{update} may be used to provide 
## a faster mean to update Jacobian and residual at runtime.
##
## @var{numit} is the number of performed iterations while @var{resnrm}
## is a vector containing the residual norm at each step.
##
## @seealso{nls_stationary,tst_backward_euler,tst_theta_method,tst_daspk,tst_odepkg}
## @end deftypefn 

function [y,ii,resnrm] = nls_newton_raphson(y0,RES,JAC,tol,maxit,\
					    verbosity,update);

  ## Check input
  ## FIXME: add input check!
  if ((nargin < 5) || (nargin > 7))
    error("nls_newton_raphson: wrong number of input parameters.");
  endif

  if ~exist("verbosity")
    verbosity = 0;
  endif

  if ~exist("update")
    update = @(x) ({});
  endif
  
  jjtot = 0;
  y     = y0;

  uptodate  = update(y);
  res_y     = RES(y,uptodate{:});
  resnrm(1) = norm(res_y,inf);
  
  for ii = 1:maxit
    
    jac_y      = JAC(y,uptodate{:}); 
    ynew       = jac_y\(-res_y+jac_y*y);
    uptodate   = update(ynew);
    res_y      = RES(ynew,uptodate{:}); 

    resnrm(ii+1) = norm(res_y,inf);
    
    jj = 0;
    while ((resnrm(ii+1)>resnrm(ii))&&(jj<10))
      jj++;
      damp = 2^(-jj);
      ynew = y*(1-damp) + ynew*damp;
      uptodate = update(ynew);
      res_y    = RES(ynew,uptodate{:});
      resnrm(ii+1) = norm(res_y,inf);
    endwhile
    
    jjtot += jj;
    y      = ynew;
    
    if resnrm(ii+1)<tol 
      if (verbosity)
	fprintf(1,"Converged in %d newton iterations and ",ii);
	fprintf(1,"%d damping iterations.\n",jjtot);
      endif
      break
    elseif ii==maxit
      if(verbosity)
	fprintf(1,"Not converged, nrm=%g.\n",resnrm(maxit))
      endif
      break
    endif
  endfor
  
endfunction