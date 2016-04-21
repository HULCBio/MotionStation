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

## Grubbs tests for one or two outliers in data sample
## 
## Description:
## 
##      Performs Grubbs' test for one outlier, two outliers on one tail,
##      or two outliers on opposite tails, in small sample.
## 
## Usage:
## 
##      [pval,G,U] = grubbstest(x,type,opposite,twosided)
## 
## Arguments:
## 
##        x: a numeric vector or matrix of data values. Matrices are treated
##           columnwise (each column as independent set).
## 
## opposite: a logical (default 0) indicating whether you want to check not the value
##           with largest difference from the mean, but opposite (lowest,
##           if most suspicious is highest etc.)
## 
##     type: Integer value indicating test variant. 10 is a test for one
##           outlier (side is detected automatically and can be reversed
##           by 'opposite' parameter). 11 is a test for two outliers on
##           opposite tails, 20 is test for two outliers in one tail. Default 10.
## 
## two.sided: Logical value indicating if there is a need to treat this
##           test as two-sided. Default 0.
## 
## Details:
## 
##      The function can perform three tests given and discussed by Grubbs
##      (1950).
## 
##      First test (10) is used to detect if the sample dataset contains
##      one outlier, statistically different than the other values. Test
##      is based by calculating score of this outlier G (outlier minus
##      mean and divided by sd) and comparing it to appropriate critical
##      values. Alternative method is calculating ratio of variances of
##      two datasets - full dataset and dataset without outlier. The
##      obtained value called U is bound with G by simple formula.
## 
##      Second test (11) is used to check if lowest and highest value are
##      two outliers on opposite tails of sample. It is based on
##      calculation of ratio of range to standard deviation of the sample. 
## 
##      Third test (20) calculates ratio of variance of full sample and
##      sample without two extreme observations. It is used to detect if
##      dataset contains two outliers on the same tail.
## 
##      The p-values are calculated using 'grubbscdf' function.
## 
## Value:
## 
## G,U: the value statistic. For type 10 it is difference between
##           outlier and the mean divided by standard deviation, and for
##           type 20 it is sample range divided by standard deviation.
##           Additional value U is ratio of sample variances with and
##           withour suspicious outlier. According to Grubbs (1950) these
##           values for type 10 are bound by simple formula and only one
##           of them can be used, but function gives both. For type 20 the
##           G is the same as U.
## 
##  pval: the p-value for the test.
## 
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## References:
## 
##      Grubbs, F.E. (1950). Sample Criteria for testing outlying
##      observations. Ann. Math. Stat. 21, 1, 27-58.
## 
## 


function [pval,G,U] = grubbstest(x,type,opposite,twosided)


	if nargin<4
		twosided=0;
	end
	if nargin<3
		opposite=0;
	end
	if nargin<2
		type=10;
	end

if ~isvector(x) & ismatrix(x)

	pval = []; G = []; U = [];
	for i=1:(columns(x))
		[pp,gg,uu] = grubbstest(x(:,i),type,opposite,twosided);
		pval = [pval pp];
		G = [G gg];
		U = [U uu];
	end

elseif isvector(x)

	x = sort(x);
	n = length(x);

	if ~any([10 11 20] == type) 
		error("Incorrect type");
	end

	if (type == 11)
		G = (x(n) - x(1))/std(x);
		U = var(x(2:(n - 1)))/var(x) * (n - 3)/(n - 1);
		pval = 1 - grubbscdf(G, n, 11);
	elseif (type == 10)
		if xor(((x(n) - mean(x)) < (mean(x) - x(1))), opposite) 
			o = x(1);
			d = x(2:n);
		else
			o = x(n);
			d = x(1:(n-1));
		end
		G = abs(o - mean(x))/std(x);
        	U = var(d)/var(x) * (n - 2)/(n - 1);
        	pval = 1 - grubbscdf(G, n, 10);
	else
		if xor(((x(n) - mean(x)) < (mean(x) - x(1))), opposite) 
			U = var(x(3:n))/var(x) * (n - 3)/(n - 1);
		else
			U = var(x(1:(n - 2)))/var(x) * (n - 3)/(n - 1);
		end
		pval = grubbscdf(U, n, 20);
		G = NA;
	end
    
    if (twosided) 
        pval = 2 * pval;
        if (pval > 1) 
            pval = 2 - pval;
	end
    end

else
	error("x must be a matrix or a vector");
end

end

