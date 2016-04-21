function int = quad2dggen(fun,xlow,xhigh,ylow,yhigh,tol)
%
%usage:  int = quad2dggen('Fun','funxlow','funxhigh',ylow,yhigh)
%or
%        int = quad2dggen('Fun','funxlow','funxhigh',ylow,yhigh,tol)
%
%This function is similar to QUAD or QUAD8 for 2-dimensional integration
%over a general 2-dimensional region, but it uses a Gaussian quadrature 
%integration scheme.  
%The integral is like:
%              yhigh   funxhigh(y)
%      int = Int     Int       Fun(x,y)  dx  dy
%              ylow    funxlow(y)
%
% 	int     -- value of the integral
%       Fun     -- Fun(x,y) (function to be integrated)
%       funxlow -- funxlow(y)
%       funxhigh-- funxhigh(y)
%       ylow    -- lower y limit of integration
%       yhigh   -- upper y limit of integration
%       tol     -- tolerance parameter (optional)
%Note that if there are discontinuities the region of integration 
%should be broken up into separate pieces.  And if there are singularities,
%a more appropriate integration quadrature should be used 
%(such as the Gauss-Chebyshev for a specific type of singularity).

%This routine could be optimized.

if ( exist('tol') != 1)
  tol=1e-3;
elseif ( tol==[] )
  tol=1e-3;
endif

oldint=gquad2dgen(fun,xlow,xhigh,ylow,yhigh,2,2);

converge=0;
for i=1:7
  lim = 2^(i+1);
  int=gquad2dgen(fun,xlow,xhigh,ylow,yhigh,lim,lim);

  diff  = oldint - int;
  limit = abs(tol*int);
  if ( abs(diff) < limit )
    converge=1;
    break;
  endif
  oldint=int;
endfor

if ( converge==0 )
  disp('Integral did not converge--singularity likely')
endif

endfunction
