%%copyright (c) 2011 Juan Pablocarbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {@var{dqdt} = } RBequations_rot (@var{t}, @var{q}, @var{opt})
%% Rotational equations of motion of rigid body fixed in one point.
%% @end deftypefn

function dqdt = RBequations_rot(t,q, opt)
% TODO
% 2. Actuation

  w = q(1:3,1).';
  s = q(4:7,1).';

  I = opt.InertiaMoment;
  m = opt.Mass;
  Rcm = quatvrot(opt.CoM,s);
  grav = opt.Gravity;
  
  
  Tgrav = quatvrot((cross(Rcm,m*grav)),quatconj(s));

  dqdt = zeros(7,1);

  %% Euler Equations
  dqdt(1:3,1) = (cross( I .* w, w ) + Tgrav)./I;
  
  %% Quaternion equation
  Omega = unvech ([0 ; q(1:3,1); 0; -q(3,1); q(2,1); 0; -q(1,1); 0],-1);
  dqdt(4:7,1) = 0.5*Omega*q(4:7,1);
  
endfunction

