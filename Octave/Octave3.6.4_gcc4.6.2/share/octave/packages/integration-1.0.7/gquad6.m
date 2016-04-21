function area = gquad6(fun,xlow,xhigh,mparts)
%
%
%   ==== Six Point Composite Gauss Formula ====
%   ====   With Weight Factors Included    ====
%
%  area = gquad6(fun,xlow,xhigh,mparts)
%  This function determines the area under an externally
%  defined function fun(x) between limits xlow and xhigh. The
%  numerical integration is performed using a composite gauss
%  integration rule.  The whole interval is divided into mparts
%  subintervals and the integration over each subinterval
%  is done with a six point Gauss formula which involves base
%  points bp and weight factors wf.  The normalized interval
%  of integration for the bp and wf constants is -1 to +1.  the
%  algorithm is structured in terms of a parameter mquad = 6 which
%  can be changed along with bp and wf to accommodate a different
%  order formula.  The composite algorithm is described by the
%  following summation relation
%  x=b                     j=n k=m
%  integral( f(x)*dx ) = d1*sum sum( wf(j)*fun(a1+d*k+d1*bp(j)) )
%  x=a                     j=1 k=1
%        where d = (b-a)/m, d1 = d/2, a1 = a-d1,
%              m = mparts, and n = nquad.
%

%     by Howard B. Wilson, U. of Alabama, Spring 1990

%  The weight factors are
wf = [ 1.71324492379170d-01;   3.60761573048139d-01;...
        4.67913934572691d-01]; wf=[wf;wf([3,2,1])];

%  The base points are
bp = [-9.32469514203152d-01;  -6.61209386466265d-01;...
      -2.38619186083197d-01]; bp=[bp;-bp([3,2,1])];

d = (xhigh - xlow)/mparts;  d2 = d/2;  nquad = length(bp);
x = (d2*bp)*ones(1,mparts) + (d*ones(nquad,1))*(1:mparts);
x = x(:) + (xlow-d2); fv=feval(fun,x); wv = wf*ones(1,mparts);

area=d2*(wv(:)'*fv(:));

endfunction
