## Copyright (C) 2006 Joseph Wakeling <joseph.wakeling@webdrake.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} infoentr_seq (@var{seq_x}, @var{seq_y})
## If just one input, calculates Shannon Information Entropy
## of the sequence x:
##      H(X) = @math{\sum_{x \in X} p(x) log2(1/p(x))}
##
## If two inputs, calculates joint entropy of the concurrent
## sequences x and y:
##   H(X,Y) = @math{\sum_{x \in X, y \in Y} p(x,y) log2(1/p(x,y))}
##
## @example
## @group
##          X=[1, 1, 2, 1, 1];
##          infoentr_seq(X)
##          infoentr_seq([1,2,2,2,1,1,1,1,1],[1,2,2,2,2,2,1,1,1])
## @end group
## @end example
## @end deftypefn
## @seealso{infogain_seq}

function H = infoentr_seq(x,y)
if(nargin<1 || nargin>2)
	usage("infoentr_seq(x,y)")
endif

if(nargin==2)
	if((rows(x)~=rows(y)) || (columns(x)~=columns(y)))
		error("Arguments do not have same dimension.")
	endif
endif

# We check that first argument is a vector, and
# if necessary convert to row vector.
if(columns(x)==1)
	x = x.'
elseif(rows(x)~=1)
	error("First argument is not a vector.");
endif


if(nargin==1)
	X = create_set(x);
	Nx = length(X);
	
	# Calculate probability Pr(x)
	for i=1:Nx
		Pr(i) = sum(x==X(i));
	endfor
	if(sum(Pr) ~= length(x))
		fprintf(stdout,"Sum is wrong.\n");
	endif
	Pr = Pr/length(x);
	
	# Calculate Shannon information content h(x) = log2(1/Pr(x))
	h = log2(1 ./ Pr);
	h(find(h==Inf)) = 0;
	H = sum(Pr .* h);
else
	# Ensure that the second argument is a vector, and
	# if necessary convert to row vector.  Actually
	# this is probably taken care of by the check on
	# dimension agreement and the check on x above. :-)
	if(columns(y)==1)
		y = y.'
	elseif(rows(y)~=1)
		error("Second argument is not a vector.");
	endif
	
	X = create_set(x);
	Y = create_set(y);
	Nx = length(X);
	Ny = length(Y);
	
	# Calculate joint probability Pr(x,y)
	for i=1:Nx
		for j=1:Ny
			Pr(i,j) = (x==X(i))*(y==Y(j)).';
		endfor
	endfor
	if sum(sum(Pr)) ~= length(x)
		fprintf(stdout,"Sum is wrong.\n");
	endif
	Pr = Pr/length(x);
	# Calculate Shannon information content h(x,y) = log2(1/Pr(x,y))
	h = log2(1 ./ Pr);
	[GGx,GGy]=find(Pr==0);

        if ~isempty(GGx)
            h(GGx,GGy)= 0;
	end
	H = sum(sum(Pr .* h));
endif
end
%!assert(infoentr_seq([2, 2, 1, 1, 2]),0.970950594454669,1e-5)
