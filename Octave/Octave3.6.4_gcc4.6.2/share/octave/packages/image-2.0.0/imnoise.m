## Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2004 Stefan van der Walt <stefan@sun.ac.za>
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
## @deftypefn {Function File} {@var{B} =} imnoise (@var{A}, @var{type})
## @deftypefnx {Function File} {@var{B} =} imnoise (@dots{}, @var{options})
## Add noise to image @var{A}.
##
## @table @code
## @item imnoise (A, 'gaussian' [, mean [, var]])
## additive gaussian noise: @var{B} = @var{A} + noise
## defaults to mean=0, var=0.01
## @item  imnoise (A, 'salt & pepper' [, density])
## lost pixels: A = 0 or 1 for density*100% of the pixels
## defaults to density=0.05, or 5%
## @item imnoise (A, 'speckle' [, var])
## multiplicative gaussian noise: @var{B} = @var{A} + @var{A}*noise
## defaults to var=0.04
## @end table
##
## @seealso{rand, randn}
## @end deftypefn

function A = imnoise (A, stype, a, b)
  ## we do not set defaults right at the start because they are different
  ## depending on the method used to generate noise

  if (nargin < 2 || nargin > 4)
    print_usage;
  elseif (!isimage (A))
    error ("imnoise: first argument must be an image.");
  elseif (!ischar (stype))
    error ("imnoise: second argument must be a string with name of noise type.");
  endif

  in_class = class (A);
  A        = im2double (A);
  if (!is_double_image (A))
    ## FIXME we should probably return an error not a warning but may want to keep
    ## this for backwards compatibility. Maybe temporarily only. What does matlab do?
    warning ("imnoise: image should be in [0,1] range.")
  endif

  switch tolower (stype)
    case {"gaussian"}
      if (nargin < 3), a = 0.0;  endif
      if (nargin < 4), b = 0.01; endif
      A = A + (a + randn (size (A)) * sqrt (b));
      ## Variance of Gaussian data with mean 0 is E[X^2]
    case {"salt & pepper", "salt and pepper"}
      if (nargin < 3), a = 0.05; endif
      noise = rand (size (A));
      A(noise <= a/2)   = 0;
      A(noise >= 1-a/2) = 1;
    case {"speckle"}
      if (nargin < 3), a = 0.04; endif
      A = A .* (1 + randn (size (A)) * sqrt (a));
    otherwise
      error ("imnoise: unknown or unimplemented type of noise `%s'", stype);
  endswitch

  A(A>1) = 1;
  A(A<0) = 0;

  ## we probably should do this in a safer way... but hardcoding the list of
  ## im2xxxx functions might not be a good idea since it then it requires to be
  ## added here if a new im2xxx function is implemented
  A = feval (["im2" in_class], A);
endfunction

%!assert(var(imnoise(ones(10)/2,'gaussian')(:)),0.01,0.005) # probabilistic
%!assert(length(find(imnoise(ones(10)/2,'salt & pepper')~=0.5)),5,10) # probabilistic
%!assert(var(imnoise(ones(10)/2,'speckle')(:)),0.01,0.005) # probabilistic
