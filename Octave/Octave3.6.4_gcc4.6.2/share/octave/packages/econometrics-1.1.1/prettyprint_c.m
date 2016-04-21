## Copyright (C) 2003, 2004 Michael Creel <michael.creel@uab.es>
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

## this prints matrices with column labels but no row labels
function prettyprint_c(mat, clabels)

	printf("  ");

	# print the column labels
	clabels = ["        ";clabels]; # pad to 8 characters wide
	clabels = strjust(clabels,"right");

	k = columns(mat);
	for i = 1:k
		printf("%s  ",clabels(i+1,:));
	endfor

	# now print the row labels and rows
	printf("\n");
	k = rows(mat);
	for i = 1:k
		printf("  %8.3f", mat(i,:));
		printf("\n");
	endfor
endfunction
