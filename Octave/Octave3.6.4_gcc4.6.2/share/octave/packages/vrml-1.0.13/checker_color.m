## Copyright (C) 2010-2012 Etienne Grossmann <etienne@egdn.net>
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

## col = checker_color (R,C, checker, col)

function col = checker_color (checker, col, R,C)

if length (checker) == 1, checker = [checker, checker]; end

if checker(1) > 0, checker(1) = - (C-1)/checker(1); end
if checker(2) > 0, checker(2) = - (R-1)/checker(2); end

checker *= -1;

colx = 2 * (rem (0:C-2,2*checker(1)) < checker(1)) - 1;
coly = 2 * (rem (0:R-2,2*checker(2)) < checker(2)) - 1;
icol = 1 + ((coly'*colx) > 0);
				# Keep at most 1st 2 colors of col for the
				# checker
if prod (size (col)) == 2,
  col = [1;1;1]*col;
elseif  prod (size (col)) < 6, # Can't be < 3 because of previous code
  col = col(1:3)(:);
  if all (col >= 1-eps), col = [col [0;0;0]];	# Black and White
  else                   col = [col [1;1;1]];	# X and White
  end
end
col = reshape (col(:),3,2);
col = col(:,icol);
