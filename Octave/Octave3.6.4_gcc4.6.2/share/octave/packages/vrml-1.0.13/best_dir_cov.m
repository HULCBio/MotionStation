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

##       [cv,wx] = best_dir_cov(x,a,sx,wd)
## 
## x    D x P     : 
## a    P x W     : Same as in best_dir, but sx is compulsory.
## sx   P x 1     :
## 
## wd (W+D) x 1   : ML estimate of [w;d]
##
## cv (W+D)x(W+D) : Covariance of the ML estimator at [w;d]
##
## wx (W+D)x(P*D) : derivatives of ML estimate wrt to observations
##

## Author:        Etienne Grossmann <etienne@egdn.net>
## Last modified: Setembro 2002

function  [cv,wx] = best_dir_cov(x,a,sx,wd)

[D,P] = size (x);
W = columns (a);
WD = prod (size (wd));

				# Check dimensions etc
if prod(size(sx)) != P
  error ("sx has %d != %d elements", prod (size (sx)), P);
end
if WD != W+D
  error ("wd has %d != %d elements", WD, W+D);
end
if rows (a) != P
  error ("a has %d != %d rows", rows (a), P);
end
if any (sx <= 0)
  error ("sx has some nonpositive elements");
end

sx = sx(:) ;
wd = wd(:) ;

w = wd(1:W);
d = wd(W+1:WD);

isig = diag(1./sx) ;		# Inverse of covariance matrix.

				# All derivatives are 1/2 of true value.

dsw = [zeros(W,1);d];		# Derivative of constraint |d|^2=1

				# Inverse of Hessian with side blocks
#keyboard
if 0,				# Readable code, bigger matrices
  d2ww = inv([ [-a';x]*isig*[-a,x'], dsw ; dsw' , 0 ]) ;

else				# Unreadable, smaller matrices
  ## tmp = (1./sx)*ones(1,WD);
  d2ww = inv( [ ([-a,x'].*((1./sx)*ones(1,WD)))'*[-a,x'], dsw ; dsw', 0 ]) ;
end
## if any(abs(D2ww(:)-d2ww(:))>sqrt(eps)), 
##  printf("Whoa!! %g",max(abs(D2ww(:)-d2ww(:)))) ;
## end

				# 2nd Derivatives wrt.  wd  and  x
				
## d2wx = zeros(WD+1,D*P);        # (padded with a row of zeros)
d2wx = zeros(WD,D*P);
				# Easy : wrt.  w  and  x
d2wx(1:W,:) = - kron(d',((1./sx)*ones(1,W))'.*a') ;

x = x'(:) ;

y = eye(D);			# tmp
tmp = zeros(D,D*P) ;
				# wrt. d  and  x
for i=1:D,
  
  ## d2wx(W+i,(i-1)*P+1:i*P) = \
  ##    2*x'*(kron(y(i,:))
  d2wx(W+i,:) =                        \
      2*x'*kron(y(i,:),kron(d,isig)) - \
      w'*a'*isig*kron(y(i,:),eye(P)) ;
end

## wx = d2ww*d2wx ;

wx = d2ww(1:WD,1:WD)*d2wx(1:WD,:) ;
cv = ((wx.*kron(ones(WD,D),sx'))*wx') ;

## cv = (wx*kron(eye(D),isig)*wx')(1:WD,1:WD) ;
#  if 0,
#    cv = (wx*kron(eye(D),diag(sx))*wx')(1:WD,1:WD) ;
#  elseif 0
#    cv = ((wx.*kron(ones(WD+1,D),sx'))*wx')(1:WD,1:WD) ;
#  end
#  if any(abs(cv2(:)-cv(:))>sqrt(eps)),
#    printf("whoa!! b_d_cov (2) : %f\n",max(abs(cv2(:)-cv(:))));
#    keyboard
#  end







endfunction

