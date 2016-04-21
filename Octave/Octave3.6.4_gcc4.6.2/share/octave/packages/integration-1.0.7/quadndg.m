function int = quadndg(fun,xlow,xhigh,tol)
%
%usage:  int = quadndg('Fun',xlow,xhigh)
%or
%        int = quadndg('Fun',xlow,xhigh,tol)
%
%This function is similar to QUAD or QUAD8 for n-dimensional integration,
%but it uses a Gaussian quadrature integration scheme.  
% 	int     -- value of the integral
%       Fun     -- Fun(x) (function to be integrated) in this case treat
%                  all the different values of x as different variables
%                  as opposed to different instances of the same variable
%       x       -- n length vector of coordinates
%       xlow    -- n length vector of lower limits of integration
%       xhigh   -- n length vector of upper limits of integration
%       tol     -- tolerance parameter (optional)
%Note that if there are discontinuities the region of integration 
%should be broken up into separate pieces.  And if there are singularities,
%a more appropriate integration quadrature should be used 
%(such as the Gauss-Chebyshev for a specific type of singularity).

%This routine could be optimized.

if ( exist('tol') != 1 )
  tol=1e-3;
elseif ( tol==[] )
  tol=1e-3;
endif

n=length(xlow);
nquad=2*ones(n,1);
int_old=gquadnd(fun,xlow,xhigh,nquad);

converge=0;  
for i=1:7
  nquad=(2^(i+1))*ones(n,1);
  int=gquadnd(fun,xlow,xhigh,nquad);

  if ( abs(int_old-int) < abs(tol*int) )
    converge=1;
    break;
  endif
  int_old=int;
endfor

if ( converge==0 )
  disp('Integral did not converge--singularity likely')
endif

endfunction

