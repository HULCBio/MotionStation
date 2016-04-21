## Copyright (C) 2007 Lukasz Komsta, http://www.komsta.net/
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

## Find value with largest difference from the mean
## 
## Description:
## 
##      Finds value with largest difference between it and sample mean,
##      which can be an outlier.
## 
## Usage:
## 
##      [out] = outlier(x,opposite,logical) 
## 
## Arguments:
## 
##        x: a data sample, vector in most cases. If argument is a
##          matrix, each column is treated as independent dataset. 
## 
## opposite: if set to 1 (default 0), gives opposite value (if largest value has
##           maximum difference from the mean, it gives smallest and vice
##           versa)
## 
##  logical: if set to 1 (default 0), gives vector of logical values, and possible
##           outlier position is marked by 1, others are 0
## 
## Value:
## 
##      A vector of value(s) with largest difference from the mean.
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
##      
## 


function [out] = outlier(x,opposite,logical) 

	if nargin<3
		logical=0;
	end
	if nargin<2
		opposite=0;
	end

   if ~isvector(x) & ismatrix(x)
	out = [];
	for i=1:columns(x)
		oo = outlier(x(:,i),opposite,logical);
		out = [out oo];
	end
   elseif isvector(x)

	if (xor(((max(x) - mean(x)) < (mean(x) - min(x))), opposite)) 
            if ~logical
                out = min(x);
            else 
		out = (x == min(x));
	    end
        else 
            if ~logical
                out = max(x);
            else 
		out = (x == max(x));
	    end
	end

    else
	    error("x must be a vector or a matrix");
    end

end

