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
%% @deftypefn {Function File} {@var{vn} = } quatvrot (@var{v}, @var{q})
%% Rotate vector v accoding to quaternionr q.
%% @end deftypefn

function rn = quatvrot(r,q)
  rn = quatprod(quatprod(q,[zeros(size(r,1),1) r]),quatconj(q))(:,2:end);
end
