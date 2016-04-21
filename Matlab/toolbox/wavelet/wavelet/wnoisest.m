function stdc = wnoisest(c,varargin)
%WNOISEST Estimate noise of 1-D wavelet coefficients.
%   STDC = WNOISEST(C,L,S) returns estimates of the detail
%   coefficients' standard deviation for levels contained
%   in the input vector S.
%   [C,L] is the input wavelet decomposition structure
%   (see WAVEDEC for more information).
%
%   If C is a one dimensional cell array, STDC = WNOISEST(C)
%   returns a vector such that STDC(k) is an estimate of the
%   standard deviation of c{k}.
%
%   If C is a numeric array, STDC = WNOISEST(C)
%   returns a vector such that STDC(k) is an estimate of the
%   standard deviation of c(k,:).
%  
%   The estimator used is Median Absolute Deviation / 0.6745,
%   well suited for zero mean Gaussian white noise in the 
%   de-noising 1-D model (see THSELECT for more information).
%
%   See also THSELECT, WAVEDEC, WDEN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 1
  error('Not enough input arguments.');
elseif nbIn > 3
  error('Too many input arguments.');
end

if length(varargin)==0
    if iscell(c)
        nblev = length(c);
    elseif isnumeric(c)
        if size(c,1)>1
            c = num2cell(c,2);
        else
            c = num2cell(c(:)',2);
        end
        nblev = size(c,1);
    else
        error(['Invalid argument value for: ' inputname(c)]);
    end
else
    c = detcoef(c,varargin{:},'cells');
    nblev = length(c);
end
stdc = zeros(1,nblev);
for k = 1:nblev
    stdc(k) = median(abs(c{k}))/0.6745;
end
