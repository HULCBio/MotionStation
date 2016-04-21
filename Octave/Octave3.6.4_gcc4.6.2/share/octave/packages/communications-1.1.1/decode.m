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
## @deftypefn {Function File} {@var{msg} =} decode (@var{code},@var{n},@var{k})
## @deftypefnx {Function File} {@var{msg} =} decode (@var{code},@var{n},@var{k},@var{typ})
## @deftypefnx {Function File} {@var{msg} =} decode (@var{code},@var{n},@var{k},@var{typ},@var{opt1})
## @deftypefnx {Function File} {@var{msg} =} decode (@var{code},@var{n},@var{k},@var{typ},@var{opt1},@var{opt2})
## @deftypefnx {Function File} {[@var{msg}, @var{err}] =} decode (@var{...})
## @deftypefnx {Function File} {[@var{msg}, @var{err}, @var{ccode}] =} decode (@var{...})
## @deftypefnx {Function File} {[@var{msg}, @var{err}, @var{ccode}, @var{cerr}] =} decode (@var{...})
##
## Top level block decoder. This function makes use of the lower level
## functions such as @dfn{cyclpoly}, @dfn{cyclgen}, @dfn{hammgen}, and
## @dfn{bchenco}. The coded message to decode is pass in @var{code}, the
## codeword length is @var{n} and the message length is @var{k}. This 
## function is used to decode messages using either:
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
## A linear block code is assumed with the message @var{msg} being in a 
## binary format. In this case the argument @var{opt1} is the generator
## matrix, and is required. Additionally, @var{opt2} containing the 
## syndrome lookup table (see @dfn{syndtable}) can also be passed.
## @item 'cyclic' or 'cyclic/binary'
## A cyclic code is assumed with the message @var{msg} being in a binary
## format. The generator polynomial to use can be defined in @var{opt1}.
## The default generator polynomial to use will be 
## @dfn{cyclpoly(@var{n},@var{k})}. Additionally, @var{opt2} containing the 
## syndrome lookup table (see @dfn{syndtable}) can also be passed.
## @item 'hamming' or 'hamming/binary'
## A Hamming code is assumed with the message @var{msg} being in a binary
## format. In this case @var{n} must be of an integer of the form
## @code{2^@var{m}-1}, where @var{m} is an integer. In addition @var{k}
## must be @code{@var{n}-@var{m}}. The primitive polynomial to use can 
## be defined in @var{opt1}. The default primitive polynomial to use is
## the same as defined by @dfn{hammgen}. The variable @var{opt2} should
## not be defined.
## @item 'bch' or 'bch/binary'
## A BCH code is assumed with the message @var{msg} being in a binary
## format. The primitive polynomial to use can be defined in @var{opt2}.
## The error correction capability of the code can also be defined in 
## @var{opt1}. Use the empty matrix [] to let the error correction 
## capability take the default value.
## @end table
##
## In addition the argument 'binary' above can be replaced with 'decimal',
## in which case the message is assumed to be a decimal vector, with each
## value representing a symbol to be coded. The binary format can be in two
## forms
##
## @table @code
## @item An @var{x}-by-@var{n} matrix
## Each row of this matrix represents a symbol to be decoded
## @item A vector with length divisible by @var{n}
## The coded symbols are created from groups of @var{n} elements of this vector
## @end table
##
## The decoded message is return in @var{msg}. The number of errors encountered
## is returned in @var{err}. If the coded message format is 'decimal' or a
## 'binary' matrix, then @var{err} is a column vector having a length equal
## to the number of decoded symbols. If @var{code} is a 'binary' vector, then
## @var{err} is the same length as @var{msg} and indicated the number of 
## errors in each symbol. If the value @var{err} is positive it indicates the
## number of errors corrected in the corresponding symbol. A negative value
## indicates an uncorrectable error. The corrected code is returned in 
## @var{ccode} in a similar format to the coded message @var{msg}. The
## variable @var{cerr} contains similar data to @var{err} for @var{ccode}.
##
## It should be noted that all internal calculations are performed in the
## binary format. Therefore for large values of @var{n}, it is preferable
## to use the binary format to pass the messages to avoid possible rounding
## errors. Additionally, if repeated calls to @dfn{decode} will be performed,
## it is often faster to create a generator matrix externally with the 
## functions @dfn{hammgen} or @dfn{cyclgen}, rather than let @dfn{decode}
## recalculate this matrix at each iteration. In this case @var{typ} should
## be 'linear'. The exception to this case is BCH codes, where the required
## syndrome table is too large. The BCH decoder, decodes directly from the
## polynomial never explicitly forming the syndrome table.
##
## @end deftypefn
## @seealso{encode,cyclgen,cyclpoly,hammgen,bchdeco,bchpoly,syndtable}

