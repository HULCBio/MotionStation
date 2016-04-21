function area = gquad (fun,xlow,xhigh,mparts,bp,wf,y)
%
%  area = gquad (fun,xlow,xhigh,mparts,bp,wf)
%    or
%  area = gquad (fun,xlow,xhigh,mparts,nquad)
%    or
%  area = gquad (fun,xlow,xhigh,mparts,bp,wf,y)
%  This function evaluates the integral of an externally
%  defined function fun(x) between limits xlow and xhigh. The
%  numerical integration is performed using a composite Gauss
%  integration rule.  The whole interval is divided into mparts
%  subintervals and the integration over each subinterval
%  is done with an nquad point Gauss formula which involves base
%  points bp and weight factors wf.  The normalized interval
%  of integration for the bp and wf constants is -1 to +1. The
%  algorithm is described by the summation relation
%  x=b                     j=n k=m
%  integral( f(x)*dx ) = d1*sum sum( wf(j)*fun(a1+d*k+d1*bp(j)) )
%  x=a                     j=1 k=1
%         where bp are base points, wf are weight factors
%         m = mparts, and n = length(bp) and
%         d = (b-a)/m, d1 = d/2, a1 = a-d1
%  The base points and weight factors must first be generated
%  by a call to grule of the form [bp,wf] = grule(nquad)
%
%  Optional argument, nquad, is used if the Gauss points and weights
%  have not been previously calculated.
%
%  Optional argument, y, is used if the function, fun is a function
%  of x and y.  fun(x,y) will be integrated over the range in x for 
%  the constant, y.

%      by Howard Wilson, U. of Alabama, Spring 1990
%      modified by Bryce Gardner, Purdue U., Spring 1993 to handle
%      optional parameter y and also to call with the number of points
%      instead of passing the points and weights.

if ( nargin < 6)
  nquad=bp;
  [bp,wf]=grule(nquad);
endif
bp=reshape(bp,length(bp),1); wf=reshape(wf,length(wf),1);
d = (xhigh - xlow)/mparts;  d2 = d/2;  nquad = length(bp);
% x = (d2*bp)*ones([1,mparts]) + (d*ones([nquad,1]))*([1:mparts]);
x1 = (d2.*bp)*ones([1,mparts]) ;
x2 = (d.*ones([nquad,1]))*([1:mparts]);
x = x1 + x2;
x = x + (xlow-d2); 
if ( nargin == 7 )
  fv = feval(fun,x,y); 
else
  fv = feval(fun,x); 
endif
wv = wf*ones([1,mparts]);
area=d2.*(sum(wv.*fv));

endfunction
