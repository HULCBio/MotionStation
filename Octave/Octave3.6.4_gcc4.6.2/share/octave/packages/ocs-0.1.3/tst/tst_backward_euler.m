## Copyright (C) 2006,2007,2008,2011  Carlo de Falco            
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

## -*- texinfo -*-
##
## @deftypefn{Function File} {[@var{out},@var{niter}] =}  @
## tst_backward_euler(@var{cirstruct},@var{x},@var{t},@var{tol},@
## @var{maxit},@var{pltvars},@var{verbosity},@var{dae_fun})
##
## Perform a transient simulation of the system described by
## @var{cirstruct} over the time interval @var{t} using the backward
## Euler algorithm.
##
## The initial value for the state vector is computed by solving a
## steady state problem at @var{t}(1), with starting guess @var{x}.
##
## @var{tol} and @var{maxit} are parameters passed to
## @code{nls_newton_raphson}.
##
## The output @var{out} will contain the value of the state vector at
## each point of @var{t}.
##
## The optional parameter @var{verbosity} controls the amount of
## output produced: 
## 
## @itemize @minus 
## @item if verbosity(1) != 0, information on the progress
## of the algorithm are output at runtime
## @item if verbosity(2) != 0, the plot of the variables whose names
## are listed in @var{pltvars} is
## produced after the computation
## @end itemize
##
## For special purposes one may need to pass modified jacobian and
## residual functions. This can be done via the cell array of function
## handles @var{dae_fun}.
##
## Such functions should have the same input and output
## parameter list as the default sub-functions
## TSTBWEFUNJAC0,TSTBWEFUNRES0, TSTBWEFUNJAC,TSTBWEFUNRES.
##
## The optional output @var{niter} returns the number of Newton iterations
## needed to reach convergence.
## 
## @seealso{tst_daspk,tst_theta_method,tst_odepkg,nls_newton_raphson}
##
## @end deftypefn

function [out, varargout] = tst_backward_euler (outstruct, x, t, tol, maxit, pltvars, verbosity, dae_fun)

  ## Check input
  ## FIXME: add input check!
  if ((nargin < 6) || (nargin > 8))
    error ("tst_backward_euler: wrong number of input parameters.");
  endif

  if ~exist ("verbosity")
    verbosity = [0,0];
  elseif (length (verbosity) < 2)
    verbosity(2) = 0;
  endif
  
  out      = zeros (rows (x), columns (t));
  out(:,1) = x;
  
  if nargout > 1
    niter = zeros (length(t),1);
  endif

  if (verbosity(1))
    fprintf (1, "Initial value.\n");
  endif
  
  
  [A0, B, C] = asm_initialize_system (outstruct, x);
  
  if (nargin > 8)
    JAC = @(x) dae_fun{1} (outstruct,x,t(1),B);
    RES = @(x) dae_fun{2} (outstruct,x,t(1),B,C);
    [out(:,1), ii, resnrm] = nls_newton_raphson (x, RES, JAC, tol, maxit, verbosity(1));
  else
    [out(:,1),ii] = nls_stationary (outstruct, x, tol, maxit);    
  endif
  
  if (nargout > 1)
    niter(1) = ii;
  endif
  
  for it = 2:length (t)

    if (verbosity(1))
      fprintf (1,"Timestep #%d.\n",it);
    endif

    if nargin > 8
      JAC = @(x) dae_fun{3} (outstruct, x, t(it-1), t(it), A0, B);
      RES = @(x) dae_fun{4} (outstruct, x, out(:,it-1), t(it-1), t(it), A0, B, C);
    else
      JAC = @(x,A1,Jac,res) TSTBWEFUNJAC1(outstruct, x, t(it-1), 
					  t(it), A0, B, A1, Jac, res);
      RES = @(x,A1,Jac,res) TSTBWEFUNRES1(outstruct, x, out(:,it-1), 
					  t(it-1), t(it), A0, B, C, 
					  A1, Jac, res);
      UPDT = @(x) TSTBWEFUNUP1 (outstruct, x, t(it));
    endif

    [out(:,it),ii,resnrm] = nls_newton_raphson (out(:,it-1), RES, JAC, tol, maxit, verbosity(1), UPDT);

    if nargout > 1
      niter(it) = ii;
    endif
    
    if (verbosity(2))
     utl_plot_by_name (t(1:it), out(:,1:it), outstruct, pltvars);
     drawnow ();
    endif
  
    ## Stop at runtime
    ## FIXME: maintain this part?
    if exist("~/.stop_ocs","file")
      printf("stopping at timestep %d\n",it);
      unix("rm ~/.stop_ocs");
      break
    end
    
  endfor

  if nargout > 1
    varargout{1} = niter;
  endif

endfunction

## Jacobian for transient problem
function lhs = TSTBWEFUNJAC1 (outstruct, x, t0, t1, A0, B, A1, Jac, res)

  DT = t1-t0;
  if (nargin < 9)
    [A1, Jac, res] = asm_build_system (outstruct, x, t1); 
  endif
  lhs = ((A0+A1)/DT + B + Jac); 

endfunction

## Residual for transient problem
function rhs = TSTBWEFUNRES1 (outstruct, x, xold, t0, t1, A0, B, C, A1, Jac, res)

  DT = t1-t0;
  if ( nargin < 11 )
    [A1, Jac, res] = asm_build_system (outstruct, x, t1); 
  endif
  rhs = (res + C + B*x + (A0+A1)*(x-xold)/DT);

endfunction

## Update for transient problem
function update = TSTBWEFUNUP1 (outstruct, x, t1)

  [A1, Jac, res] = asm_build_system (outstruct, x, t1);
  update = {A1, Jac, res};

endfunction