function [msg, err, ccode, cerr] = decode(code, n, k, typ, opt1, opt2)

  if ((nargin < 3) || (nargin > 6))
    usage ("[msg, err, ccode] = decode (code, n, k [, typ [, opt1 [, opt2]]])");
  endif

  if (!isscalar(n) || (n != floor(n)) || (n < 3))
    error ("decode: codeword length must be an integer greater than 3");
  endif

  if (!isscalar(k) || (k != floor(k)) || (k > n))
    error ("decode: message length must be an integer less than codeword length");
  endif

  if (nargin > 3)
    if (!ischar(typ))
      error ("decode: type argument must be a string");
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
	      error ("decode: unrecognized coding and/or message type");
      endif
    endif
  else
    coding = "hamming";
    msgtyp = "binary";
  endif

  if (strcmp(msgtyp,"binary"))
    vecttyp = 0;
    if ((max(code(:)) > 1) || (min(code(:)) < 0))
      error ("decode: illegal value in message");
    endif
    [ncodewords, n2] = size(code);
    len = n2*ncodewords;
    if ((n * floor(len/n)) != len) 
      error ("decode: coded message of incorrect length");
    endif
    if (min(n2,ncodewords) == 1)
      vecttyp = 1;
      ncodewords = len / n;
      code = reshape(code,n,ncodewords);
      code = code';
    elseif (n2 != n)
      error ("decode: coded message matrix must be n columns wide");
    endif
  else
    if (!isvector(code))
      error ("decode: decimally decoded message must be a vector");
    endif
    if ((max(code) > 2^n-1) || (min(code) < 0))
      error ("decode: illegal value in message");
    endif
    ncodewords = length(code);
    code = de2bi(code(:),n);
  endif

  if (strcmp(coding,"bch"))
    if ((nargin < 5) || (isempty(opt1)))
      tmp = bchpoly(n, k,"probe");
      t = tmp(3);
    else
      t = opt1;
    endif

    if (nargin > 5)
      [msg err ccode] = bchdeco(code,k,t,opt2);
    else
      [msg err ccode] = bchdeco(code,k,t);
    endif
    cerr = err;
  else
    if (strcmp(coding,"linear"))
      if (nargin > 4)
	      gen = opt1;
	      if ((size(gen,1) != k) || (size(gen,2) != n))
	        error ("decode: generator matrix is in incorrect form");
	      endif
	      par = gen2par(gen);
	      if (nargin > 5)
	        st = opt2;
	      else
	        st = syndtable(par);
	      endif
      else
	      error ("decode: linear coding must supply the generator matrix");
      endif
    elseif (strcmp(coding,"cyclic"))
      if (nargin > 4)
	      [par, gen] = cyclgen(n,opt1);
      else
	      [par, gen] = cyclgen(n,cyclpoly(n,k));
      endif
      if (nargin > 5)
	      ## XXX FIXME XXX Should we check that the generator polynomial is
	      ## consistent with the syndrome table. Where is the acceleration in
	      ## this case???
	      st = opt2;
      else
	      st = syndtable(par);
      endif
    else
      m = log2(n + 1);
      if ((m != floor(m)) || (m < 3) || (m > 16))
	      error ("decode: codeword length must be of the form '2^m-1' with integer m");
      endif
      if (k != (n-m))
	      error ("decode: illegal message length for hamming code");
      endif
      if (nargin > 4)
	      [par, gen] = hammgen(m, opt1);
      else
	      [par, gen] = hammgen(m);
      endif
      if (nargin > 5)
	      error ("decode: illegal call for hamming coding");
      else
	      st = syndtable(par);
      endif
    endif

    errvec = st(bi2de((mod(par * code',2))',"left-msb")+1,:);
    ccode = mod(code+errvec,2);
    err = sum(errvec');
    cerr = err;
    if (isequal(gen(:,1:k),eye(k)))
      msg = ccode(:,1:k);
    elseif (isequal(gen(:,n-k+1:n),eye(k)))
      msg = ccode(:,n-k+1:n);
    else
      error ("decode: generator matrix must be in standard form");
    endif
  endif

  if (strcmp(msgtyp,"binary") && (vecttyp == 1))
    msg = msg';
    msg = msg(:);
    ccode = ccode';
    ccode = ccode(:);
    err = ones(k,1) * err;
    err = err(:);
    cerr = ones(n,1) * cerr;
    cerr = cerr(:);
  else
    err = err(:);
    cerr = cerr(:);
    if (strcmp(msgtyp,"decimal"))
      msg = bi2de(msg);
      ccode = bi2de(ccode);
    endif
  endif

endfunction
