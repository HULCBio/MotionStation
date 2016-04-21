function int = quadc(fun,xlow,xhigh,tol,trace,p1,p2,p3,p4,p5,p6,p7,p8,p9)
%
%usage:  int = quadc('Fun',xlow,xhigh)
%or
%        int = quadc('Fun',xlow,xhigh,tol)
%or
%        int = quadc('Fun',xlow,xhigh,tol,trace,p1,p2,....)
%
%This function works just like QUAD or QUAD8 but uses a Gaussian-Chebyshev
%quadrature integration scheme.
%
%  The Gauss-Chebyshev Quadrature integrates an integral of the form
%     xhigh
%  Int ((1/sqrt(1-x^2)) fun(x)) dx
%    -xhigh
%This routine ignores xlow

global cb2
global cw2

if ( exist('tol') != 1)
  tol=1e-3;
elseif ( tol==[] )
  tol=1e-3;
endif
if ( exist('trace') != 1)
  trace=0;
elseif ( trace==[] )
  trace=0;
else
  trace=1;
endif

xlow=-xhigh;

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
if ( exist('cb2') != 1 )
  [cb2,cw2]=crule(2);
endif

x=(cb2+1)*jacob+xlow;
eval(exec_string);
int_old=sum(cw2.*y)*jacob;
if ( trace==1 )
  x_trace=x(:);
  y_trace=y(:);
endif

converge=0;
for i=1:7
  gnum=int2str(2^(i+1));
  vname = ['cb',gnum];
  if ( exist(vname) == 0 )
    estr =['[cb',gnum,',cw',gnum,']=crule(',gnum,');'];
    eval(estr);
    estr =['global cb' gnum,' cw',gnum,';'];
    eval(estr);
  endif
  estr = ['x=(cb',gnum,'+1)*jacob+xlow;'];
  eval(estr);
  x=x(:);
  eval(exec_string);
  estr = ['int=sum(cw',gnum,'.*y)*jacob;'];
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

endfunction
