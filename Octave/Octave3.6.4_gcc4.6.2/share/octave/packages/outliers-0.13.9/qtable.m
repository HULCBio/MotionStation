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

## Interpolate tabularized distribution
## 
## Description:
## 
##      This function calculates critical values or p-values which cannot
##      be obtained numerically, and only tabularized version is
##      available. 
## 
## Usage:
## 
##      [q] = qtable(p,probs,quants)
## 
## Arguments:
## 
##        p: vector of probabilities. 
## 
##    probs: vector of given probabilities. 
## 
##   quants: vector of given corresponding quantiles. 
## 
## Details:
## 
##      This function is mainly internal routine used to obtain Grubbs and Dixon
##      critical values. It fits linear or cubical regression to closests
##      values of its argument, then uses obtained function to obtain
##      quantile by interpolation. But noone disables to call it directly in
##      any purpose :)
## 
## Value:
## 
##      q: A vector of interpolated values
## 
## Note:
## 
##      You can simply do "reverse" interpolation (p-value calculating) by
##      reversing probabilities and quantiles (2 and 3 argument).
## 
## Author(s):
## 
##      Lukasz Komsta, ported from R package "outliers".
##	See R News, 6(2):10-13, May 2006
## 
## 
## 

function [q] = qtable(p,probs,quants)

	[probs,o] = sort(probs);
	quants = quants(o);
	q = [];
	l = length(probs);

	for n=1:length(p)
		pp = p(n);
		if pp<=probs(1)
			q0 = quants([1 2]);
			p0 = probs([1 2]);
			fit = polyfit(p0,q0,1);
		elseif pp>=probs(l)
			q0 = quants([l-1 l]);
			p0 = probs([l-1 l]);
			fit = polyfit(p0,q0,1);
		else
			x0 = find(abs(pp-probs) == min(abs(pp-probs)));
			x1 = find(abs(pp-probs) == sort(abs(pp-probs))(2));
			x = min([x0 x1]);
			if x==1 
				x=2;
			elseif x>(l-2)
				x=l-2;
			end
			i = [x-1 x x+1 x+2];
			q0 = quants(i);
			p0 = probs(i);
			fit = polyfit(p0,q0,3);
		end
		q = [q polyval(fit,pp)];
	end
end



