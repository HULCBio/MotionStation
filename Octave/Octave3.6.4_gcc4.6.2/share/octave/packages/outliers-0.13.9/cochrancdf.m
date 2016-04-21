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

## p-values for Cochran outlying variance test
##
## Description:
## 
##      This functions calculates p-values
##      for Cochran test for outlying variance.
## 
## Usage:
## 
##       [res] = cochrancdf(q,n,k)
## 
## Arguments:
## 
##        q: vector of quantiles. 
## 
##        n: number of values in each group (if not equal, use arithmetic
##           mean). 
## 
##        k: number of groups.
## 
## Value:
## 
##      Vector of p-values.
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


function [res] = cochrancdf(q,n,k)
    f = (1./q - 1)./(k - 1);
    res = 1 - fcdf(f, (n - 1) .* (k - 1), n - 1) .* k;
    res(res<0)=0;
    res(res>1)=1;
end
