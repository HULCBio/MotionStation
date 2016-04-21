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

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{vstacked}, @var{astacked}] =} rotparams (@var{rstacked})
## @cindex  
##  The function w = rotparams (r)            - Inverse to rotv().
##  Using, @var{w}    = rotparams(@var{r})  is such that
##  rotv(w)*r' == eye(3).
##
##  If used as, [v,a]=rotparams(r) ,  idem, with v (1 x 3) s.t. w == a*v.
## 
##     0 <= norm(w)==a <= pi
## 
##     :-O !!  Does not check if 'r' is a rotation matrix.
##
##  Ignores matrices with zero rows or with NaNs. (returns 0 for them)
##
## @seealso{rotv}
## @end deftypefn

function [vstacked, astacked] = rotparams (rstacked)

  N = size (rstacked,1) / 3;

  ## ang = 0 ;
  ## if length(varargin),
  ##   if strcmp(varargin{1},'ang'),    ang = 1;  end
  ## end
  ok = all ( ! isnan (rstacked') ) & any ( rstacked' );
  ok = min ( reshape (ok,3,N) );
  ok = find (ok) ;
  ## keyboard
  vstacked = zeros (N,3);
  astacked = zeros (N,1);
  for j = ok,
    r = rstacked(3*j-2:3*j,:);
    [v,f] = eig (r); 
    f = diag(f);

    [m,i] = min (abs (real (f)-1));
    v = v(:,i);

    w = null (v');
    u = w(:,1);
    a = u'*r*u;
    if a<1,
      a = real (acos (u'*r*u));
    else
      a = 0;
    endif
    ## Check orientation
    x=r*u;
    if v'*[0 -u(3) u(2); u(3) 0 -u(1);-u(2) u(1) 0]*x < 0,  v=-v; endif


    if nargout <= 1,   v = v*a; endif
    vstacked(j,:) = -v';
    astacked(j) = a;
  endfor
endfunction
