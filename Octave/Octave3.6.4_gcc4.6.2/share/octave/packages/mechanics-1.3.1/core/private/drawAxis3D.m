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

function drawAxis3D (p,E,c)
  for i=1:3
     l =[p; p+E(i,:)];
     line(l(:,1),l(:,2),l(:,3),'color',c(i,:),'linewidth',2);
  end
end
