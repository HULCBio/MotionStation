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

## Calculate critical values and p-values for Grubbs tests
## 
## Description:
## 
##      This function is designed to calculate critical values for Grubbs
##      tests for outliers detecting and to approximate p-values
##      reversively.
## 
## Usage:
## 
##      [q]=grubbsinv(p, n, type, rev) 
## 
## Arguments:
## 
##        p: vector of probabilities. 
## 
##        n: sample size. 
## 
##     type: Integer value indicating test variant. 10 is a test for one
##           outlier (side is detected automatically and can be reversed
##           by 'opposite' parameter). 11 is a test for two outliers on
##           opposite tails, 20 is test for two outliers in one tail. 
## 
##      rev: if set to TRUE, function 'grubbsinv' acts as 'grubbscdf' (grubbscdf
##           is really wrapper to grubbsinv to omit repetition of the code).
## 
## Details:
## 
##      The critical values for test for one outlier is calculated
##      according to approximations given by Pearson and Sekar (1936). The
##      formula is simply reversed to obtain p-value.
## 
##      The values for two outliers test (on opposite sides) are
##      calculated according to David, Hartley, and Pearson (1954). Their
##      formula cannot be rearranged to obtain p-value, thus such values
##      are obtained by simple bisection method.
## 
##      For test checking presence of two outliers at one tail, the
##      tabularized distribution (Grubbs, 1950) is used, and
##      approximations of p-values are interpolated using 'qtable'.
## 
## Value:
## 
##      A vector of quantiles or p-values.
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
##      Pearson, E.S., Sekar, C.C. (1936). The efficiency of statistical
##      tools and a criterion for the rejection of outlying observations.
##      Biometrika, 28, 3, 308-320.
## 
##      David, H.A, Hartley, H.O., Pearson, E.S. (1954). The distribution
##      of the ratio, in a single normal sample, of range to standard
##      deviation. Biometrika, 41, 3, 482-493.
## 
## 

