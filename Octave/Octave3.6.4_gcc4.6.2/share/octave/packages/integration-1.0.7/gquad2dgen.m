function vol = gquad2dgen(funxy,limxlow,limxhigh,ylow,yhigh,b1,w1,b2,w2)
%
%usage: vol = gquad2dgen(funxy,limxlow,limxhigh,ylow,yhigh,bpxv,wfxv,bpyv,wfyv);
%  or
%usage: vol = gquad2dgen(funxy,limxlow,limxhigh,ylow,yhigh,nquadx,nquady);
%
% This function evaluates a general double integral.  The limits of the 
% inner integration may be functions of the outer integral's variable of 
% integration.  Such as
%              yhigh    ghigh(y)
%      Vol = Int     Int       f(x,y)  dx  dy
%              ylow    glow(y)
% where
%      funxy = f(x,y)
%      limxlow = glow(y)
%      limxhigh = ghigh(y)
% and the base points and weighting functions are found from
%     [bpxv,wfxv,bpyv,wfyv]=grule2dgen(nquadx,nquady);
% where nquadx and nquady are the number of gauss points in the x- and
% y-directions, respectively.
%
% The first form of gquad2dgen is faster when used several times, because 
% the points and weights are only calculated once.
%
% The second form of gquad2dgen is usefull if it is only called once (or a 
% few times).

%      by Bryce Gardner, Purdue University, Spring 1993
%      extending Howard Wilson's (U. of Alabama, Spring 1990) 
%      set of 1-D Gauss quadrature routines to 2-dimensions.

if ( nargin == 7 )
  nquadx=b1;
  nquady=w1;
  [bpxv,wfxv,bpyv,wfyv]=grule2dgen(nquadx,nquady);
elseif ( nargin == 9 )
  bpxv = b1;
  wfxv = w1;
  bpyv = b2;
  wfyv = w2;
else
  disp('Wrong Number of Input Arguments')
  return
endif

nquady=length(bpyv);
qy=(yhigh-ylow)/2;
py=(yhigh+ylow)/2;

vol = 0;

for i=1:nquady
  y=qy*bpyv(i)+py;

  xhigh=feval(limxhigh,y);
  xlow=feval(limxlow,y);

  vx  = gquad(funxy,xlow,xhigh,1,bpxv,wfxv,y);
  vol = vol + (wfyv(i) * vx);
endfor

vol = vol .* qy;

endfunction
