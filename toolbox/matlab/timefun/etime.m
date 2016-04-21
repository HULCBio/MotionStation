function t = etime(t1,t0)
%ETIME  Elapsed time.
%   ETIME(T1,T0) returns the time in seconds that has elapsed between
%   vectors T1 and T0.  The two vectors must be six elements long, in
%   the format returned by CLOCK:
%
%       T = [Year Month Day Hour Minute Second]
%
%   Time differences over many orders of magnitude are computed accurately.
%   The result can be thousands of seconds if T1 and T0 differ in their
%   first five components, or small fractions of seconds if the first five
%   components are equal.
%
%     t0 = clock;
%     operation
%     etime(clock,t0)
%
%   See also TIC, TOC, CLOCK, CPUTIME, DATENUM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2002/09/30 12:01:19 $

% Compute time difference accurately to preserve fractions of seconds.

t = 86400*(datenummx(t1(:,1:3)) - datenummx(t0(:,1:3))) + ...
    (t1(:,4:6) - t0(:,4:6))*[3600; 60; 1];
