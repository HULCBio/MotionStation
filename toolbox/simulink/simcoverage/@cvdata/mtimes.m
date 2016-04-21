function r = mtimes(p,q),
% CVDATA/PLUS   Implement P*Q, data intersection.
%
% When a test metric exists in only one of
% the arguments, the inteintersection will be empty
%
% DECISION The path counts are the minimum of the
% count in P and the count in Q and the agregate counts 
% are calculated from the minimum
%
% CONDITION The condition evaluation counts are 
% the sum of the counts in P and Q and the agregate
% counts are the agregate of the sum.
%
% RELATION The equality counts are the sum of the 
% counts in P and Q and the agregate counts are the 
% agregate of the sum.  The min positive difference 
% is the minimum from P and Q, and the max negative
% difference is the max from P and Q.

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/23 03:02:28 $

r = times(p,q);   