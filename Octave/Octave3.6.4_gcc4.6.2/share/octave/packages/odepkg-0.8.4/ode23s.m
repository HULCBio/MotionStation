## Copyright (C) 2012 Davide Prandi <davide_prandi@hotmail.it>
## Copyright (C) 2012 Carlo de Falco 
##
## This file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file.  If not, see <http://www.gnu.org/licenses/>

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{tout}, @var{xout}] =} ode23s (@var{FUN}, @var{tspan}, @var{x0}, @var{options})
##
## This function can be used to solve a set of stiff ordinary differential
## equations with a Rosenbrock method of order (2,3).
## 
## All the mathematical formulas are from
## "The MATLAB ode suite", L.F. Shampine, M.W. Reichelt, pp.6-7
##
## @itemize @minus
## @item @var{FUN}: String or function-handle for the problem description.
## @itemize @minus
## @item signature: @code{xprime = fun (t,x)}
## @item t:  Time (scalar).
## @item x: Solution (column-vector).
## @item xprime: Returned derivative (column-vector, @code{xprime(i) = dx(i) / dt}).
## @end itemize
## @item @var{tspan}: Initial value column vector [tstart, tfinal]
## @item @var{x0}: Initial value (column-vector).
## @item @var{options}: User-defined integration parameters, using "odeset". 
## See @code{help odeset} for more details.
## Option parameters currently accepted are: RelTol, MaxStep, InitialStep, Mass, Jacobian, JPattern.
## If "options" is not used, these parameters will be given default values.
## ode23s solves problems in the form M*y' = FUN (t, y), where M is a costant mass matrix, 
## non-singular and possibly sparse. Set the filed @var{mass} in @var{options} using @var{odeset} 
## to specify a mass matrix.
## @end itemize
##
## Example:
## @example
## f=@@(t,y) [y(2); 1000*(1-y(1)^2)*y(2)-y(1)];
## opt = odeset ('Mass', [1 0; 0 1], 'MaxStep', 1e-1);
## [vt, vy] = ode23s (f, [0 2000], [2 0], opt);
## @end example
##
## The structure of the code is based on "ode23.m", written by Marc Compere. 
## @seealso{ode23, odepkg, odeset, daspk, dassl}
## @end deftypefn

                                % Author: Davide Prandi
                                % Created: 5 September 2012

