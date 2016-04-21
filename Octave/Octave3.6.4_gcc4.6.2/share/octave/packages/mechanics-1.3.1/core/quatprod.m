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
%% @deftypefn {Function File} {@var{q3} = } quatprod (@var{q1}, @var{q2})
%% Product of two quaternions.
%% @end deftypefn

function q3 = quatprod (q1,q2)

q3 = [ q1(:,1).*q2(:,1) - q1(:,2).*q2(:,2) - q1(:,3).*q2(:,3) - q1(:,4).*q2(:,4) ...
       q1(:,1).*q2(:,2) + q1(:,2).*q2(:,1) + q1(:,3).*q2(:,4) - q1(:,4).*q2(:,3) ...
       q1(:,1).*q2(:,3) - q1(:,2).*q2(:,4) + q1(:,3).*q2(:,1) + q1(:,4).*q2(:,2) ...
       q1(:,1).*q2(:,4) + q1(:,2).*q2(:,3) - q1(:,3).*q2(:,2) + q1(:,4).*q2(:,1) ];

endfunction

