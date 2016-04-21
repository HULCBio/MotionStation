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
 
% -*- texinfo -*-
% @deftypefn{Function File} {clq =} calcwing (wing, varargin)
% Runs the automatic calculation of a wing's aerodynamic
% characteristics for a whole range of angles of attack.
% The @var{wing} argument specifies the wing geometry (as returned
% from makewing), and any following arguments must be in 
% @code{"option name", option_value} pairs. Valid options are:
% @itemize
% @item "start"   Initial angle of attack (0)
% @item "limit"   Maximum angle of attack (22)
% @item "psep"    The minimum past-separation local angle to terminate (0)
% @item "sstep"   Initial angle step (0.5)
% @item "mstep"   Minimum angle step (1e-2)
% @item "maxit"   Maximum number of corrector iterations (250)
% @item "minit"   Minimum number of corrector iterations (4)
% @item "tol"     Minimum tolerance to achieve in corrector.
% @item "silent"  Suppress verbose output (false)
% @item "use_fsolve"  Use fsolve as a corrector (false) (experimental).
% @end itemize
% @end deftypefn
function clq = calcwing (wing, varargin)

  % set default options
  opts.start = 0;
  opts.limit = 22;
  opts.psep = 0;
  opts.sstep = 0.5;
  opts.mstep = 1e-2;
  opts.maxit = 250;
  opts.minit = 4;
  opts.tol = [];
  opts.silent = false;
  opts.use_fsolve = false;
  wassep = false;

  ns = 0;
  % override specified
  for i = 1:2:length (varargin)-1
    opts.(varargin{i}) = varargin{i+1};
  endfor
  ## FIXME: the following duality stems from the fact that 
  ## fsolve uses relative tolerance. Need a better solution here.
  if (isempty (opts.tol))
    if (opts.use_fsolve)
      opts.tol = 1e-12;
    else
      opts.tol = 1e-4;
    endif
  endif

  if (opts.silent)
    % supply a dummy output function
    printf_flush = @() [];
  endif

  flw.wing = wing;

  step = opts.sstep;
  flw = setalfa (flw, opts.start);
  printf_flush ("initial alfa: %f\n", flw.alfad);

  flw1 = flw;

  first_iter = true;
  while (flw.alfad < opts.limit && step >= opts.mstep)
    % corrector
    printf_flush ("corrector loop: ");

    if (opts.use_fsolve)
      nmaxit = opts.maxit;
    else
      nmaxit = max (opts.minit, floor (opts.maxit * opts.mstep / step));
    endif
    tol1 = min (1e4*flw.res, opts.tol);
    flw1 = corrector (flw1, tol1, opts, first_iter);

    if (isempty (flw1))
      printf_flush (" bad.\n");
      if (first_iter)
        error ("Could not converge from initial point. Try different settings");
      elseif (step == opts.mstep)
	printf_flush ("terminating.\n");
	break;
      else
	step *= .5;
      endif
    else
      printf_flush (" good.\n");
      first_iter = false;
      flw = flw1;
      ns++;
      alfas{ns} = flw.alfad;
      als{ns} = flw.alfa;
      [cls{ns}, cds{ns}, cms{ns}, ads{ns}] = qcalc (flw);
      amaxd = flw.alfa + ads{ns} - wing.amax;
      [mad, imad] = max (amaxd);
      step = max (step, min (step * 1.4, 5*opts.mstep));
      if (mad < 0)
	zsep{ns} = NaN;
	% update step
	step = max (min (step, -90/pi*mad), 2*opts.mstep);
      else
	zsep{ns} = wing.zc (imad);
	if (mad > opts.psep)
	  printf_flush ("separation condition reached.\n");
	  break;
	endif
      endif
    endif

    printf_flush ("predictor step: ");
    flw1 = [];
    while (step > opts.mstep)
      flw1 = predictor (flw, step);
      printf_flush ("%5.3f ", step);
      if (isempty (flw1))
	step *= .5;
      else
	break;
      endif
    endwhile

    if (step <= opts.mstep)
      printf_flush ("unpredicted.\n");
      step = opts.mstep;
      flw1 = setalfa (flw, flw.alfad + step);
    else
      printf_flush ("good.\n");
    endif
    printf_flush ("alfa = %5.2f\n", flw1.alfad);

  endwhile

  clq.alfa = cell2mat (alfas);
  clq.al = cell2mat (als);
  clq.cl = cell2mat (cls);
  clq.cd = cell2mat (cds);
  clq.cm = cell2mat (cms);
  clq.ad = cell2mat (ads);
  clq.zsep = cell2mat (zsep);

  # integral quantities
  dzac = diff (wing.zac);
  dS = wing.ch .* dzac;
  dSp = wing.ch .* hypot (dzac, diff (wing.yac));
  area = wing.area;
  if (wing.sym)
    area /= 2;
  endif
  cad = cos (clq.ad); sad = sin (clq.ad);
  clq.clw = dS.' * (clq.cl .* cad + clq.cd .* sad) / area;
  clq.cdiw = -dSp.' * (clq.cl .* sad) / area;
  clq.cdw = dSp.' * (clq.cd .* cad)/ area + clq.cdiw;
  if (wing.sym)
    clq.bmw = dSp.' * (clq.cl .* cad) / area;
  endif
  # integral moment - local moment contributions
  clq.cmw = (dS .* wing.ch).' * clq.cm;
  # local force contributions
  adm = bsxfun (@minus, clq.al, wing.amac) + clq.ad;
  clq.cmw -= (dS .* wing.rmac).' * (clq.cl .* cos (adm));
  clq.cmw += (dSp .* wing.rmac).' * (clq.cd .* sin (adm));
  clq.cmw /= (area * wing.cmac);

endfunction

function printf_flush (varargin)
  fprintf (stderr, varargin{:});
  fflush (stderr);
endfunction

