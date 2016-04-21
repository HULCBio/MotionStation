% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of NLWing2.
% 
% NLWing2 is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% -*- texinfo -*-
% @deftypefn{Function File} {flow =} corrector (flow, tol, opts, init)
% applies a newton/levenberg-marquardt corrector to a flow state, in order
% to reach local lift/circulation balance. tol specifies tolerance. 
% Reads the options minit, maxit, use_fsolve and silent from opts.
% Returns empty matrix if not successful.
% @end deftypefn

function flow = corrector (flow, tol, opts, init)
  verbose = ! opts.silent;
  if (opts.use_fsolve)

    global current_corrector_flow;
    current_corrector_flow = flow;

    if (init)
      ## turn off Broyden updates in the first iteration. This wouldn't be
      ## necessary if fsolve was more intelligent about them.
      updating = "off";
    else
      updating = "on";
    endif
    np = length (flow.g);
    opts = optimset ("MaxIter", opts.maxit,
                     "TolFun", tol,
                     "Jacobian", "on",
                     "Updating", updating);
    if (verbose)
      opts = optimset (opts, "OutputFcn", @corrector_output_fcn);
    endif
    [g, eq, info, out, eqj] = fsolve (@corrector_fcn, flow.g, opts);
    if (verbose)
      fprintf (stdout, "i: %d ", info);
      fflush (stdout);
    endif
    if (info > 0)
      res = norm (eq) / sqrt(np);
      flow.g = g;
      flow.eq = eq;
      flow.res = res;
      flow.eqj = eqj;
    else
      flow = [];
    endif
  else
    nitmin = opts.minit;
    nitmax = opts.maxit;
    np = length (flow.g);
    eqj = flow.eqj;
    eq = flow.eq;
    g = flow.g;
    res = norm (eq) / sqrt(np);
    if (verbose)
      fprintf (stderr, "%5.2e ", res);
    endif

    lam0 = sqrt (1e-1*eps) * norm (eqj, 1);
    lambda = lam0;

    it = 1;
    do
      if (lambda <= lam0)
        % newton step
        g1 = g - eqj \ eq;
      else
        % levenberg-marquardt step (ridge regression)
        g1 = g - [eqj; lambda*eye(np)] \ [eq; zeros(np, 1)];
      endif
      eq1 = floweq (g1, flow);
      res1 = norm (eq1) / sqrt (np);
      if (res1 < res)
        % successful step
        lambda = max (lam0, lambda/1.4);
        g = g1;
        eq = eq1;
        res = res1;
        eqj = floweqj (g, flow);
        if (verbose)
          fprintf (stderr, "%5.2e ", res);
        endif
      else
        lambda *= 2;
        if (verbose)
          fprintf (stderr, "+ ");
        endif
      endif
    until ((res < tol && it >= nitmin) || it++ == nitmax )

    % check if failed
    if (it > nitmax)
      flow = [];
    else
      flow.g = g1;
      flow.eq = eq1;
      flow.res = res1;
      flow.eqj = eqj;
    endif
  endif

endfunction


function [eq, eqj] = corrector_fcn (g)
  global current_corrector_flow;
  eq = floweq (g, current_corrector_flow);
  ## FIXME: worksharing possible amongst floweq/floweqj !
  if (nargout > 1)
    eqj = floweqj (g, current_corrector_flow);
  endif
endfunction

function stop = corrector_output_fcn (g, opt, state)
  persistent lastiter = 0;
  iter = opt.iter;
  if (iter < lastiter)
    lastiter = 0;
  endif
  if (iter > lastiter)
    fprintf (stderr, "%5.2e ", opt.fval / sqrt (length (g)));
    lastiter = iter;
  else
    fprintf (stderr, "+ ");
  endif
  stop = false;
  
endfunction

