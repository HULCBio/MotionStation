function s = norm(Hd,pnorm)
%NORM   Filter norm.
%   NORM(Hm) returns the L2-norm of a multirate filter (MFILT) Hm.  
%
%   NORM(Hm,PNORM) returns the p-norm of a filter. PNORM can be either
%   frequency-domain norms: 'L1', 'L2', 'Linf' or discrete-time-domain
%   norms: 'l1', 'l2', 'linf'. Note that the L2-norm of a filter is equal
%   to its l2-norm (Parseval's theorem), but this is not true for other
%   norms.
%
%   When computing the l1-, l2-, linf-, L1-, and L2-norms of an IIR filter,
%   NORM(...,TOL) will specify the tolerance for greater or less accuracy.
%   By default, TOL = 1e-8.
%
%       EXAMPLE: Compute the infinity norm of a FIR interpolator
%       Hm = mfilt.firinterp;
%       Linf = norm(Hm,'Linf'); 
%
%   See also DFILT/NORM, ADAPTFILT/NORM.

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:24:56 $

