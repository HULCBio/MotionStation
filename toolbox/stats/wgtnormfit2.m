function [paramEsts,paramCIs] = wgtnormfit2
%WGTNORMFIT2 Fitting demo for a weighted normal distribution (log(sigma) parameterization).
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/22 23:55:38 $
x = [0.25 -1.24 1.38 1.39 -1.43 2.79 3.52 0.92 1.44 1.26];
m = [   8     2    1    3     8    4    2    5    2    4];

    function logy = logpdf_wn2(x,mu,logsigma)
        v = exp(logsigma).^2 ./ m;
        logy = -(x-mu).^2 ./ (2.*v) - .5.*log(2.*pi.*v);
    end

[paramEsts,paramCIs] = mle(x, 'logpdf',@logpdf_wn2, 'start',[mean(x),log(std(x))]);

end