function [q]=grubbsinv(p, n, type, rev) 

	if nargin<4
		rev=0;
	end
	if nargin<3
		type=10;
	end

	if (type == 10) 
        	if ~rev 
            		q = (((n - 1)/sqrt(n)) .* sqrt(t_inv((1 - p)/n, n - 2) ...
			.^2./(n - 2 + t_inv((1 - p)/n, n - 2)^2)));
        	else 
            		s = (p.^2 .* n .* (2 - n))./(p.^2 .* n - (n - 1).^2);
            		t = sqrt(s);
			t(s<0) = 0;
                	q = n * (1 - t_cdf(t, n - 2));
                	t(t>1) = 1;
            		q = 1 - q;
		end
	elseif (type == 11) 
        	if ~rev 
            		tt =  t_inv((1- p)./(n.*(n - 1)),n - 2).^2;
			q = sqrt((2 * (n - 1) .* tt)./(n-2+tt));
        	else 
            		q = p;
            		p =[];
            		for i=1:length(q) 
                		if (q(i) > grubbsinv(0.9999, n, 11)) 
                  			pp = 1;
		                elseif (q(i) < grubbsinv(2e-16, n, 11)) 
                  			pp = 0;
		                else 
                  			x1 = 0;
					x2 = 1;
					for t=1:12
						x3=(x1+x2)/2;
            						tt =  t_inv((1- x3)./(n.*(n - 1)),n - 2).^2;
							g = sqrt((2 * (n - 1) .* tt)./(n-2+tt));
						if g<q(i)
							x1=x3;
						else
							x2=x3;
						end
					end
					pp = x3;

				end
	                p = [p pp];
			q = p;
			end
		end

    	else
        if (n > 30) 
            error("n must be in range 3-30");
	end
        pp = [0.01, 0.025, 0.05, 0.1, 0.15, 0.2, 0.4, 0.6, ...
            0.8, 0.9, 0.95, 0.975, 0.99];
        gtwo = [NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
            NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ... 
            NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
            NA, NA, 1e-05, 2e-04, 8e-04, 0.0031, 0.007, 0.013, ...
            0.055, 0.138, 0.283, 0.399, 0.482, 0.54, 0.589, 0.0035, ...
            0.009, 0.0183, 0.0376, 0.058, 0.078, 0.169, 0.276, ...
            0.41, 0.502, 0.571, 0.63, 0.689, 0.0186, 0.0349, ...
            0.0565, 0.0921, 0.124, 0.153, 0.257, 0.361, 0.478, ...
            0.562, 0.626, 0.674, 0.724, 0.044, 0.0708, 0.102, ...
            0.1479, 0.186, 0.217, 0.325, 0.423, 0.53, 0.605, ...
            0.659, 0.701, 0.743, 0.075, 0.1101, 0.1478, 0.1994, ...
            0.238, 0.271, 0.376, 0.468, 0.568, 0.635, 0.684, ...
            0.722, 0.763, 0.1082, 0.1492, 0.1909, 0.2454, 0.285,... 
            0.319, 0.42, 0.507, 0.598, 0.658, 0.703, 0.738, 0.776, ...
            0.1415, 0.1865, 0.2305, 0.2863, 0.326, 0.358, 0.455, ...
            0.537, 0.622, 0.678, 0.721, 0.753, 0.787, 0.1736, ...
            0.2212, 0.2666, 0.3226, 0.363, 0.394, 0.487, 0.564, ...
            0.624, 0.695, 0.734, 0.765, 0.797, 0.2044, 0.2536, ...
            0.2996, 0.3552, 0.393, 0.424, 0.514, 0.585, 0.66, ...
            0.709, 0.745, 0.773, 0.802, 0.2333, 0.2836, 0.3295, ...
            0.3843, 0.421, 0.451, 0.537, 0.605, 0.676, 0.721, ...
            0.755, 0.782, 0.809, 0.2605, 0.3112, 0.3568, 0.4106, ...
            0.447, 0.477, 0.558, 0.622, 0.689, 0.733, 0.765, ...
            0.789, 0.817, 0.2859, 0.3367, 0.3818, 0.4345, 0.469, ... 
            0.497, 0.576, 0.639, 0.701, 0.742, 0.773, 0.797, ...
            0.822, 0.3098, 0.3603, 0.4048, 0.4562, 0.491, 0.518, ...
            0.593, 0.653, 0.713, 0.751, 0.78, 0.803, 0.826, 0.3321, ...
            0.3822, 0.4259, 0.4761, 0.511, 0.536, 0.609, 0.666, ...
            0.723, 0.76, 0.787, 0.808, 0.831, 0.353, 0.4025, ...
            0.4455, 0.4944, 0.526, 0.552, 0.622, 0.676, 0.732, ...
            0.767, 0.793, 0.814, 0.835, 0.3725, 0.4214, 0.4636, ...
            0.5113, 0.543, 0.567, 0.635, 0.688, 0.74, 0.774, ...
            0.799, 0.818, 0.838, 0.3909, 0.4391, 0.4804, 0.5269,... 
            0.559, 0.582, 0.647, 0.697, 0.748, 0.781, 0.805, ...
            0.823, 0.843, 0.408, 0.457, 0.496, 0.542, 0.571, ...
            0.594, 0.657, 0.706, 0.755, 0.786, 0.81, 0.828, 0.847, ...
            0.425, 0.474, 0.512, 0.556, 0.584, 0.606, 0.668, ...
            0.715, 0.762, 0.792, 0.815, 0.834, 0.85, 0.442, 0.486, ...
            0.524, 0.568, 0.596, 0.618, 0.677, 0.723, 0.769, ...
            0.797, 0.819, 0.836, 0.853, 0.453, 0.5, 0.538, 0.581, ...
            0.608, 0.628, 0.686, 0.73, 0.774, 0.802, 0.823, 0.84, ...
            0.857, 0.466, 0.511, 0.547, 0.589, 0.616, 0.637, ...
            0.693, 0.736, 0.779, 0.807, 0.827, 0.843, 0.86, 0.482, ...
            0.525, 0.561, 0.601, 0.627, 0.647, 0.701, 0.743, ...
            0.784, 0.811, 0.83, 0.845, 0.861, 0.492, 0.536, 0.572, ...
            0.611, 0.636, 0.655, 0.709, 0.749, 0.789, 0.815, ...
            0.834, 0.849, 0.864, 0.505, 0.548, 0.583, 0.621, ...
            0.646, 0.664, 0.716, 0.755, 0.794, 0.819, 0.837, ...
            0.851, 0.866, 0.516, 0.558, 0.592, 0.629, 0.654, ...
            0.672, 0.722, 0.76, 0.798, 0.822, 0.84, 0.854, 0.869, ...
            0.528, 0.568, 0.602, 0.638, 0.661, 0.679, 0.728, ...
            0.765, 0.802, 0.826, 0.842, 0.856, 0.87];
        gtwo = reshape(gtwo,13,30);
        if ~rev 
            q = qtable(p, pp, gtwo(:,n)');
        else 
		q = qtable(p, gtwo(:,n)', pp);
	end
	q(q<0)=0;
	q(q>1)=1;
	end
end



