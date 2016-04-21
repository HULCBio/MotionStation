## Copyright (C) 1996, 2000, 2004, 2005, 2006, 2007
##               Auburn University. All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} rlocus (@var{sys}) 
## @deftypefnx {Function File} {[@var{rldata}, @var{k}] =} rlocus (@var{sys}, @var{increment}, @var{min_k}, @var{max_k}) 
## Display root locus plot of the specified @acronym{SISO} system.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI model.  Must be a single-input and single-output (SISO) system.
## @item increment
## The increment used in computing gain values.
## @item min_k
## Minimum value of @var{k}.
## @item max_k
## Maximum value of @var{k}.
## @end table
##
## @strong{Outputs}
## @table @var 
## @item rldata
## Data points plotted: in column 1 real values, in column 2 the imaginary values.
## @item k
## Gains for real axis break points.
## @end table
##
## @strong{Block Diagram}
## @example
## @group
##  u    +         +---+      +------+             y
## ------>(+)----->| k |----->| SISO |-------+------->
##         ^ -     +---+      +------+       |
##         |                                 |
##         +---------------------------------+
## @end group
## @end example
## @end deftypefn

## Author: David Clem
## Author: R. Bruce Tenison <btenison@eng.auburn.edu>
## Updated by Kristi McGowan July 1996 for intelligent gain selection
## Updated by John Ingram July 1996 for systems

## Adapted-By: Lukas Reichlin <lukas.reichlin@gmail.com>
## Date: December 2009
## Version: 0.4

## TODO: Improve compatibility

