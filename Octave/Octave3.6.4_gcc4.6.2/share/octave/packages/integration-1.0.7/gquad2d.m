function vol = gquad2d(fun,xlow,xhigh,ylow,yhigh,b1,b2,w1)
%
%usage:  vol = gquad2d(fun,xlow,xhigh,ylow,yhigh,bpx,bpy,wfxy)
% or
%        vol = gquad2d(fun,xlow,xhigh,ylow,yhigh,nquadx,nquady)
%  This function evaluates the integral of an externally
%  defined function fun(x,y) between limits xlow and xhigh
%  and ylow and yhigh. The numerical integration is performed 
%  using a Gauss integration rule.  The integration 
%  is done with an nquadx by nquady Gauss formula which involves base
%  point matrices bpx and bpy and weight factor matrix wfxy.  The normalized 
%  interval of integration for the bpx, bpy and wfxy constants is -1 to +1 
%  (in x) and -1 to +1 (in y). The algorithm is described by the 
%  summation relation
%  x=b                     j=nx k=ny
%  integral( f(x)*dx ) = J*sum sum( wfxy(j,k)*fun( x(j), y(k) ) )
%  x=a                     j=1 k=1
%         where wfxy are weight factors,
%         nx = nquadx = number of Gauss points in the x-direction,
%         ny = nquady = number of Gauss points in the y-direction,
%         x = (xhigh-xlow)/2 * bpx + (xhigh+xlow)/2 = mapping function in x,
%         y = (yhigh-ylow)/2 * bpy + (yhigh+ylow)/2 = mapping function in y,
%         and J = (xhigh-xlow)*(yhigh-ylow)/4 = Jacobian of the mapping.
%  The base points and weight factors must first be generated
%  by a call to grule of the form [bpx,bpy,wfxy] = grule2d(nquadx,nquady)
%
% The first form of gquad2d is faster when used several times, because 
% the points and weights are only calculated once.
%
% The second form of gquad2d is usefull if it is only called once (or a 
% few times).

%      by Bryce Gardner, Purdue University, Spring 1993
%      extending Howard Wilson's (U. of Alabama, Spring 1990) 
%      set of 1-D Gauss quadrature routines.

if ( nargin == 7 )
  nquadx=b1;
  nquady=b2;
  [bpx,bpy,wfxy]=grule2d(nquadx,nquady);
elseif ( nargin == 8 )
  bpx = b1;
  bpy = b2;
  wfxy = w1;
else
  disp('Wrong Number of Input Arguments')
  return
endif

%Map to x
qx=(xhigh-xlow)/2;
px=(xhigh+xlow)/2;
x=qx*bpx+px;

%Map to y
qy=(yhigh-ylow)/2;
py=(yhigh+ylow)/2;
y=qy*bpy+py;

fv = feval(fun,x,y);
vol = sum(sum(wfxy.*fv))*qx*qy;

endfunction
