## Author: Paul Kienzle <pkienzle@users.sf.net>
## This program is granted to the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{M} =} colorgradient (@var{C}, @var{w}, @var{n})
## Define a colour map which smoothly traverses the given colors.
## @var{C} contains the colours, one row per r,g,b value.
## @var{w}(i) is the relative length of the transition from colour i to colour i+1
## in the entire gradient.  The default is ones(rows(C)-1,1).
## n is the length of the colour map.  The default is rows(colormap).
##
## E.g.,
## @example 
## colorgradient([0,0,1; 1,1,0; 1,0,0])  # blue -> yellow -> red
## x = linspace(0,1,200);
## imagesc(x(:,ones(30,1)))';
## @end example
## @end deftypefn

function ret = colorgradient (C, w, n)
  if nargin < 1 || nargin > 3
    print_usage;
  endif

  if nargin == 1
    n = rows(colormap);
    w = ones(length(C)-1,1);
  elseif nargin == 2
    if (length(w) == 1)
      n = w;
      w = ones(rows(C)-1,1);
    else
      n = rows(colormap);
    endif
  endif

  if (length(w)+1 != rows(C))
    error("must have one weight for each color interval");
  endif

  w = 1+round((n-1)*cumsum([0;w(:)])/sum(w));
  map = zeros(n,3);
  for i=1:length(w)-1
    if (w(i) != w(i+1))
      map(w(i):w(i+1),1) = linspace(C(i,1),C(i+1,1),w(i+1)-w(i)+1)';
      map(w(i):w(i+1),2) = linspace(C(i,2),C(i+1,2),w(i+1)-w(i)+1)';
      map(w(i):w(i+1),3) = linspace(C(i,3),C(i+1,3),w(i+1)-w(i)+1)';
    endif
  endfor

  if nargout == 0
    colormap(map);
  else
    ret = map;
  endif
endfunction
