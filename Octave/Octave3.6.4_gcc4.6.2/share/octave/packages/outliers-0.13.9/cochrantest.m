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

## Test for outlying or inlying variance
## 
## Description:
## 
##      This test is useful to check if largest variance in several groups
##      of data is "outlying" and this group should be rejected.
##      Alternatively, if one group has very small variance, we can test
##      for "inlying" variance.
## 
## Usage:
## 
##      [pval,C] = cochrantest(x,inlying,n)
## 
## Arguments:
## 
##        x: A vector of variances or matrix of observations. 
## 
##        n: If object is a vector, n should be another vector, giving
##           number of data in each corresponding group. If object is a
##           matrix, n should be omitted.
## 
##  inlying: Test smallest variance instead of largest.
## 
## Details:
## 
##      The corresponding p-value is calculated using 'cochrancdf' function.
## 
## Value:
## 
##        C: the value of Cochran-statistic.
## 
##  p.value: the p-value for the test.
## 
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## References:
## 
##      Snedecor, G.W., Cochran, W.G. (1980). Statistical Methods (seventh
##      edition). Iowa State University Press, Ames, Iowa.
## 
## 
## 

function [pval,C] = cochrantest(x,inlying,n)

	if nargin<3
		n=NA;
	end
	if nargin<2
		inlying=0;
	end

	if ismatrix(x) & ~isvector(x)
		n = rows(x);
		x = var(x,2);
	else
		n = mean(n);
	end 

		k = length(x);

	if inlying
		C = min(min(x))/sum(sum(x));
		pval = cochrancdf(C,n,k);
	else
		C = max(max(x))/sum(sum(x));
		pval = 1 - cochrancdf(C,n,k);
	end

end

