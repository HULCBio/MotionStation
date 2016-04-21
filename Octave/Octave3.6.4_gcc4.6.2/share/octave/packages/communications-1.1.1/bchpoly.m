## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {@var{p} = } bchpoly ()
## @deftypefnx {Function File} {@var{p} = } bchpoly (@var{n})
## @deftypefnx {Function File} {@var{p} = } bchpoly (@var{n},@var{k})
## @deftypefnx {Function File} {@var{p} = } bchpoly (@var{prim},@var{k})
## @deftypefnx {Function File} {@var{p} = } bchpoly (@var{n},@var{k},@var{prim})
## @deftypefnx {Function File} {@var{p} = } bchpoly (@var{...},@var{probe})
## @deftypefnx {Function File} {[@var{p},@var{f}] = } bchpoly (@var{...})
## @deftypefnx {Function File} {[@var{p},@var{f},@var{c}] = } bchpoly (@var{...})
## @deftypefnx {Function File} {[@var{p},@var{f},@var{c},@var{par}] = } bchpoly (@var{...})
## @deftypefnx {Function File} {[@var{p},@var{f},@var{c},@var{par},@var{t}] = } bchpoly (@var{...})
##
## Calculates the generator polynomials for a BCH coder. Called with no input
## arguments @dfn{bchpoly} returns a list of all of the valid BCH codes for
## the codeword length 7, 15, 31, 63, 127, 255 and 511. A three column matrix
## is returned with each row representing a seperate valid BCH code. The first
## column is the codeword length, the second the message length and the third
## the error correction capability of the code.
##
## Called with a single input argument, @dfn{bchpoly} returns the valid BCH
## codes for the specified codeword length @var{n}. The output format is the
## same as above.
##
## When called with two or more arguments, @dfn{bchpoly} calculates the 
## generator polynomial of a particular BCH code. The generator polynomial
## is returned in @var{p} as a vector representation of a polynomial in
## GF(2). The terms of the polynomial are listed least-significant term
## first.
##
## The desired BCH code can be specified by its codeword length @var{n}
## and its message length @var{k}. Alternatively, the primitive polynomial
## over which to calculate the polynomial can be specified as @var{prim}.
## If a vector representation of the primitive polynomial is given, then 
## @var{prim} can be specified as the first argument of two arguments,
## or as the third argument. However, if an integer representation of the
## primitive polynomial is used, then the primitive polynomial must be 
## specified as the third argument.
##
## When called with two or more arguments, @dfn{bchpoly} can also return the
## factors @var{f} of the generator polynomial @var{p}, the cyclotomic coset 
## for the Galois field over which the BCH code is calculated, the parity
## check matrix @var{par} and the error correction capability @var{t}. It
## should be noted that the parity check matrix is calculated with 
## @dfn{cyclgen} and limitations in this function means that the parity
## check matrix is only available for codeword length upto 63. For 
## codeword length longer than this @var{par} returns an empty matrix.
##
## With a string argument @var{probe} defined, the action of @dfn{bchpoly}
## is to calculate the error correcting capability of the BCH code defined
## by @var{n}, @var{k} and @var{prim} and return it in @var{p}. This is 
## similar to a call to @dfn{bchpoly} with zero or one argument, except that
## only a single code is checked. Any string value for @var{probe} will
## force this action.
##
## In general the codeword length @var{n} can be expressed as
## @code{2^@var{m}-1}, where @var{m} is an integer. However, if 
## [@var{n},@var{k}] is a valid BCH code, then a shortened BCH code of
## the form [@var{n}-@var{x},@var{k}-@var{x}] can be created with the
## same generator polynomial
##
## @end deftypefn
## @seealso{cyclpoly,encode,decode,cosets}

