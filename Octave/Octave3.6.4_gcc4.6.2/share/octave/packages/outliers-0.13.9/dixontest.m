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

## Dixon tests for outlier
## 
## Description:
## 
##      Performs several variants of Dixon test for detecting outlier in
##      data sample.
## 
## Usage:
## 
##      [pval,Q] = dixontest(x,type,opposite,twosided)
## 
## Arguments:
## 
##        x: a numeric vector or matrix of data values. Each column of a
##           matrix is treated as independent sample set.
## 
## opposite: a logical (0,1) indicating whether you want to check not the value
##           with  largest difference from the mean, but opposite (lowest,
##           if most suspicious is highest etc.). Default 0.
## 
##     type: an integer specyfying the variant of test to be performed.
##           Possible values are compliant with these given by Dixon
##           (1950): 10, 11, 12, 20, 21. If this value is set to zero, a
##           variant of the test is chosen according to sample size (10
##           for 3-7, 11 for 8-10, 21 for 11-13,  22 for 14 and more). The
##           lowest or highest value is selected automatically, and can be
##           reversed used 'opposite' parameter. 
## 
## two.sided: treat test as two-sided (default=1). 
## 
## Details:
## 
##      The p-value is calculating by interpolation using 'dixoncdf' and
##      'qtable'. According to Dixon (1951) conclusions, the critical
##      values can be obtained numerically only for n=3. Other critical
##      values are obtained by simulations, taken from original Dixon's
##      paper, and regarding corrections given by Rorabacher (1991).
## 
## Value:
## 
## 	Q: the value of Dixon Q-statistic.
## 
##  	pval: the p-value for the test.
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## References:
## 
##      Dixon, W.J. (1950). Analysis of extreme values. Ann. Math. Stat.
##      21, 4, 488-506.
## 
##      Dixon, W.J. (1951). Ratios involving extreme values. Ann. Math.
##      Stat. 22, 1, 68-78.
## 
##      Rorabacher, D.B. (1991). Statistical Treatment for Rejection of
##      Deviant Values: Critical Values of Dixon Q Parameter and Related
##      Subrange Ratios at the 95 percent Confidence Level. Anal. Chem.
##      83, 2, 139-146.
## 


function [pval,Q] = dixontest(x,type,opposite,twosided)

	if nargin<4
		twosided=1;
	end
	if nargin<3
		opposite=0;
	end
	if nargin<2
		type=0;
	end


if ~isvector(x) & ismatrix(x)
	pval = []; Q = [];
	for i=1:(columns(x))
		[pp,qq] = dixontest(x(:,i),type,opposite,twosided);
		pval = [pval pp];
		Q = [Q qq];
	end

elseif isvector(x)

	x = sort(x);
	n = length(x);

	if (type == 10 | type == 0) & (n < 3 | n > 30) 
		error("Sample size must be in range 3-30");
	elseif (type == 11 & (n < 4 | n > 30))
		error("Sample size must be in range 4-30");
    	elseif (type == 12 & (n < 5 | n > 30))
		error("Sample size must be in range 5-30");
	elseif (type == 20 & (n < 4 | n > 30)) 
		error("Sample size must be in range 4-30");
	elseif (type == 21 & (n < 5 | n > 30)) 
		error("Sample size must be in range 5-30");
	elseif (type == 22 & (n < 6 | n > 30)) 
		error("Sample size must be in range 6-30");
	end

	if ~any([0 10 11 12 20 21 22] == type) 
		error("Incorrect type");
	elseif (type == 0)
		if (n <= 7) 
            		type=10;
        	elseif (n > 7 & n <= 10) 
			type=11;
        	elseif (n > 10 & n <= 13) 
			type=21;
	        else
		        type=22;
		end
	end

    if xor(((x(n) - mean(x)) < (mean(x) - x(1))), opposite) 
        if (type == 10)
            Q = (x(2) - x(1))/(x(n) - x(1));
        elseif (type == 11) 
            Q = (x(2) - x(1))/(x(n - 1) - x(1));
        elseif (type == 12) 
            Q = (x(2) - x(1))/(x(n - 2) - x(1));
        elseif (type == 20) 
            Q = (x(3) - x(1))/(x(n) - x(1));
        elseif (type == 21) 
            Q = (x(3) - x(1))/(x(n - 1) - x(1));
        else 
            Q = (x(3) - x(1))/(x(n - 2) - x(1));
	end
    else 
        if (type == 10) 
            Q = (x(n) - x(n - 1))/(x(n) - x(1));
        elseif (type == 11) 
            Q = (x(n) - x(n - 1))/(x(n) - x(2));
        elseif (type == 12) 
            Q = (x(n) - x(n - 1))/(x(n) - x(3));
        elseif (type == 20) 
            Q = (x(n) - x(n - 2))/(x(n) - x(1));
        elseif (type == 21) 
            Q = (x(n) - x(n - 2))/(x(n) - x(2));
        else 
            Q = (x(n) - x(n - 2))/(x(n) - x(3));
	end
    end
    pval = dixoncdf(Q, n, type);
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

