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

## Chi-squared test for outlier
## 
## Description:
## 
##      Performs a chisquared test for detection of one outlier in a
##      vector.
## 
## Usage:
## 
##      [pval,chisq] = chisqouttest(x,variance,opposite)
## 
## Arguments:
## 
##        x: a numeric vector of data values. 
## 
## variance: known variance of population. if not given, estimator from
##           sample is taken, but there is not so much sense in such test
##           (it is similar to z-scores) 
## 
## opposite: a logical indicating whether you want to check not the value
##           with  largest difference from the mean, but opposite (lowest,
##           if most suspicious is highest etc.)
## 
## Details:
## 
##      This function performs a simple test for one outlier, based on
##      chisquared distribution of squared differences between data and
##      sample mean. It assumes known variance of population.  It is
##      rather not recommended today for routine use, because several more
##      powerful  tests are implemented (see other functions mentioned
##      below).  It was discussed by Dixon (1950) for the first time, as
##      one of the tests taken into account by him.
## 
## Value:
## 
## chisq: the value of chisquared-statistic.
## 
##  pval: the p-value for the test.
## 
## Note:
## 
##      This test is known to reject only extreme outliers, if no known
##      variance is specified.
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
## 

function [pval,chisq] = chisqouttest(x,variance,opposite)

	if nargin<3
		opposite=0;
	end
	if nargin<2
		variance=var(x);
	end

	chisq=(outlier(x,opposite)-mean(x)).^2./variance;
	pval=1-chi2cdf(chisq,1);

end
