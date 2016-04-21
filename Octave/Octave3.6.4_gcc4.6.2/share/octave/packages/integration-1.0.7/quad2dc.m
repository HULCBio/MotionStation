function int = quad2dc(fun,xlow,xhigh,ylow,yhigh,tol)
%
%usage:  int = quad2dc('Fun',xlow,xhigh,ylow,yhigh)
%or
%        int = quad2dc('Fun',xlow,xhigh,ylow,yhigh,tol)
%
%This function is similar to QUAD or QUAD8 for 2-dimensional integration,
%but it uses a Gaussian-Chebyshev quadrature integration scheme.  
% 	int     -- value of the integral
%       Fun     -- Fun(x,y) (function to be integrated)
%       xlow    -- lower x limit of integration  (should be -xhigh)
%       xhigh   -- upper x limit of integration
%       ylow    -- lower y limit of integration  (should be -yhigh)
%       yhigh   -- upper y limit of integration
%       tol     -- tolerance parameter (optional)
%  The Gauss-Chebyshev Quadrature integrates an integral of the form
%     yhigh                xhigh
%  Int ((1/sqrt(1-y^2)) Int ((1/sqrt(1-x^2)) fun(x,y)) dx dy
%    -yhigh               -xlow

%This routine could be optimized.

if ( exist('tol') != 1 )
  tol=1e-3;
elseif ( tol == [] )
  tol=1e-3;
endif

n=length(xlow);
nquad=2*ones(n,1);
[bpx,bpy,wfxy] = crule2d(2,2);
int_old=gquad2d(fun,xlow,xhigh,ylow,yhigh,bpx,bpy,wfxy);

converge=0;
for i=1:7
  lim = 2^(i+1);
  [bpx,bpy,wfxy] = crule2d(lim,lim);
  int=gquad2d(fun,xlow,xhigh,ylow,yhigh,bpx,bpy,wfxy);

  if ( abs(int_old-int) < abs(tol*int) )
    converge=1;
    break;
  endif
  int_old=int;
endfor

if ( converge == 0 )
  disp('Integral did not converge--singularity likely')
endif

endfunction
