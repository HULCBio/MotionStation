## Copyright (C) 2000, 2011 P.R. Nienhuis <prnienhuis@users.sf.net>
## Copyright (C) 2001 Paul Kienzle <pkienzle@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{B} =} funm (@var{A}, @var{F})
## Compute matrix equivalent of function F; F can be a function name or
## a function handle.
##
## For trigonometric and hyperbolic functions, @code{thfm} is automatically
## invoked as that is based on @code{expm} and diagonalization is avoided.
## For other functions diagonalization is invoked, which implies that
## -depending on the properties of input matrix @var{A}- the results
## can be very inaccurate @emph{without any warning}. For easy diagonizable and
## stable matrices results of funm will be sufficiently accurate.
##
## Note that you should not use funm for 'sqrt', 'log' or 'exp'; instead
## use sqrtm, logm and expm as these are more robust.
##
## Examples:
##
## @example
##   B = funm (A, sin);
##   (Compute matrix equivalent of sin() )
## @end example
##
## @example
##   function bk1 = besselk1 (x)
##      bk1 = besselk(x, 1);
##   endfunction 
##   B = funm (A, besselk1);
##   (Compute matrix equivalent of bessel function K1(); a helper function
##    is needed here to convey extra args for besselk() )
## @end example
##
## @seealso{thfm, expm, logm, sqrtm}
## @end deftypefn

function B = funm (A, name)

  persistent thfuncs  = {"cos",   "sin",   "tan",   "sec",   "csc",   "cot",   ...
                         "cosh",  "sinh",  "tanh",  "sech",  "csch",  "coth",  ...
                         "acos",  "asin",  "atan",  "asec",  "acsc",  "acot",  ...
                         "acosh", "asinh", "atanh", "asech", "acsch", "acoth", ...
                        }

  ## Function handle supplied?
  try 
    ishndl = isstruct (functions (name));
    fname = functions (name).function;
  catch
    ishdnl = 0;
    fname = ' '
  end_try_catch

  if (nargin < 2 || (!(ischar (name) || ishndl)) || ischar (A))
    usage ("B = funm (A, 'f'  where A = square matrix and f = function name");
  endif
  
  if (~isempty (find (ismember (thfuncs, fname))))
    ## Use more robust thfm ()
    if (ishndl); name = fname; endif
    B = thfm (A, name);
  else
    ## Simply invoke eigenvalues. Note: risk for repeated eigenvalues!!
    ## Modeled after suggestion by N. Higham (based on R. Davis, 2007)
    ## FIXME  Do we need automatic setting of TOL?
    tol = 1.e-15;
    [V, D] = eig (A + tol * randn (size(A)));
    D = diag (feval (name, diag(D)));
    B = V * D / V;
  endif
  
endfunction
