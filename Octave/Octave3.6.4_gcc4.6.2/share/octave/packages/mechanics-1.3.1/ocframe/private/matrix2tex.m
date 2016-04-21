## Copyright (C) 2010 Johan Beke
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function matrix2tex(m)
	printf("[tex]\\left(\\begin{array}{")
	for c=1:columns(m)
		printf("c")
	end
	printf("}\n")
	for r=1:rows(m)
		for c=1:columns(m)
			if (c!=columns(m))
				printf(" %3.3e &",m(r,c))
			else
				printf(" %3.3e \\\\\n",m(r,c))
			end
		end
	end
	printf("\\end{array}\\right)[/tex]\n\n")
end
