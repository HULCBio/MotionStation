function [f,x,fbounds] = getcdfdata(ds)
%GETCDFDATA Get x and y values for plotting cdf of data set.

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:30 $
%   Copyright 2003-2004 The MathWorks, Inc.

if isempty(ds.cdfx) || isempty(ds.cdfy) || ...
       (nargout>=3 && (isempty(ds.cdfLower) || isempty(ds.cdfUpper)))
   % Compute cdf results if not already available
   alpha = 1 - ds.conflev;
   [f,x,flo,fup] = ecdf(ds.y, 'cens',ds.censored, 'freq',ds.frequency, ...
                        'alpha', alpha);
   ds.cdfy = f;
   ds.cdfx = x;
   ds.cdfLower = flo;
   ds.cdfUpper = fup;
else
   % Retrieve stored results
   f = ds.cdfy;
   x = ds.cdfx;
end

% Assemble bounds into two-column matrix for output
fbounds = [ds.cdfLower ds.cdfUpper];