## Copyright (C) 2001 Rolf Fabian <fabian@tu-cottbus.de>
## Copyright (C) 2001 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2011 Philip Nienhuis <pr.nienhuis@hccnet.nl>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn{Function File} {@var{y} =} thfm (@var{x}, @var{mode})
## Trigonometric/hyperbolic functions of square matrix @var{x}.
##
## @var{mode} must be the name of a function. Valid functions are 'sin', 'cos',
## 'tan', 'sec', 'csc', 'cot' and all their inverses and/or hyperbolic variants,
## and 'sqrt', 'log' and 'exp'.
##
## The code @code{thfm (x, 'cos')} calculates matrix cosinus @emph{even if} input
## matrix @var{x} is @emph{not} diagonalizable.
##
## @emph{Important note}:
## This algorithm does @emph{not} use an eigensystem similarity transformation. It
## maps the @var{mode} functions to functions of @code{expm}, @code{logm} and
## @code{sqrtm}, which are known to be robust with respect to non-diagonalizable
## ('defective') @var{x}.
##
## @seealso{funm}
## @end deftypefn

function y = thfm (x,M)
  ## minimal arg check only
  if ( nargin != 2 || !ischar (M) || ischar (x) )
    print_usage;
  endif

  ## look for known functions of sqrt, log, exp
  I = eye (size (x));

  switch (M)
    case {'cos'}
      if (isreal(x))  y = real( expm( i*x ) );
      else            y = ( expm( i*x ) + expm( -i*x ) ) / 2;
      endif
    case {'sin'}
      if (isreal(x))  y = imag( expm( i*x ) );
      else            y = ( expm( i*x ) - expm( -i*x ) ) / (2*i);
      endif
    case {'tan'}
      if (isreal(x))  t = expm( i*x );    y = imag(t)/real(t);
      else            t = expm( -2*i*x ); y = -i*(I-t)/(I+t);
      endif
    case {'cot'}
      if (isreal(x))  t = expm( i*x );    y = real(t)/imag(t);
      else            t = expm( -2*i*x ); y = i*(I+t)/(I-t);
      endif
    case {'sec'}
      if (isreal(x))  y = inv( real(expm(i*x)) );
      else            y = inv( expm(i*x)+expm(-i*x) )*2 ;
      endif
    case {'csc'}
      if (isreal(x))  y = inv( imag(expm(i*x)) );
      else            y = inv( expm(i*x)-expm(-i*x) )*2i;
      endif
    case {'log'}      y = logm(x);
    case {'exp'}      y = expm(x);
    case {'cosh'}     y = ( expm(x)+expm(-x) )/2;
    case {'sinh'}     y = ( expm(x)-expm(-x) )/2;
    case {'tanh'}     t = expm( -2*x ); y = (I - t)/(I + t);
    case {'coth'}     t = expm( -2*x ); y = (I + t)/(I - t);
    case {'sech'}     y = 2 * inv( expm(x) + expm(-x) );
    case {'csch'}     y = 2 * inv( expm(x) - expm(-x) );
    case {'asin'}     y = -i * logm( i*x + sqrtm(I - x*x) );
    case {'acos'}     y =  i * logm( x - i*sqrtm(I - x*x) );
    case {'atan'}     y = -i/2 * logm( (I + i*x)/(I - i*x) );
    case {'acot'}     y =  i/2 * logm( (I + i*x)/(i*x - I) );
    case {'asec'}     y = i * logm( ( I - sqrtm(I - x*x) ) / x );
    case {'acsc'}     y = -i * logm( i*( I + sqrtm(I - x*x) ) / x );
    case {'sqrt'}     y = sqrtm(x);
    case {'asinh'}    y = logm( x + sqrtm (x*x + I) );
    case {'acosh'}    y = logm( x + sqrtm (x*x - I) );
    case {'atanh'}    y = logm( (I + x)/(I - x) ) / 2;
    case {'acoth'}    y = logm( (I + x)/(x - I) ) / 2;
    case {'asech'}    y = logm( (I + sqrtm (I - x*x)) / x );
    case {'acsch'}    y = logm( (I + sqrtm (I + x*x)) / x );
    otherwise
      error ("thfm doesn't support function %s - try to use funm instead.", M);
  endswitch

endfunction
