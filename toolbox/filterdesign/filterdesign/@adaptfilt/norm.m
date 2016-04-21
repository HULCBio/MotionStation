function s = norm(Hd,pnorm)
%NORM   Filter norm.
%   NORM(Ha) returns the 2-norm of an adaptive filter (ADAPTFILT) Ha.  
%
%   NORM(Ha,PNORM) returns the p-norm of a filter. PNORM can be either
%   frequency-domain norms: 'L1', 'L2', 'Linf' or discrete-time-domain
%   norms: 'l1', 'l2', 'linf'. Note that the L2-norm of a filter is equal
%   to its l2-norm (Parseval's theorem), but this is not true for other
%   norms.
%
%       EXAMPLE:
%       % Compute the two norm of an LMS filter
%       Ha = adaptfilt.lms; % norm(Ha) is zero because all coeffs are zero
%       % Create some data to filter with
%       x = randn(100,1); d = x + randn(100,1);
%       [y,e] = filter(Ha,x,d);
%       L2 = norm(Ha); % Now norm(Ha) is nonzero
%
%   See also DFILT/NORM, MFILT/NORM.

%   Author(s): R. Losada
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:15:47 $

