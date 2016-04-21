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
## @deftypefn {Function File} {@var{code} =} encode (@var{msg},@var{n},@var{k})
## @deftypefnx {Function File} {@var{code} =} encode (@var{msg},@var{n},@var{k},@var{typ})
## @deftypefnx {Function File} {@var{code} =} encode (@var{msg},@var{n},@var{k},@var{typ},@var{opt})
## @deftypefnx {Function File} {[@var{code}, @var{added}] =} encode (@var{...})
##
## Top level block encoder. This function makes use of the lower level
## functions such as @dfn{cyclpoly}, @dfn{cyclgen}, @dfn{hammgen}, and
## @dfn{bchenco}. The message to code is pass in @var{msg}, the
## codeword length is @var{n} and the message length is @var{k}. This 
## function is used to encode messages using either:
##
## @table @asis
## @item A [n,k] linear block code defined by a generator matrix
## @item A [n,k] cyclic code defined by a generator polynomial
## @item A [n,k] Hamming code defined by a primitive polynomial
## @item A [n,k] BCH code code defined by a generator polynomial
## @end table
##
## The type of coding to use is defined by the variable @var{typ}. This 
## variable is a string taking one of the values
##
## @table @code
## @item 'linear' or 'linear/binary'
## A linear block code is assumed with the coded message @var{code} being in 
## a binary format. In this case the argument @var{opt} is the generator
## matrix, and is required.
## @item 'cyclic' or 'cyclic/binary'
## A cyclic code is assumed with the coded message @var{code} being in a
## binary format. The generator polynomial to use can be defined in @var{opt}.
## The default generator polynomial to use will be 
## @dfn{cyclpoly(@var{n},@var{k})}
## @item 'hamming' or 'hamming/binary'
## A Hamming code is assumed with the coded message @var{code} being in a
## binary format. In this case @var{n} must be of an integer of the form
## @code{2^@var{m}-1}, where @var{m} is an integer. In addition @var{k}
## must be @code{@var{n}-@var{m}}. The primitive polynomial to use can 
## be defined in @var{opt}. The default primitive polynomial to use is
## the same as defined by @dfn{hammgen}.
## @item 'bch' or 'bch/binary'
## A BCH code is assumed with the coded message @var{code} being in a binary
## format. The generator polynomial to use can be defined in @var{opt}.
## The default generator polynomial to use will be 
## @dfn{bchpoly(@var{n},@var{k})}
## @end table
##
## In addition the argument 'binary' above can be replaced with 'decimal',
## in which case the message is assumed to be a decimal vector, with each
## value representing a symbol to be coded. The binary format can be in two
## forms
##
## @table @code
## @item An @var{x}-by-@var{k} matrix
## Each row of this matrix represents a symbol to be coded
## @item A vector 
## The symbols are created from groups of @var{k} elements of this vector.
## If the vector length is not divisble by @var{k}, then zeros are added
## and the number of zeros added is returned in @var{added}.
## @end table
##
## It should be noted that all internal calculations are performed in the
## binary format. Therefore for large values of @var{n}, it is preferable
## to use the binary format to pass the messages to avoid possible rounding
## errors. Additionally, if repeated calls to @dfn{encode} will be performed,
## it is often faster to create a generator matrix externally with the 
## functions @dfn{hammgen} or @dfn{cyclgen}, rather than let @dfn{encode}
## recalculate this matrix at each iteration. In this case @var{typ} should
## be 'linear'. The exception to this case is BCH codes, whose encoder 
## is implemented directly from the polynomial and is significantly faster.
##
## @end deftypefn
## @seealso{decode,cyclgen,cyclpoly,hammgen,bchenco,bchpoly}