function [rldata_r, k_break, rlpol, gvec, real_ax_pts] = rlocus (sys, increment, min_k, max_k)

  ## TODO: multiplot feature:   rlocus (sys1, "b", sys2, "r", ...)

  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif

  if (! isa (sys, "lti") || ! issiso (sys))
    error ("rlocus: first argument must be a SISO LTI model");
  endif

  ## Convert the input to a transfer function if necessary
  [num, den] = tfdata (sys, "vector");     # extract numerator/denominator polynomials
  lnum = length (num);
  lden = length (den);
  ## equalize length of num, den polynomials
  ## TODO: handle case lnum > lden (non-proper models)
  if (lden < 2)
    error ("rlocus: system has no poles");
  elseif (lnum < lden)
    num = [zeros(1,lden-lnum), num];       # so that derivative is shortened by one
  endif

  olpol = roots (den);
  olzer = roots (num);
  nas = lden - lnum;                       # number of asymptotes
  maxk = 0;
  if (nas > 0)
    cas = (sum (olpol) - sum (olzer)) / nas;
    angles = (2*[1:nas]-1)*pi/nas;
    ## printf("rlocus: there are %d asymptotes centered at %f\n", nas, cas);
  else
    cas = angles = [];
    maxk = 100*den(1)/num(1);
  endif


  ## compute real axis break points and corresponding gains
  dnum = polyder (num);
  dden = polyder (den);
  brkp = conv (den, dnum) - conv (num, dden);
  real_ax_pts = roots (brkp);
  real_ax_pts = real_ax_pts(find (imag (real_ax_pts) == 0));
  k_break = -polyval (den, real_ax_pts) ./ polyval (num, real_ax_pts);
  idx = find (k_break >= 0);
  k_break = k_break(idx);
  real_ax_pts = real_ax_pts(idx);
  if (! isempty (k_break))
    maxk = max (max (k_break), maxk);
  endif
  
  if (nas == 0)
    maxk = max (1, 2*maxk);                # get at least some root locus
  else
    ## get distance from breakpoints, poles, and zeros to center of asymptotes
    dmax = 3*max (abs ([vec(olzer); vec(olpol); vec(real_ax_pts)] - cas));
    if (dmax == 0)
      dmax = 1;
    endif
 
    ## get gain for dmax along each asymptote, adjust maxk if necessary
    svals = cas + dmax * exp (j*angles);
    kvals = -polyval (den, svals) ./ polyval (num, svals);
    maxk = max (maxk, max (real (kvals)));
  endif
  
  ## check for input arguments:
  if (nargin > 2)
    mink = min_k;
  else
    mink = 0;
  endif
  if (nargin > 3)
    maxk = max_k;
  endif
  if (nargin > 1)
    if (increment <= 0)
      error ("rlocus: increment must be positive");
    else
      ngain = fix ((maxk-mink)/increment);
    endif
  else
    ngain = 30;
  endif

  ## vector of gains
  ngain = max (30, ngain);
  gvec = linspace (mink, maxk, ngain);
  if (length (k_break))
    gvec = sort ([gvec, reshape(k_break, 1, [])]);
  endif

  ## Find the open loop zeros and the initial poles
  rlzer = roots (num);

  ## update num to be the same length as den
  lnum = length (num);  
  if (lnum < lden)
    num = [zeros(1,lden - lnum),num];
  endif

  ## compute preliminary pole sets
  nroots = lden - 1;
  for ii = 1:ngain
   gain = gvec(ii);
   rlpol(1:nroots,ii) = vec(sort (roots (den + gain*num)));
  endfor

  ## set smoothing tolerance 
  smtolx = 0.01*(max (max (real (rlpol))) - min (min (real (rlpol))));
  smtoly = 0.01*(max (max (imag (rlpol))) - min (min (imag (rlpol))));
  smtol = max (smtolx, smtoly);
  ## sort according to nearest-neighbor
  rlpol = sort_roots (rlpol, smtolx, smtoly);

  done = (nargin == 4);                    # perform a smoothness check
  while (! done && ngain < 1000)
    done = 1 ;                             # assume done
    dp = abs (diff (rlpol.')).';
    maxdp = max (dp);
    
    ## search for poles whose neighbors are distant
    if (lden == 2)
      idx = find (dp > smtol);
    else
      idx = find (maxdp > smtol);
    endif

    for ii = 1:length(idx)
      i1 = idx(ii);
      g1 = gvec(i1);
      p1 = rlpol(:,i1);

      i2 = idx(ii)+1;
      g2 = gvec(i2);
      p2 = rlpol(:,i2);

      ## isolate poles in p1, p2 
      if (max (abs (p2-p1)) > smtol)
        newg = linspace (g1, g2, 5);
        newg = newg(2:4);
        gvec = [gvec,newg];
        done = 0;                          # need to process new gains
      endif
    endfor

    ## process new gain values
    ngain1 = length (gvec);
    for ii = (ngain+1):ngain1
      gain = gvec(ii);
      rlpol(1:nroots,ii) = vec(sort (roots (den + gain*num)));
    endfor

    [gvec, idx] = sort (gvec);
    rlpol = rlpol(:,idx);
    ngain = length (gvec);
    ## sort according to nearest-neighbor
    rlpol = sort_roots (rlpol, smtolx, smtoly);
  endwhile
  rldata = rlpol;

  ## Plot the data
  if (nargout  == 0)
    rlpolv = vec(rlpol);
    axdata = [real(rlpolv), imag(rlpolv); real(olzer), imag(olzer)];
    axlim = __axis_limits__ (axdata);
    rldata = [real(rlpolv), imag(rlpolv) ];

    %inname = get (sys, "inname");
    %outname = get (sys, "outname");

    ## build plot command args pole by pole

    n_rlpol = rows (rlpol);
    nelts = n_rlpol+1;
    if (! isempty (rlzer))
      nelts++;
    endif
    ## add asymptotes
    n_A = length (olpol) - length (olzer);
    if (n_A > 0)
      nelts += n_A;
    endif
    args = cell (3, nelts);
    kk = 0;
    ## asymptotes first
    if (n_A > 0)
      len_A = 2*max (abs (axlim));
      sigma_A = (sum(olpol) - sum(olzer))/n_A;
      for i_A=0:n_A-1
        phi_A = pi*(2*i_A + 1)/n_A;
        args{1,++kk} = [sigma_A sigma_A+len_A*cos(phi_A)];
        args{2,kk} = [0 len_A*sin(phi_A)];
        if (i_A == 1)
          args{3,kk} = "k--;asymptotes;";
        else
          args{3,kk} = "k--";
        endif
      endfor
    endif
    ## locus next
    for ii = 1:rows(rlpol)
      args{1,++kk} = real (rlpol (ii,:));
      args{2,kk} = imag (rlpol (ii,:));
      if (ii == 1)
        args{3,kk} = "b-;locus;";
      else
        args{3,kk} = "b-";
      endif
    endfor
    ## poles and zeros last
    args{1,++kk} = real (olpol);
    args{2,kk} = imag (olpol);
    args{3,kk} = "rx;open loop poles;";
    if (! isempty (rlzer))
      args{1,++kk} = real (rlzer);
      args{2,kk} = imag (rlzer);
      args{3,kk} = "go;zeros;";
    endif

    set (gcf,"visible","off");
    hplt = plot (args{:});
    set (hplt(kk--), "markersize", 2);
    if (! isempty (rlzer))
      set (hplt(kk--), "markersize", 2);
    endif
    for ii = 1:rows(rlpol)
      set (hplt(kk--), "linewidth", 2);
    endfor
    legend ("boxon", 2);
    grid ("on");
    axis (axlim);
    title (["Root Locus of ", inputname(1)]);
    xlabel (sprintf ("Real Axis     gain = [%g, %g]", gvec(1), gvec(ngain)));
    ylabel ("Imaginary Axis");
    set (gcf (), "visible", "on");
  else
    rldata_r = rldata;
  endif
endfunction


function rlpol = sort_roots (rlpol, tolx, toly)
  ## no point sorting of you've only got one pole!
  if (rows (rlpol) == 1)
    return;
  endif

  ## reorder entries in each column of rlpol to be by their nearest-neighbors rlpol
  dp = diff (rlpol.').';
  drp = max (real (dp));
  dip = max (imag (dp));
  idx = find (drp > tolx | dip > toly);
  if (isempty (idx))
    return;
  endif

  [np, ng] = size (rlpol);                 # num poles, num gains
  for jj = idx
    vals = rlpol(:,[jj,jj+1]);
    jdx = (jj+1):ng;
    for ii = 1:rows(rlpol-1)
      rdx = ii:np;
      dval = abs (rlpol(rdx,jj+1)-rlpol(ii,jj));
      mindist = min (dval);
      sidx = min (find (dval == mindist)) + ii - 1;
      if (sidx != ii)
        c1 = norm (diff(vals.'));
        [vals(ii,2), vals(sidx,2)] = swap (vals(ii,2), vals(sidx,2));
        c2 = norm (diff (vals.'));
        if (c1 > c2)
          ## perform the swap
          [rlpol(ii,jdx), rlpol(sidx,jdx)] = swap (rlpol(ii,jdx), rlpol(sidx,jdx));
          vals = rlpol(:,[jj,jj+1]);
        endif
      endif
    endfor
  endfor

endfunction


function [b, a] = swap (a, b)

endfunction
