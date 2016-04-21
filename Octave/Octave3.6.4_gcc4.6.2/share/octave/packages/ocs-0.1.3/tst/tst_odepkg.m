## Copyright (C) 2006,2007,2008  Carlo de Falco            
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
## @deftypefn{Function File} {[@var{out}, [@var{tout}]] =}  tst_odepkg @
## (@var{cirstruct},@var{x},@var{t},@var{tol},@var{maxit},@
## @var{pltvars},@var{solver},@var{odestruct},@var{verbosity});
##
## Perform a transient simulation of the system described by
## @var{cirstruct} over the time interval @var{t} using the @code{odepkg} DAE
## solver specified in @var{solver}.
##
## Pssible values for @var{solver} are @code{ode2r}, @code{ode5r},
## @code{oders} or @code{odesx}.
##
## The initial value for the state vector is computed by solving a
## steady state problem at @var{t}(1), with starting guess @var{x}.
##
## @var{tol} and @var{maxit} are parameters passed to @code{nls_newton_raphson}.
##
## If one output is requested @var{out} will contain the value of the state vector
## at each point of @var{t}. 
##
## If two outputs are requested @var{out} will contain the value of the state vector
## at each point of @var{tout}.
##
## Extra options for options for the solver can be passed to the solver
## via @var{odestruct}.
##
## The optional parameter  @var{verbosity} controls the amount of
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
## @seealso{tst_backward_euler,tst_theta_method,tst_daspk,nls_newton_raphson,odepkg,odeset,@
## ode2r,ode5r,oders,odesx}
##
## @end deftypefn

function [out, tout] = tst_odepkg (outstruct,x,t,tol,maxit,\
				   pltvars,solver,verbosity,odestruct)

  ## Check input
  ## FIXME: add input check!
  if ((nargin < 7) || (nargin > 9))
    error("tst_odepkg:wrong number of input parameters");
  endif

  if ~exist("verbosity")
    verbosity = [0,0];
  elseif length(verbosity)<2
    verbosity(2) =0;
  endif

  if(verbosity(1))
    fprintf(1,"initial value:\n");
  endif

  if ~exist("odestruct")
    odestruct = odeset();
  endif

  [A0,B,C] = asm_initialize_system(outstruct,x);

  [out(:,1),ii] = nls_stationary(outstruct,x,tol,maxit);
    
  JAC = @(t, x) TSTODEPKGFUNJAC(outstruct, x, A0, B, t);
  RES = @(t, x) TSTODEPKGFUNRES(outstruct, x, A0, B, C, t);
  MASS= @(t, x) TSTODEPKGFUNMASS(outstruct, x, A0, t);

  odestruct = odeset(odestruct,"Jacobian", JAC);
  odestruct = odeset(odestruct,"Mass",MASS(0,x));
  odestruct = odeset(odestruct,"RelTol", 1e-6,"AbsTol",1e6*eps,
		     "MaxStep", max(diff(t)),"InitialStep",(diff(t))(1));

  if verbosity(2)
    odestruct = odeset(odestruct, "OutputFcn", 
  		       @(t, y, flag)  plotfun(t, y, flag, outstruct, pltvars) );
  endif

  [tout, out] = feval( solver, RES, t([1 end]), x, odestruct);
  if (nargout < 2)
    out = interp1(tout, out, t).';
  endif

endfunction

function [varargout] = plotfun (vt, vy, vflag, outstruct, pltvars)
  ## this function is a modified version of odeplot distributed
  ## with odepkg (c) Thomas Treichl
  
  %# No input argument check is done for a higher processing speed
  persistent vfigure; persistent vtold; 
  persistent vyold;   persistent vcounter;
  
  if (strcmp (vflag, "init")) 
    %# Nothing to return, vt is either the time slot [tstart tstop]
    %# or [t0, t1, ..., tn], vy is the inital value vector 'vinit'
    vfigure  = figure; vtold = vt(1,1); vyold = vy(:,1); 
    vcounter = 1;
    
  elseif (isempty (vflag))
    %# Return something in varargout{1}, either false for 'not stopping
    %# the integration' or true for 'stopping the integration'
    vcounter = vcounter + 1; figure (vfigure);
    vtold(vcounter,1) = vt(1,1);
    vyold(:,vcounter) = vy(:,1);
    utl_plot_by_name(vtold, vyold, outstruct, pltvars); drawnow;
    varargout{1} = false;

  elseif (strcmp (vflag, "done")) 
    %# Cleanup has to be done, clear the persistent variables because
    %# we don't need them anymore
    clear ("vfigure","vtold","vyold","vcounter");

  endif
  
endfunction
## Jacobian for transient problems
function lhs = TSTODEPKGFUNJAC(outstruct,x,A0,B,t)

  [A1,Jac,res] = asm_build_system(outstruct,x,t);
  lhs = ( B + Jac); 

endfunction

function lhs = TSTODEPKGFUNMASS(outstruct,x,A0,t)

  [A1,Jac,res] = asm_build_system(outstruct,x,t);
  lhs = -(A0+A1); 

endfunction

## Residual for transient problems
function rhs = TSTODEPKGFUNRES(outstruct,x,A0,B,C,t)
  
  [A1,Jac,res] = asm_build_system(outstruct,x,t);
  rhs =  B*x + C + res; 

endfunction