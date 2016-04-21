function int = quad2dcgen(fun,xlow,xhigh,ylow,yhigh,tol)
%
%usage:  int = quad2dcgen('Fun','funxlow','funxhigh',ylow,yhigh)
%or
%        int = quad2dcgen('Fun','funxlow','funxhigh',ylow,yhigh,tol)
%
%This function is similar to QUAD or QUAD8 for 2-dimensional integration
%over a general 2-dimensional region, but it uses a Gauss-Chebyshev 
%quadrature integration scheme.  
%The integral is like:
%               yhigh                   funxhigh(y)
%      int = Int  (1/sqrt(1-y.^2))   Int  (1/sqrt(1-x.^2))  Fun(x,y)  dx  dy
%               ylow                    funxlow(y)
%
% 	int     -- value of the integral
%       Fun     -- Fun(x,y) (function to be integrated)
%       funxlow -- funxlow(y)
%       funxhigh-- funxhigh(y)
%       ylow    -- lower y limit of integration
%       yhigh   -- upper y limit of integration
%       tol     -- tolerance parameter (optional)

%This routine could be optimized.

if ( exist('tol') != 1 )
  tol=1e-3;
elseif ( tol==[] )
  tol=1e-3;
endif

n=length(xlow);
nquad=2*ones(n,1);
[bpxv,wfxv,bpyv,wfyv]=crule2dgen(2,2);
int_old=gquad2dgen(fun,xlow,xhigh,ylow,yhigh,bpxv,wfxv,bpyv,wfyv);

converge=0;
for i=1:7
  lim = 2^(i+1);
  [bpxv,wfxv,bpyv,wfyv]=crule2dgen(lim,lim);
  int=gquad2dgen(fun,xlow,xhigh,ylow,yhigh,bpxv,wfxv,bpyv,wfyv);

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
