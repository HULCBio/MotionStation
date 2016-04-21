%  [c,vertx] = polydec(pv,p)
%  vertx = polydec(pv)
%
%  Given a parameter vector PV ranging in a box and a value
%  P of this parameter vector,  POLYDEC returns the corners
%  of the parameter box (columns of VERTX) and the convex
%  decomposition  C = (c1,...,cn) of P over this set of
%  corners:
%
%       P = c1*VERTX(:,1) + ... + cn*VERTX(:,n)
%
%       cj >=0 ,              c1 + ... + cn = 1
%
%
%  The list VERTX of corners can be obtained directly by
%  typing
%             VERTX = POLYDEC(PV)
%
%
%  See also  PVEC, PVINFO, AFF2POL, HINFGS.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [c,vertx] = polydec(pv,p)

if ~any(nargin==[1 2]),
  error('usage: [c,vertx] = polydec(pv,p)');
elseif nargin==1,
  p=[];
end

[typ,np]=pvinfo(pv);

if ~strcmp(typ,'box'),  % box type
  error('PV must be of type ''box'' ');
elseif nargin > 1 & np~=length(p),
  error(sprintf('P should be of length %d according to PV',np));
end


% generate matrix of vertices (columns) and c

[minval,maxval]=pvinfo(pv,'par',1);
if nargin==1,
  c=[minval,maxval];
  for j=2:np,
     [minval,maxval]=pvinfo(pv,'par',j);
     ls=size(c,2);
     c=[c c;minval*ones(1,ls) maxval*ones(1,ls)];
  end
  return
end

t=(p(1)-minval)/(maxval-minval);
if t < 0 | t > 1,
  error(sprintf('P(%d) is not in the specified range',1));
end
c=[1-t , t];

if nargout>1,

  vertx=[minval,maxval];
  for j=2:np,
     [minval,maxval]=pvinfo(pv,'par',j);
     t=(p(j)-minval)/(maxval-minval);
     if t < 0 | t > 1,
        error(sprintf('P(%d) is not in the specified range',j));
     end

     c=[c*(1-t) , c*t];
     ls=size(vertx,2);
     vertx=[vertx vertx;minval*ones(1,ls) maxval*ones(1,ls)];
  end

else

  for j=2:np,
     [minval,maxval]=pvinfo(pv,'par',j);
     t=(p(j)-minval)/(maxval-minval);
     if t < 0 | t > 1,
        error(sprintf('P(%d) is not in the specified range',j));
     end

     c=[c*(1-t) , c*t];
  end

end
