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
## @deftypefn {Function File} {} rsencof (@var{in},@var{out})
## @deftypefnx {Function File} {} rsencof (@var{in},@var{out},@var{t})
## @deftypefnx {Function File} {} rsencof (@var{...},@var{pad})
##
## Encodes an ascii file using a Reed-Solomon coder. The input file is
## defined by @var{in} and the result is written to the output file @var{out}.
## The type of coding to use is determined by whether the input file is 7-
## or 8-bit. If the input file is 7-bit, the default coding is [127,117].
## while the default coding for an 8-bit file is a [255, 235]. This allows
## for 5 or 10 error characters in 127 or 255 symbols to be corrected 
## respectively. The number of errors that can be corrected can be overridden 
## by the variable @var{t}.
##
## If the file is not an integer multiple of the message size (127 or 255)
## in length, then the file is padded with the EOT (ascii character 4)
## characters before coding. Whether these characters are written to the
## output is defined by the @var{pad} variable. Valid values for @var{pad}
## are "pad" (the default) and "nopad", which write or not the padding
## respectively.
##
## @end deftypefn
## @seealso{rsdecof}

function rsencof(in, out, varargin)

  if ((nargin < 2) || (nargin > 4))
    usage("rsencof (in, out [, t [, pad]])");
  endif

  if (!ischar(in) || !ischar(out))
    error ("rsencof: input and output filenames must be strings");
  endif

  t = 0;
  pad = 1;
  for i=1:length(varargin)
    arg = varargin{i};
    if (ischar(arg))
      if (strcmp(arg,"pad"))
	pad = 1;
      elseif (strcmp(arg,"nopad"))
	pad = 0;
      else
	error ("rsencof: unrecognized string argument");
      endif
    else
      if (!isscalar(t) || (t != floor(d)) || (t < 1))
	error ("rsencof: t must be a postive, non-zero integer");
      endif
    endif
  end

  try fid = fopen(in, "r");
  catch
    error ("rsencof: can not open input file");
  end
  [msg, count] = fread(fid, Inf, "char");
  fclose(fid);

  is8bit = (max(msg) > 127);

  if (is8bit)
    m = 8;
    n = 255;
    if (t == 0)
      t = 10;
    endif
  else
    m = 7;
    n = 127;
    if (t == 0)
      t = 5;
    endif
  endif
  k = n - 2 * t;

  ncodewords = ceil(count / k);
  npad = k * ncodewords - count;
  msg = reshape([msg ; 4 * ones(npad,1)],k,ncodewords)';

  code = rsenc(gf(msg,m), n, k,"beginning")';
  code = code(:);

  try fid = fopen(out, "w");
  catch
    error ("rsencof: can not open output file");
  end
  if (pad)
    fwrite(fid, code, "char");
  else
    fwrite(fid, code(1:(ncodewords*n-npad)), "char");
  endif
  fclose(fid);

endfunction
