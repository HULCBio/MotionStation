function int = quadg(fun,xlow,xhigh,tol,trace,p1,p2,p3,p4,p5,p6,p7,p8,p9)
%
%usage:  int = quadg('Fun',xlow,xhigh)
%or
%        int = quadg('Fun',xlow,xhigh,tol)
%or
%        int = quadg('Fun',xlow,xhigh,tol,trace,p1,p2,....)
%
%This function works just like QUAD or QUAD8 but uses a Gaussian quadrature
%integration scheme.  Use this routine instead of QUAD or QUAD8:
%	if higher accuracy is desired (this works best if the function, 
%		'Fun', can be approximated by a power series) 
%	or if many similar integrations are going to be done (I think less
%		function evaluations will typically be done, but the 
%		integration points and the weights must be calculated.
%		These are saved between integrations so when QUADG
%		is called again, the points and weights are all ready
%		known.)
%	or if the function evaluations are time consuming.
%Note that if there are discontinuities the integral should be broken up into separate 
%pieces.  And if there are singularities,  a more appropriate integration quadrature
%should be used (such as the Gauss-Chebyshev).

global b2
global w2

if ( exist('tol') != 1 )
  tol=1e-3;
elseif ( tol==[] )
  tol=1e-3;
endif
if ( exist('trace') != 1 )
  trace=0;
elseif ( trace==[] )
  trace=0;
else
  trace=1;
endif

%setup string to call the function
exec_string=['y=',fun,'(x'];
num_parameters=nargin-5;
for i=1:num_parameters
  exec_string=[exec_string,',p',int2str(i)];
endfor
exec_string=[exec_string,');'];

%setup mapping parameters
jacob=(xhigh-xlow)/2;

%generate the first two sets of integration points and weights
if ( exist('b2') != 1 )
  [b2,w2]=grule(2);
endif

x=(b2+1)*jacob+xlow;
eval(exec_string);
int_old=sum(w2.*y)*jacob;
if ( trace==1 )
  x_trace=x(:);
  y_trace=y(:);
endif

converge=0;
for i=1:7
  gnum=int2str(2^(i+1));
  vname = ['b',gnum];
  if ( exist(vname) == 0 )
    estr = ['[b',gnum,',w',gnum,']=grule(',gnum,');'];
    eval(estr);
    estr = ['global b',gnum,' w',gnum,';'];
    eval(estr);
  endif
  estr = ['x=(b',gnum,'+1)*jacob+xlow;'];
  eval(estr);
  eval(exec_string);
  estr = ['int=sum(w',gnum,'.*y)*jacob;'];
  eval(estr);

  if ( trace==1 )
    x_trace=[x_trace;x(:)];
    y_trace=[y_trace;y(:)];
  endif

  if ( abs(int_old-int) < abs(tol*int) )
    converge=1;
    break;
  endif
  int_old=int;
endfor

if ( converge==0 )
  disp('Integral did not converge--singularity likely')
endif

if ( trace==1 )
  plot(x_trace,y_trace,'+')
endif

%gnum,i,length(x_trace)

endfunction
