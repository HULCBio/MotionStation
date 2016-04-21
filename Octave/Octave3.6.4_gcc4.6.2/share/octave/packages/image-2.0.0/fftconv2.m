## Copyright (C) 2004 Stefan van der Walt <stefan@sun.ac.za>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} fftconv2 (@var{a}, @var{b}, @var{shape})
## @deftypefnx{Function File} fftconv2 (@var{v1}, @var{v2}, @var{a}, @var{shape})
## Convolve 2 dimensional signals using the FFT.
##
## This method is faster but less accurate than @var{conv2} for large @var{a} and @var{b}.
## It also uses more memory. A small complex component will be 
## introduced even if both @var{a} and @var{b} are real.
## @seealso{conv2}
## @end deftypefn

function X = fftconv2(varargin)
  ## FIXME seems to not work when using a vector for the convolution in the row
  ## direction and another in the column direction (fftconv2 (v1, v2, m)
    if (nargin < 2)
      print_usage;
    endif

    shape = "full";
    rowcolumn = 0;
    
    if ((nargin > 2) && ismatrix(varargin{3}) && !ischar(varargin{3}))

        ## usage: fftconv2(v1, v2, a[, shape])

        rowcolumn = 1;
        v1 = varargin{1}(:)';
        v2 = varargin{2}(:);
        orig_a = varargin{3};

        if (nargin == 4) shape = varargin{4}; endif
    else
        ## usage: fftconv2(a, b[, shape])

        a = varargin{1};
        b = varargin{2};
        if (nargin == 3) shape = varargin{3}; endif

    endif

    if (rowcolumn)
        a = fftconv2(orig_a, v2);
        b = v1;
    endif
    
    ra = rows(a);
    ca = columns(a);
    rb = rows(b);
    cb = columns(b);

    A = fft2(impad(a, [0 cb-1], [0 rb-1]));
    B = fft2(impad(b, [0 ca-1], [0 ra-1]));

    X = ifft2(A.*B);

    if (rowcolumn)
        rb = rows(v2);
        ra = rows(orig_a);
        cb = columns(v1);
        ca = columns(orig_a);
    endif
    
    if strcmp(shape,"same")
        r_top = ceil((rb + 1) / 2);
        c_top = ceil((cb + 1) / 2);
        X = X(r_top:r_top + ra - 1, c_top:c_top + ca - 1);
    elseif strcmp(shape, "valid")
        X = X(rb:ra, cb:ca);
    endif
endfunction

%!# usage: fftconv2(a,b,[, shape])
%!shared a,b
%! a = repmat(1:10, 5);
%! b = repmat(10:-1:3, 7);
%!assert(norm(fftconv2(a,b)-conv2(a,b)), 0, 1e6*eps)
%!assert(norm(fftconv2(b,a)-conv2(b,a)), 0, 1e6*eps)
%!assert(norm(fftconv2(a,b,'full')-conv2(a,b,'full')), 0, 1e6*eps)
%!assert(norm(fftconv2(b,a,'full')-conv2(b,a,'full')), 0, 1e6*eps)
%!assert(norm(fftconv2(a,b,'same')-conv2(a,b,'same')), 0, 1e6*eps)
%!assert(norm(fftconv2(b,a,'same')-conv2(b,a,'same')), 0, 1e6*eps)
%!assert(isempty(fftconv2(a,b,'valid')));
%!assert(norm(fftconv2(b,a,'valid')-conv2(b,a,'valid')), 0, 1e6*eps)

%!# usage: fftconv2(v1, v2, a[, shape])
%!##FIXME this usage seems to be broken...
%!shared x,y,a
%! x = 1:4; y = 4:-1:1; a = repmat(1:10, 5);
%!assert(norm(fftconv2(x,y,a)-conv2(x,y,a)), 0, 1e6*eps)
%!assert(norm(fftconv2(x,y,a,'full')-conv2(x,y,a,'full')), 0, 1e6*eps)
%!assert(norm(fftconv2(x,y,a,'same')-conv2(x,y,a,'same')), 0, 1e6*eps)
%!assert(norm(fftconv2(x,y,a,'valid')-conv2(x,y,a,'valid')), 0, 1e6*eps)

%!demo
%! ## Draw a cross
%! N = 100;
%! [x,y] = meshgrid(-N:N, -N:N);
%! z = 0*x;
%! z(N,1:2*N+1) = 1; z(1:2*N+1, N) = 1;
%! imshow(z);
%!
%! ## Draw a sinc blob
%! n = floor(N/10);
%! [x,y] = meshgrid(-n:n, -n:n);
%! b = x.^2 + y.^2; b = max(b(:)) - b; b = b / max(b(:));
%! imshow(b);
%!
%! ## Convolve the cross with the blob
%! imshow(real(fftconv2(z, b, 'same')*N))