function [tout, xout] = ode23s (FUN, tspan, x0, options)

  if nargin < 4, options = odeset (); end

  %% Initialization

  d = 1 / (2 + sqrt (2));
  a = 1 / 2;
  e32 = 6 + sqrt (2);

  jacfun = false;
  jacmat = false;
  if (isfield (options, 'Jacobian') && ! isempty (options.Jacobian)) %user-defined Jacobian
    if (ischar (options.Jacobian))
      jacfun = true;
      jac = str2fun (options.Jacobian);
    elseif (is_function_handle (options.Jacobian))
      jacfun = true;
      jac = options.Jacobian;
    elseif (ismatrix (options.Jacobian))
      jacmat = true;
      jac = options.Jacobian;
    else
      error ("ode23s: the jacobian should be passed as a matrix, a string or a function handle")
    endif
  endif

  jacpat = false;
  if (isfield (options, 'JPattern') && ! isempty (options.JPattern)) %user-defined Jacobian
    jacpat = true;
    [ii, jj] = options.Jacobian;
    pattern = sparse (ii, jj, true);
  endif
  
  if (isfield (options, 'RelTol') && ! isempty (options.RelTol)) %user-defined relative tolerance
    rtol = options.RelTol;
  else
    rtol = 1.0e-3;
  endif
  
  if (isfield (options, 'AbsTol') && ! isempty (options.AbsTol)) %user-defined absolute tolerance
    atol = options.AbsTol;
  else
    atol = 1.0e-6;
  endif


  t = tspan(1);
  tfinal = tspan(2);

  if (isfield (options, 'MaxStep') && ! isempty (options.MaxStep)) %user-defined max step size
    hmax = options.MaxStep;
  else
    hmax = .1 * abs (tfinal - t);
  endif
  
  if (isfield (options, 'InitialStep') && ! isempty (options.InitialStep)) %user-defined initial step size
    h = options.InitialStep
  else
    h = (tfinal - t) * .05; % initial guess at a step size
  end 
  
  hmin = min (16 * eps (tfinal - t), h);
    
  x = x0(:);            % this always creates a column vector, x
  tout = t;             % first output time
  xout = x.';           % first output solution

  %% The main loop
  while (t < tfinal) && (h >= hmin)

    if t + h > tfinal
      h = tfinal - t; 
    endif
    
    %% Jacobian matrix, dfxpdp
    if (jacmat)
      J = jac;
    elseif (jacfun) 
      J = jac (t, x);
    elseif (! jacpat)
      J = __dfxpdp__ (x, @(a) feval (FUN, t, a), rtol);      
    elseif (jacpat)
      J = __dfxpdp__ (x, @(a) feval (FUN, t, a), rtol, pattern);
    endif

    T = (feval (FUN, t + .1 * h, x) - feval (FUN, t, x)) / (.1 * h);

    %% Wolfbrandt coefficient
    W = eye (length (x0))- h*d*J;
    
    %% compute the slopes
    F(:,1) = feval (FUN, t, x);
    k(:,1) = W \ (F(:,1) + h*d*T);
    F(:,2) = feval (FUN, t+a*h, x+a*h*k(:,1));
    k(:,2) = W \ ((F(:,2) - k(:,1))) + k(:,1);
    
    %% compute the 2nd order estimate
    x2 = x + h*k(:,2);
    
    %% 3rd order, needed in error forumula
    F(:,3) = feval (FUN, t+h, x2);
    k(:,3) = W \ (F(:,3) - e32 * (k(:,2)-F(:,2)) - 2 * (k(:,1)-F(:,1)) + h*d*T);

    %% estimate the error
    err = (h/6) * (k(:,1) - 2*k(:,2) + k(:,3));

    %% Estimate the acceptable error
    tau = max (rtol .* abs (x), atol);

    %% Update the solution only if the error is acceptable
    if all (err <= tau)

      t = t + h;
      tout = [tout; t];
      
      x = x2;  %no local extrapolation, FSAL (See documentation)
      
      if (isfield (options', "Mass") && ! (isempty (options.Mass))) %%user-defined mass matrix
        M = options.Mass;
        xout = [xout; (M \ x).'];     
      else
        xout = [xout; x.'];
      end

      %% Update the step size
      if (err == 0.0)
        err = 1e-16;
      endif

      h = min (hmax, h*1.25);    % adaptive step update
      
    else
       if (h <= hmin)
         error ("ode23s: requested step-size too small at t = %g, h = %g, err = %g \n", t, h, err)
       endif
       h = max (hmin, h*0.5);    % adaptive step update
      
    endif
    
  endwhile

  if (t < tfinal)
    error ("ode23s: requested step-size too small at t = %g, h = %g, err = %g \n", t, h, err)
  endif

endfunction


%% The following function is copied from the optim 
%% package of Octave-Forge
%% Copyright (C) 1992-1994 Richard Shrager
%% Copyright (C) 1992-1994 Arthur Jutan
%% Copyright (C) 1992-1994 Ray Muzic
%% Copyright (C) 2010, 2011 Olaf Till <olaf.till@uni-jena.de>

function prt = __dfxpdp__ (p, func, rtol, pattern)

  f = func (p)(:);
  m = numel (f);
  n = numel (p);

  diffp = rtol .* ones (n, 1);  
  sparse_jac = false;
  if (nargin > 3 && issparse (pattern))
    sparse_jac = true;
  endif
  %% initialise Jacobian to Zero

  if (sparse_jac)
    prt = pattern;
  else
    prt = zeros (m, n);   
  endif

  del = ifelse (p == 0, diffp, diffp .* p);
  absdel = abs (del);

  p2 = p1 = zeros (n, 1);
  
  %% double sided interval
  p1 = p + absdel/2;
  p2 = p - absdel/2;

  ps = p;  
  if (! sparse_jac)

    for j = 1:n
      ps(j) = p1(j);
      tp1 = func (ps);
      ps(j) = p2(j);
      tp2 = func (ps);
      prt(:, j) = (tp1(:) - tp2(:)) / absdel(j);
      ps(j) = p(j);
    endfor

  else

    for j = find (any (pattern, 1))
      ps(j) = p1(j);
      tp1 = func (ps);      
      ps(j) = p2(j);
      tp2 = func (ps);
      nnz = find (pattern(:, j));
      prt(nnz, j) = (tp1(nnz) - tp2(nnz)) / absdel(j);
      ps(j) = p(j);
    endfor

  endif

endfunction

%!test
%!  test1=@(t,y) t - y + 1;
%!  [vt, vy] = ode23s (test1, [0 10], [1]);
%!  assert ([vt(end), vy(end)], [10, exp(-10) + 10], 1e-3);

%!demo
%!  # Demo function: stiff Van Der Pol equation
%!  fun = @(t,y) [y(2); 10*(1-y(1)^2)*y(2)-y(1)];
%!  # Calling ode23s method
%!  tic ()
%!  [vt, vy] = ode23s (fun, [0 20], [2 0]);
%!  toc ()
%!  # Plotting the result
%!  plot(vt,vy(:,1),'-o');

%!demo
%!  # Demo function: stiff Van Der Pol equation
%!  fun = @(t,y) [y(2); 10*(1-y(1)^2)*y(2)-y(1)];
%!  # Calling ode23s method
%!  options = odeset ("Jacobian", @(t,y) [0 1; -20*y(1)*y(2)-1, 10*(1-y(1)^2)],
%!                    "InitialStep", 1e-3)
%!  tic ()
%!  [vt, vy] = ode23s (fun, [0 20], [2 0], options);
%!  toc ()
%!  # Plotting the result
%!  plot(vt,vy(:,1),'-o');

%!demo
%!  # Demo function: stiff Van Der Pol equation
%!  fun = @(t,y) [y(2); 100*(1-y(1)^2)*y(2)-y(1)];
%!  # Calling ode23s method
%!  %!  options = odeset ("InitialStep", 1e-4);
%!  tic ()
%!  [vt, vy] = ode23s (fun, [0 200], [2 0]);
%!  toc ()
%!  # Plotting the result
%!  plot(vt,vy(:,1),'-o');

%!demo
%!  # Demo function: stiff Van Der Pol equation
%!  fun = @(t,y) [y(2); 100*(1-y(1)^2)*y(2)-y(1)];
%!  # Calling ode23s method
%!  options = odeset ("Jacobian", @(t,y) [0 1; -200*y(1)*y(2)-1, 100*(1-y(1)^2)], 
%!                    "InitialStep", 1e-4);
%!  tic ()
%!  [vt, vy] = ode23s (fun, [0 200], [2 0], options);
%!  toc ()
%!  # Plotting the result
%!  plot(vt,vy(:,1),'-o');
