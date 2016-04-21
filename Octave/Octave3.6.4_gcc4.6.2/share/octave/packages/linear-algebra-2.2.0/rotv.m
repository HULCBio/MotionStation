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
## @deftypefn{Function File} {@var{r} = } rotv ( v, ang ) 
## @cindex  
## The functionrotv calculates a Matrix of rotation about @var{v} w/ angle |v|
## r = rotv(v [,ang])    
##
## Returns the rotation matrix w/ axis v, and angle, in radians, norm(v) or
## ang (if present).
##
## rotv(v) == w'*w + cos(a) * (eye(3)-w'*w) - sin(a) * crossmat(w)
## 
## where a = norm (v) and w = v/a.
##
## v and ang may be vertically stacked : If 'v' is 2x3, then 
## rotv( v ) == [rotv(v(1,:)); rotv(v(2,:))]
##
## @example
## 
## @end example
## @seealso{rotparams, rota, rot}
## @end deftypefn

function r = rotv(v ,ang)

  if nargin > 1
    v = v.*((ang(:)./sqrt(sum(v'.^2))')*ones(1,3));
  end
  ## For checking only
  ## v00 = v ;
  ## static toto = floor(rand(1)*100) ;
  ## toto
  a = sqrt(sum(v'.^2))' ; 
  oka = find(a!=0);
  if all(size(oka)),
    v(oka,:) = v(oka,:)./(a(oka)*ones(1,3)) ; 
  end
  ## ca = cos(a);
  ## sa = sin(a);

  N = size(v,1) ; N3 = 3*N ;
  r = (reshape( v', N3,1 )*ones(1,3)).*kron(v,ones(3,1)) ;
  r += kron(cos(a),ones(3,3)) .* (kron(ones(N,1),eye(3))-r) ;

  ## kron(cos(a),ones(3,3)) .* (kron(ones(N,1),eye(3))-r0) 
  ## cos(a)

  tmp = zeros(N3,3) ;
  tmp( 2:3:N3,1 ) =  v(:,3) ;
  tmp( 1:3:N3,2 ) = -v(:,3) ;
  tmp( 3:3:N3,1 ) = -v(:,2) ;
  tmp( 1:3:N3,3 ) =  v(:,2) ;
  tmp( 2:3:N3,3 ) = -v(:,1) ;
  tmp( 3:3:N3,2 ) =  v(:,1) ;
  ## keyboard
  r -= kron(sin(a),ones(3)) .* tmp ;

endfunction

## For checking only
## r2 = zeros(N3,3) ;
## for i=1:size(v,1),
##   v0 = v00(i,:);
##   t = norm(v0);
##   if t, v0 = v0/t; end;
##   r2(3*i-2:3*i,:) = v0'*v0 + cos(t)*(eye(3)-v0'*v0) + -sin(t)*[0, -v0(3), v0(2);v0(3), 0, -v0(1);-v0(2), v0(1), 0];
## end 
## max(abs(r2(:)-r(:)))