function [code, added] = encode(msg, n, k, typ, opt)

  if ((nargin < 3) || (nargin > 5))
    usage ("[code, added] = encode (msg, n, k [, typ [, opt]])");
  endif

  if (!isscalar(n) || (n != floor(n)) || (n < 3))
    error ("encode: codeword length must be an integer greater than 3");
  endif

  if (!isscalar(k) || (k != floor(k)) || (k > n))
    error ("encode: message length must be an integer less than codeword length");
  endif

  if (nargin > 3)
    if (!ischar(typ))
      error ("encode: type argument must be a string");
    else
      ## Why the hell did matlab decide on such an ugly way of passing 2 args!
      if (strcmp(typ,"linear") || strcmp(typ,"linear/binary"))
	      coding = "linear";
	      msgtyp = "binary";
      elseif (strcmp(typ,"linear/decimal"))
	      coding = "linear";
	      msgtyp = "decimal";
      elseif (strcmp(typ,"cyclic") || strcmp(typ,"cyclic/binary"))
	      coding = "cyclic";
	      msgtyp = "binary";
      elseif (strcmp(typ,"cyclic/decimal"))
	      coding = "cyclic";
	      msgtyp = "decimal";
      elseif (strcmp(typ,"bch") || strcmp(typ,"bch/binary"))
	      coding = "bch";
	      msgtyp = "binary";
      elseif (strcmp(typ,"bch/decimal"))
	      coding = "bch";
	      msgtyp = "decimal";
      elseif (strcmp(typ,"hamming") || strcmp(typ,"hamming/binary"))
	      coding = "hamming";
	      msgtyp = "binary";
      elseif (strcmp(typ,"hamming/decimal"))
	      coding = "hamming";
	      msgtyp = "decimal";
      else
	      error ("encode: unrecognized coding and/or message type");
      endif
    endif
  else
    coding = "hamming";
    msgtyp = "binary";
  endif

  added = 0;
  if (strcmp(msgtyp,"binary"))
    vecttyp = 0;
    if ((max(msg(:)) > 1) || (min(msg(:)) < 0))
      error ("encode: illegal value in message");
    endif
    [ncodewords, k2] = size(msg);
    len = k2*ncodewords;
    if (min(k2,ncodewords) == 1)
      vecttyp = 1;
      msg = vec2mat(msg,k);
      ncodewords = size(msg,1);
    elseif (k2 != k)
      error ("encode: message matrix must be k columns wide");
    endif
  else
    if (!isvector(msg))
      error ("encode: decimally encoded message must be a vector");
    endif
    if ((max(msg) > 2^k-1) || (min(msg) < 0))
      error ("encode: illegal value in message");
    endif
    ncodewords = length(msg);
    msg = de2bi(msg(:),k);
  endif

  if (strcmp(coding,"bch"))
    if (nargin > 4)
      code = bchenco(msg,n,k,opt);
    else
      code = bchenco(msg,n,k);
    endif
  else
    if (strcmp(coding,"linear"))
      if (nargin > 4)
	      gen = opt;
	      if ((size(gen,1) != k) || (size(gen,2) != n))
	        error ("encode: generator matrix is in incorrect form");
	      endif
      else
	      error ("encode: linear coding must supply the generator matrix");
      endif
    elseif (strcmp(coding,"cyclic"))
      if (nargin > 4)
	      [par, gen] = cyclgen(n,opt);
      else
	      [par, gen] = cyclgen(n,cyclpoly(n,k));
      endif
    else
      m = log2(n + 1);
      if ((m != floor(m)) || (m < 3) || (m > 16))
	      error ("encode: codeword length must be of the form '2^m-1' with integer m");
      endif
      if (k != (n-m))
	      error ("encode: illegal message length for hamming code");
      endif
      if (nargin > 4)
	      [par, gen] = hammgen(m, opt);
      else
	      [par, gen] = hammgen(m);
      endif
    endif
    code = mod(msg * gen, 2);
  endif

  if (strcmp(msgtyp,"binary") && (vecttyp == 1))
    code = code';
    code = code(:);
  elseif (strcmp(msgtyp,"decimal"))
    code = bi2de(code);
  endif

endfunction
