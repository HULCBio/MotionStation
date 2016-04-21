## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## y = bound_convex(d,h,x,pad=0) 
##
##  y : 3xQ : Corners that define the convex hull of the projection of x
##            in the plane d*y == v. The corners are sorted.
##

## Author:        Etienne Grossmann <etienne@egdn.net>

function y = bound_convex(d,h,x,pad) 

if  nargin<4, pad = 0 ; end

d = d(:)' ;

P = size(x,2) ;
prudent = 1;

## I don't really care if I'm not given coplanar points
## 
#  if prudent && any(abs(d*x-h)>10*eps),
#    printf("bound_convex : Points are not on plane (max dist=%8.4g\n",...
#  	 max(abs(d*x-h)));
#    keyboard
#  end

## Project x to plane { y | d'*y = h }
nd = norm(d);
h ./= nd;
d ./= nd;

p = (v*d)*ones(1,P);

x -= d'*d*(x-p) ;

## x = proplan (x,d,h);

c = mean(x')'*ones(1,P);
xc = x-c ;

ext = zeros(1,P);		# Extremal points

nuld = null(d);
px = nuld'*xc; 			# Project on 2D 
[chx,ich] = chull (px);		# Find 2D convex hull
ext(ich) = 1;
## keyboard
#  for i = 1:P,

#    [dum,jj] = max( xc(:,i)'*xc ) ;
#    ext(jj) = 1 ;
#    [dum,jj] = min( xc(:,i)'*xc ) ;
#    ext(jj) = 1 ;
#  end

y = xc(:,find(ext)) ;

norms = sqrt( sum( y.^2 ) );

if any(norms==0),
  printf("bound_convex : Points project to line\n") ;
  if sum( norms != 0 )!=2,
    printf("bound_convex : Moreover the segment has more than 2 tips!!\n") ;
  end
  y = y(:,find(norms != 0)) ;
  norms = norms(find(norms != 0));
  return
end
## Sort points so that they turn monotonously around the origin
d1 = y(:,1)'/norms(1) ;
if abs( d1*d1' - 1 )>10*eps,
  error ("bound_convex : d1 ain't unit!\n");
  ## keyboard
end
norms = [1;1;1]*norms;

[dum,id2] = min( abs( d1*y./norms(1,:) ) ) ;
## d2 = cross( d1, y(:,id2)' ) ;
d2 = cross( d1, d ) ;
d2 = d2/norm(d2) ;

[dum,iy] = sort( atan2( d2*y./norms(1,:), d1*y./norms(1,:) ) ) ;

y = y(:,iy) ;



## foo = d2*y./norms(1,iy);
## bar = d1*y./norms(1,iy);
## plot(bar,foo) ;

## keyboard

## Shift back y into place 
y = y+c(:,1:size(y,2)) ;
endfunction