function [p, f, c, par, t] = bchpoly(nn, k, varargin)

  if ((nargin < 0) || (nargin > 4))
    error ("bchpoly: incorrect number of arguments");
  endif

  probe = 0;
  prim = 0;    ## Set to zero to use default primitive polynomial
  if (nargin == 0)
    m = [3:9];
    n = 2.^m - 1;
    nn = n;
  elseif (isscalar(nn))
    m = ceil(log2(nn+1));
    n = 2.^m - 1;
    if ((n != floor(n)) || (n < 7) || (m != floor(m)) )
      error("bchpoly: n must be a integer greater than 3");
    endif
  else
    prim = bi2de(n);
    if (!isprimitive(prim))
      error ("bchpoly: prim must be a primitive polynomial of GF(2^m)");
    endif
    m = length(n) - 1;
    n = 2^m - 1;
  endif

  if ((nargin > 1) && (!isscalar(k) || (floor(k) != k) || (k > n)))
    error ("bchpoly: message length must be less than codeword length");
  endif

  for i=1:length(varargin)
    arg = varargin{i};
    if (ischar(arg))
      probe = 1;
      if (nargout > 1)
	      error ("bchpoly: only one output argument allowed when probing valid codes");
      endif
    else
      if (prim != 0)
	      error ("bchpoly: primitive polynomial already defined");
      endif
      prim = arg;
      if (!isscalar(prim))
	      prim = bi2de(prim);
      endif
      if ((floor(prim) != prim) || (prim < 2^m) || (prim > 2^(m+1)) || ...
	        !isprimitive(prim))
	      error ("bchpoly: prim must be a primitive polynomial of GF(2^m)");
      endif
    endif
  end

  ## Am I using the right algo to calculate the correction capability?
  if (nargin < 2)
    if (nargout > 1)
      error ("bchpoly: only one output argument allowed when probing valid codes");
    endif

    p = [];
    for ni=1:length(n)
      c = cosets(m(ni), prim);
      nc = length(c);
      fc = zeros(1,nc);
      f = [];

      for t=1:floor(n(ni)/2)
	      for i=1:nc
	        if (fc(i) != 1)
	          cl = log(c{i});
	          for j=2*(t-1)+1:2*t
	            if (find(cl == j))
		            f = [f, c{i}.x];
		            fc(i) = 1;
		            break;
	            endif
	          end
	        endif
	      end

	      k = nn(ni) - length(f);
	      if (k < 2)
	        break;
	      endif

	      if (!isempty(p) && (k == p(size(p,1),2)))
	        p(size(p,1),:) = [nn(ni), k, t];
	      else
	        p = [p; [nn(ni), k, t]];
	      endif
      end
    end
  else
    c = cosets(m, prim);
    nc = length(c);
    fc = zeros(1,nc);
    f = [];
    fl = 0;
    f0 = [];
    f1 = [];
    t = 0;
    do
      t++;
      f0 = f1;
      for i=1:nc
	      if (fc(i) != 1)
	        cl = log(c{i});
	        for j=2*(t-1)+1:2*t
	          if (find(cl == j))
	            f1 = [f1, c{i}.x];
	            fc(i) = 1;
	            ptmp = gf([c{i}(1), 1], m, prim);
	            for l=2:length(c{i})
		            ptmp = conv(ptmp, [c{i}(l), 1]);
	            end
	            f = [f; [ptmp.x, zeros(1,m-length(ptmp)+1)]];
	            fl = fl + length(ptmp);
	            break;
	          endif
	        end
	      endif
      end
    until (length(f1) > nn - k)
    t--;
    
    if (nn - length(f0) != k)
      error("bchpoly: can not find valid generator polynomial for parameters");
    endif

    if (probe)
      p = [nn, k, t];
    else

      ## Have to delete a line from the list of minimum polynomials
      ## since we've gone one past in calculating f1 above to be
      ## sure or the error correcting capability
      f = f(1:size(f,1)-1,:);

      p = gf([f0(1), 1], m, prim);
      for i=2:length(f0)
	      p = conv(p, [f0(i), 1]);
      end
      p = p.x;

      if (nargout > 3)
	      if (n > 64)
	        warning("bchpoly: can not create parity matrix\n");
	        par = [];
	      else
	        par = cyclgen(n,p);
	      endif
      endif
    endif
  endif
endfunction
