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
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## Calculate scores of the sample
## 
## Description:
## 
##      This function calculates normal, t, chi-squared, IQR and MAD
##      scores of given data.
## 
## Usage:
## 
##      [res]=scores(x,type,prob,lim) 
## 
## Arguments:
## 
##        x: a vector or matrix of data. Matrices are treated columnwise
##           (each column as independent dataset).
## 
##     type: "0" calculates normal scores (differences between each value
##           and the mean divided by sd, DEFAULT), "1" calculates t-Student scores
##           (transformed by '(z*sqrt(n-2))/sqrt(z-1-t^2)' formula,
##           "2" gives chi-squared scores (squares of differences
##           between values and mean divided by variance. For the "3"
##           type, all values lower than first and greater than third
##           quartile is considered, and difference between them and
##           nearest quartile divided by IQR are calculated. For the
##           values between these quartiles, scores are always equal to
##           zero. "4" gives MAD scores - differences between each value and median,
##           divided by median absolute deviation.
## 
##     prob: If set (default is NA), the corresponding p-values instead of scores are
##           given. If value is set to 1, p-values are returned. Otherwise,
##           a logical vector is formed, indicating which values are
##           exceeding specified probability. In "z" and "mad" types,
##           there is also possibility to set this value to zero, and then
##           scores are confirmed to (n-1)/sqrt(n) value, according to 
##           Shiffler (1998). The "3" (IQR) type does not support
##           probabilities, but "lim" value can be specified.
## 
##      lim: This value can be set for "3" (IQR) type of scores, to form
##           logical vector, which values has this limit exceeded. 
## 
## Value:
## 
##      A vector of scores, probabilities, or logical vector.
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## References:
## 
##      Schiffler, R.E (1998). Maximum Z scores and outliers. Am. Stat.
##      42, 1, 79-80.
## 

function [res]=scores(x,type,prob,lim) 

	if nargin<4
		lim=NA;
	end
	if nargin<3
		prob=NA;
	end
	if nargin<2
		type=0;
	end

if ~isvector(x) & ismatrix(x)
	res = [];
	for i=1:columns(x)
		rr = scores(x(:,i),type,prob,lim);
		res = [res rr];
	end
elseif isvector(x)
	n = length(x);
        if (type == 0) 
            res = (x - mean(x))/std(x);
            if ~isna(prob) 
                if (prob == 1) 
                  res = stdnormal_cdf(res);
                elseif (prob == 0) 
                  res = (abs(res) > (n - 1)/sqrt(n));
                else 
		  res =	(abs(res) > stdnormal_inv(prob));
		end
	    end

        elseif (type == 1) 
            t = (x - mean(x))/std(x);
            res = (t * sqrt(n - 2))./sqrt(n - 1 - t.^2);
            if ~isna(prob)
                if (prob == 1) 
                  res = tcdf(res, n - 2);
                elseif (prob == 0) 
                  res = (abs(res) > (n - 1)/sqrt(n));
                else 
		  res = (abs(res) > tinv(prob, n - 2));
		end
	    end

        elseif (type == 2) 
            res = (x - mean(x)).^2./var(x);
	    if ~isna(prob)
        	if (prob == 1) 
                  res = chi2cdf(res, 1);
                else 
		  res = (abs(res) > chi2inv(prob, 1));
		end
	     end
        elseif (type == 3) 
            res = x; st = statistics(x);
            Q1 = st(2); Q3 = st(4);
            res(x > Q1 & res < Q3) = 0;
            res(x < Q1) = (res(x < Q1) - Q1)/iqr(x);
            res(x > Q3) <- (res(x > Q3) - Q3)/iqr(x);
            if ~isna(lim)
            	res = (abs(res) > lim);
	    end
        elseif (type == 4) 
            res = (x - median(x))/(mad(x)*1.4826);
            if ~isna(prob)
                if (prob == 1) 
                  res = stdnorm_cdf(res)
                else if (prob == 0) 
                  res = (abs(res) > (n - 1)/sqrt(n));
                else 
		  res = abs(res) > qnorm(prob);
		end
	    end
	end
else
	error("x must be a vector or a matrix");
end

end

