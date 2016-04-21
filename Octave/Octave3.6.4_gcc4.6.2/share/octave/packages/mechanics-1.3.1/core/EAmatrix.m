%%copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: youcan redistribute itand/or modify
%%    it under the terms of the GNU General Public Licenseas publishedby
%%    the Free Software Foundation, either version 3 of the License, or
%%   any later version.
%%
%%    This program is distributed in the hope that it willbe useful,
%%   but WITHOUTaNY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FORa PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have receivedacopy of the GNU General Public License
%%   along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{output} = } EAmatrix (@var{angles}, @var{convention})
%% Generates the Eulerangle rotation matrix in the given convention.
%%
%% Using the equivalence between Euler angles and rotation composition, it is
%% possible to change to and from matrix convention.
%% Fixed (world)axes and column vectors, with intrinsic composition
%%  (composition of rotations about body axes) ofactive rotationsand the
%%  right-handed rule for the positive sign of the angles are assumed. This means
%%  for example that a convention named (YXZ) is the result of performing firstan
%%  intrinsic Y rotation, followedbyan Xanda Z rotations, in the moving axes.
%%
%%  Subindexes refer to the order in which theangles are applied. Trigonometric
%%  notation hasbeen simplified. For example,c1 meanscos(θ1)and s2 means
%%  sin(θ2).as we assumed intrinsic and active compositions, θ1 is the external
%% angle of the static definition (angle between fixed axis x and line of nodes)
%% and θ3 the internal angle (from the line of nodes to rotated axis X). The
%%  following table can be used both ways, to obtainan orientation matrix from
%%  Euler angles and to obtain Euler angles from the matrix. The possible
%% combinations of rotations equivalent to Euler angles are shown here.
%% @end deftypefn

function varargout =  EAmatrix (ang,convention = [3 1 3], handle = false)

  if handle

    if !ischar (convention)
      letters = 'XYZ';
      convention = letters(convention);
    end

    varargout{1} = eval(["@" toupper(convention)]);

    if nargout > 1
      varargout{2} = eval(["@d" toupper(convention)]);
    end
  else
    if ischar (convention)
      convention =arrayfun (@str2num, ...
    strrep( strrep( strrep ( toupper (convention), "X","1"),"Y","2"),"Z","3") );
    end

    I = eye(3)(convention,:);
    R1 = rotv (I(1,:),-ang(1));
    %% Rotation of axes
    M = R1 * rotv (I(2,:),-ang(2)) * rotv (I(3,:),-ang(3));

    varargout{1} = M;

    if nargout > 1
    %% Conversion from angle derivatives to angular speed
    R1e2 = I(2,:)*R1';
    varargout{2} = [ I(1,:)*M(:,1) R1e2*M(:,1) 0; ...
           I(1,:)*M(:,2) R1e2*M(:,2) 0; ...
           I(1,:)*M(:,3) R1e2*M(:,3) 1];
    end
  end

endfunction

function M =  ZXZ(ang)
  c = cos(ang);
  s = sin(ang);
  M = [ c(1)*c(3) - s(1)*c(2)*s(3), -c(1)*s(3) - s(1)*c(2)*c(3),  s(1)*s(2); ...
        c(1)*c(2)*s(3) + s(1)*c(3),  c(1)*c(2)*c(3) - s(1)*s(3), -c(1)*s(2); ...
        s(2)*s(3),                   s(2)*c(3),                   c(2)];
endfunction

function dM = dZXZ(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ s(2)*s(3),c(3),0; ...
        s(2)*c(3),-s(3),0; ...
        c(2),0,1];

endfunction

function M =   ZYZ(ang)
  c = cos(ang);
  s = sin(ang);
  M = [ c(1)*c(2)*c(3)-s(1)*s(3), -c(1)*c(2)*s(3)-s(1)*c(3), c(1)*s(2);...
        c(1)*s(3)+s(1)*c(2)*c(3),  c(1)*c(3)-s(1)*c(2)*s(3), s(1)*s(2);...
       -s(2)*c(3),                 s(2)*s(3),                c(2)];
endfunction

