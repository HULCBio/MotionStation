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

## Remove the value(s) most differing from the mean
## 
## Description:
## 
##      This function can remove the outliers or replace by sample mean or median.
## 
## Usage:
## 
##      [res] = rmoutlier(x,fill,median,opposite)
## 
## Arguments:
## 
##        x: a dataset, most frequently a vector. If argument is a
##           matrix, each column is treated as independent dataset. 
## 
##     fill: If set to 1 (default 0), the median or mean is placed instead of
##           outlier. Otherwise,  the outlier(s) is/are simply removed. 
## 
##   median: If set to 1 (default 0), median is used instead of mean in outlier
##           replacement. 
## 
## opposite: if set to 1 (default 0), replaces opposite value (if largest value has
##           maximum difference from the mean, it replaces smallest and vice
##           versa)
## 
## Value:
## 
##      A dataset of the same type as argument, with outlier(s) removed or
##      replaced by appropriate means or medians.
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## 


function [res] = rmoutlier(x,fill,median,opposite)

	if nargin<4
		opposite=0;
	end
	if nargin<3
		median=0;
	end
	if nargin<2
		fill=0;
	end

if ~isvector(x) & ismatrix(x)
	res = [];
	for i=1:columns(x)
		rr = rmoutlier(x(:,i),fill,median,opposite);
		res = [res rr];
	end

elseif isvector(x)
	wo = x;
	ou = find(x == outlier(x,opposite));
		for i=1:length(ou)
			wo(ou(i)) = [];
		end

        if ~fill
		res = wo;
	else
       		res = x;
 		for i=1:length(ou)
			if median 
			res(ou(i)) = median(wo);
			else
			res(ou(i)) = mean(wo);
			end
		end
  	end
end
end
