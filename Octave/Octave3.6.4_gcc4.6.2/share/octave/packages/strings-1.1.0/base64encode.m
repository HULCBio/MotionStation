## Author: Paul Kienzle <pkienzle@users.sf.net>
## This program is granted to the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{Y} =} base64encode (@var{X})
## @deftypefnx {Function File} {@var{Y} =} base64encode (@var{X}, @var{do_reshape})
## Convert X into string of printable characters according to RFC 2045.
## The input may be a string or a matrix of integers in the range 0..255.
## If want the output in the 1-row of strings format, pass the 
## @var{do_reshape} argument as true.
## 
## Example:
## @example
## @group
## base64encode('Hakuna Matata',true) 
## ##returns 'SGFrdW5hIE1hdGF0YQ=='
##
## @end group
## @end example
## @seealso{base64decode}
## @end deftypefn

function Y = base64encode (X, do_reshape)

  if (nargin < 1)
    print_usage;
  elseif nargin != 2
    do_reshape=false;
  endif
  if (ischar(X))
    X = toascii(X);
  elseif (any(X(:)) != fix(X(:)) || any(X(:) < 0) || any(X(:) > 255))
    error("base64encode is expecting integers in the range 0 .. 255");
  endif

  n = length(X(:));
  X = X(:);

  ## split the input into three pieces, zero padding to the same length
  in1 = X(1:3:n);
  in2 = zeros(size(in1));
  in3 = zeros(size(in1));
  in2(1:length(2:3:n)) = X(2:3:n);
  in3(1:length(3:3:n)) = X(3:3:n);

  ## put the top bits of the inputs into the bottom bits of the 
  ## corresponding outputs
  out1 = fix(in1/4);
  out2 = fix(in2/16);
  out3 = fix(in3/64);

  ## add the bottom bits of the inputs as the top bits of the corresponding
  ## outputs
  out4 =            in3 - 64*out3;
  out3 = out3 +  4*(in2 - 16*out2);
  out2 = out2 + 16*(in1 -  4*out1);

  ## correct the output for padding
  if (length(2:3:n) < length(1:3:n)) out3(length(out3)) = 64; endif
  if (length(3:3:n) < length(1:3:n)) out4(length(out4)) = 64; endif

  ## 6-bit encoding table, plus 1 for padding
  table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  table([ out1']+ 1);
  table([ out2']+ 1);
  table([ out3']+ 1);
  table([ out4']+ 1);

  Y = table([ out1'; out2'; out3'; out4' ] + 1);

  if ( do_reshape )
     Y = reshape(Y,[1, prod(size(Y))]);
  end
endfunction

%!assert(base64encode('Hakuna Matata',true),'SGFrdW5hIE1hdGF0YQ==')
