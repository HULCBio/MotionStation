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

##       [d,w,rx,cv,wx] = best_dir( x, [a , sx ] )
##
## Some points  x,  are observed and one assumes that they belong to
## parallel planes. There is an unknown direction  d  s.t. for each
## point  x(i,:), one has :
##
##         x(i,:)*d == w(j(i)) + noise
##
## where j is known(given by the matrix  a ), but  w  is unknown.
##
## Under the assumption that the error on  x  are i.i.d. gaussian,
## best_dir() returns the maximum likelihood estimate of  d  and  w.
##
## This function is slower when cv is returned.
##
## INPUT :
## -------
## x  : D x P    P points. Each one is the sum of a point that belongs
##               to a plane and a noise term.
##
## a  : P x W    0-1 matrix describing association of points (rows of 
##               x) to planes :
##
##           a(p,i) == 1 iff point x(p,:) belongs to the i'th plane.
##
##                                                Default is ones(P,1)
## 
## sx : P x 1    Covariance of x(i,:) is sx(i)*eye(D). 
##                                                Default is ones(P,1)
## OUTPUT :
## --------
## d  : D x 1    All the planes have the same normal, d. d has unit
##               norm.
##
## w  : W x 1    The i'th plane is { y | y*d = w(i) }.
##
## rx : P x 1    Residuals of projection of points to corresponding plane.
##
##
##               Assuming that the covariance of  x  (i.e. sx) was known
##               only up to a scale factor, an estimate of the
##               covariance of  x  and  [w;d]  are
##
##                 sx * mean(rx.^2)/mean(sx)       and
##                 cv * mean(rx.^2)/mean(sx),  respectively.
##
## cv : (D+W)x(D+W) 
##               Covariance of the estimator at [d,w] ( assuming that
##               diag(covariance(vec(x))) == sx ). 
##
## wx : (D+W)x(D*P)
##               Derivatives of [w;d] wrt to x.
##
## Author  : Etienne Grossmann <etienne@egdn.net>
## Created : March 2000
##
function [d,w,rx,cv,wx] = best_dir( x, a, sx )

[D,P] = size(x) ;
## Check dimension of args
if nargin<2, 
  a = ones(P,1) ; 
elseif size(a,1) != P,
  error ("best_dir : size(a,1)==%d != size(x,2)==%d\n",size(a,1),P);
  ## keyboard
end
if isempty (a)
  error ("best_dir : a is empty. This will not do!\n");
  ## keyboard
end

W = size(a,2) ;
if nargin<3, 
  sx = ones(P,1) ;
else
  if prod(size(sx)) != P,
    error ("best_dir : sx has %d elements, rather than P=%d\n",
	   prod(size(sx)),P);
    ## keyboard
  end
  if !all(sx)>0,
    error ("best_dir : sx has non positive element\n");
    ## keyboard
  end
end
sx = sx(:);


## If not all points belong to a plane, clean  a.

keep = 0 ;
if ! all(sum([a';a'])),		# trick for single-column  a

  ## if verbose, printf ("best_dir : Cleaning up useless rows of 'a'\n"); end
  keep = find(sum([a';a'])) ;
  ## [d,w,cv] = best_dir(x(keep,:),a(keep,:),sx(keep)) ;
  ## return ;
  x = x(:,keep);
  a = a(keep,:);
  sx = sx(keep);
  P_orig = P ;
  P = prod(size(keep));
end

## If not all planes are used, remove some rows of a.
if !all(sum(a)),
  keep = find(sum(a)) ;
  if nargout >= 4, 
    [d,ww,rx,cv2] = best_dir(x,a(:,keep),sx) ;
    cv = zeros(W+D,W+D) ;
    cv([1:3,3+keep],[1:3,3+keep]) = cv2 ;
  else             
    [d,ww,rx]    = best_dir(x,a(:,keep),sx) ;
  end
  w = zeros(W,1);
  w(keep) = ww ;
  return
end
## Now,  a  has rank  W  for sure.

## tmp = diag(1./sx) ;
tmp = (1./sx)*ones(1,W) ;
tmp2 = inv(a'*(tmp.*a))*(a.*tmp)' ; ;
tmp = x*(eye(P) - tmp2'*a') ; 
## tmp = tmp*diag(1./sx)*tmp' ;
tmp = (tmp.*(ones(D,1)*(1./sx)'))*tmp' ;

[u,S,v] = svd(tmp) ;
d = v(:,D) ;
w = tmp2*x'*d ;

rx = (x'*d - a*w) ;

if nargout >= 4,
  wd = [w;d];
  ## shuffle = ( ones(D,1)*[0:P-1]+[1:P:P*D]'*ones(1,P) )(:) ;
  ## [cv,wx] = best_dir_cov(x',a,sx,wd) ;
  ## ## wx = wx(:,shuffle) ;

  [cv,wx] = best_dir_cov(x,a,sx,wd) ;

  ##  [cv2,wx2] = best_dir_cov2(x,a,sx,wd) ;
  ##    if any(abs(cv2(:)-cv(:))>eps),
  ##      printf("test cov : bug 1\n") ;
  ##      keyboard
  ##    end
  ##    if any(abs(wx2(:)-wx(:))>eps),
  ##      printf("test cov : bug 2\n") ;
  ##      keyboard
  ##    end

end


if keep,
  tmp = zeros(P_orig,1) ;
  tmp(keep) = rx ; 
  rx = tmp ;
  if nargout >= 5,
    k1 = zeros(1,P_orig) ; k1(keep) = 1 ; k1 = kron(ones(1,D),k1) ;
    tmp = zeros(D+W,P_orig*D) ;
    tmp(:,k1) = wx ;
    wx = tmp ;
  end
end

endfunction