function dM = dZYZ(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ -s(2)*c(3),s(3),0; ...
        s(2)*s(3),c(3),0; ...
        c(2),0,1];

endfunction

function M =   XYX(ang)
  c = cos(ang);
  s = sin(ang);
  M = [c(2),0,s(2); ...
       c(1)*s(2)*s(3)+s(1)*s(2)*c(3),c(1)*c(3)-s(1)*s(3),-c(1)*c(2)*s(3)-s(1)*c(2)*c(3); ...
       s(1)*s(2)*s(3)-c(1)*s(2)*c(3),c(1)*s(3)+s(1)*c(3),c(1)*c(2)*c(3)-s(1)*c(2)*s(3)];
endfunction

function dM = dXYX(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ c(2),s(2)*s(3),0; ...
        0,c(3),0; ...
        s(2),-c(2)*s(3),1];

endfunction

function M =   YXY(ang)
  c = cos(ang);
  s = sin(ang);
  M = [c(1)*c(3)-s(1)*c(2)*s(3),s(1)*s(2),c(1)*s(3)+s(1)*c(2)*c(3); ...
       s(2)*s(3),c(2),-s(2)*c(3); ...
       -c(1)*c(2)*s(3)-s(1)*c(3),c(1)*s(2),c(1)*c(2)*c(3)-s(1)*s(3)];
endfunction

function dM = dYXY(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ s(2)*s(3),c(3),0; ...
        c(2),0,0; ...
        -s(2)*c(3),s(3),1];

endfunction

function M =   XZY(ang)
  c = cos(ang);
  s = sin(ang);
  M = [c(2)*c(3),-s(2),c(2)*s(3); ...
       s(1)*s(3)+c(1)*s(2)*c(3),c(1)*c(2),c(1)*s(2)*s(3)-s(1)*c(3); ...
       s(1)*s(2)*c(3)-c(1)*s(3),s(1)*c(2),s(1)*s(2)*s(3)+c(1)*c(3)];
endfunction

function dM = dXZY(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ c(2)*c(3),-s(3),0; ...
        -s(2),0,0; ...
        c(2)*s(3),c(3),1];

endfunction

function M =   XYZ(ang)
  c = cos(ang);
  s = sin(ang);
  M = [c(2)*c(3),-c(2)*s(3),s(2); ...
       c(1)*s(3)+s(1)*s(2)*c(3),c(1)*c(3)-s(1)*s(2)*s(3),-s(1)*c(2); ...
       s(1)*s(3)-c(1)*s(2)*c(3),c(1)*s(2)*s(3)+s(1)*c(3),c(1)*c(2)];
endfunction

function dM = dXYZ(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ c(2)*c(3),s(3),0; ...
        -c(2)*s(3),c(3),0; ...
        s(2),0,1];

endfunction

function M =   YXZ(ang)
  c = cos(ang);
  s = sin(ang);
  M = [s(1)*s(2)*s(3)+c(1)*c(3),s(1)*s(2)*c(3)-c(1)*s(3),s(1)*c(2); ...
       c(2)*s(3),c(2)*c(3),-s(2); ...
       c(1)*s(2)*s(3)-s(1)*c(3),s(1)*s(3)+c(1)*s(2)*c(3),c(1)*c(2)];
endfunction

function dM = dYXZ(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ c(2)*s(3),c(3),0; ...
        c(2)*c(3),-s(3),0; ...
        -s(2),0,1];

endfunction

function M =  YZX(ang)
  c = cos(ang);
  s = sin(ang);
  M = [s(1)*s(2)*s(3)+c(1)*c(2),s(1)*c(2)*s(3)-c(1)*s(2),s(1)*c(3); ...
       s(2)*c(3),c(2)*c(3),-s(3); ...
       c(1)*s(2)*s(3)-s(1)*c(2),c(1)*c(2)*s(3)+s(1)*s(2),c(1)*c(3)];
endfunction

function dM = dYZX(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ s(2)*c(3),s(2)*s(3),0; ...
        c(2)*c(3),c(2)*s(3),0; ...
        -s(3),c(3),1];

endfunction

function M =   ZXY(ang)
  c = cos(ang);
  s = sin(ang);
  M = [c(1)*c(3)-s(1)*s(2)*s(3),-s(1)*c(2),c(1)*s(3)+s(1)*s(2)*c(3); ...
       c(1)*s(2)*s(3)+s(1)*c(3),c(1)*c(2),s(1)*s(3)-c(1)*s(2)*c(3); ...
       -c(2)*s(3),s(2),c(2)*c(3)];
endfunction

function dM = dZXY(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ -c(2)*s(3),c(3),0; ...
        s(2),0,0; ...
        c(2)*c(3),s(3),1];

endfunction

function M =   ZYX(ang)
  c = cos(ang);
  s = sin(ang);
  M = [ c(1)*c(2)-s(1)*s(2)*s(3),-s(1)*c(3),s(1)*c(2)*s(3)+c(1)*s(2); ...
  c(1)*s(2)*s(3)+s(1)*c(2),c(1)*c(3),s(1)*s(2)-c(1)*c(2)*s(3); ...
  -s(2)*c(3),s(3),c(2)*c(3)];
endfunction

function dM = dZYX(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ -s(2)*c(3),s(2)*s(3),0; ...
        s(3),c(3),0; ...
        c(2)*c(3),-c(2)*s(3),1];

endfunction

function M =   XZX(ang)
  c = cos(ang);
  s = sin(ang);
  M = [ c(2),-s(2),0; ...
  c(1)*s(2)*c(3)-s(1)*s(2)*s(3),c(1)*c(2)*c(3)-s(1)*c(2)*s(3),-c(1)*s(3)-s(1)*c(3); ...
  c(1)*s(2)*s(3)+s(1)*s(2)*c(3),c(1)*c(2)*s(3)+s(1)*c(2)*c(3),c(1)*c(3)-s(1)*s(3)];
endfunction

function dM = dXZX(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ c(2),s(2)*s(3),0; ...
        -s(2),c(2)*s(3),0; ...
        0,c(3),1];

endfunction

function M =   YZY(ang)
  c = cos(ang);
  s = sin(ang);
  M = [ c(1)*c(2)*c(3)-s(1)*s(3),-c(1)*s(2),c(1)*c(2)*s(3)+s(1)*c(3); ...
  s(2)*c(3),c(2),s(2)*s(3); ...
  -c(1)*s(3)-s(1)*c(2)*c(3),s(1)*s(2),c(1)*c(3)-s(1)*c(2)*s(3)];
endfunction

function dM = dYZY(ang)
  c = cos(ang);
  s = sin(ang);
  dM = [ s(2)*c(3),-s(3),0; ...
        c(2),0,0; ...
        s(2)*s(3),c(3),1];

endfunction

%!shared C, S, ANG
%! ANG = pi/2*eye(3);
%! C = cos(ANG);
%! S = sin(ANG);

%!test
%! fhandle = EAmatrix (0,"ZXZ",true);
%! for i=1:3
%!  c = C(i,:); s = S(i,:);
%!  ZXZ = [c(1)*c(3)-c(2)*s(1)*s(3) -c(1)*s(3)-c(3)*c(2)*s(1) s(2)*s(1); ...
%!         c(2)*c(1)*s(3)+c(3)*s(1) c(1)*c(2)*c(3)-s(1)*s(3) -c(1)*s(2); ...
%!          s(3)*s(2)                c(3)*s(2)                c(2)];
%!
%!  assert (EAmatrix (ANG(i,:)), ZXZ);
%!  assert (fhandle(ANG(i,:)), ZXZ);
%! end

%!test
%! [Mh dMh] = EAmatrix (0,"ZXZ",true);
%! [M dM] = EAmatrix (ANG(1,:),"ZXZ");
%!  c = C(1,:); s = S(1,:);
%!  dZXZ = [ s(2)*s(3),c(3),0; ...
%!        s(2)*c(3),-s(3),0; ...
%!        c(2),0,1];
%!
%!  assert (dM, dZXZ);
%!  assert (dMh(ANG(1,:)), dZXZ);
