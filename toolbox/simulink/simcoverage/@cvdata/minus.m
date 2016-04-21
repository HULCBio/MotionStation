function r = minus(p,q),
%CVDATA/MINUS  Implement P-Q, data difference.
%
%  When a test metric exists in only one of the arguments it will be copied 
%  from that argument into the result. When the same metric exists in both 
%  arguments the following union rules apply:
%
%  DECISION Find the coverage points only exercised in data P.  The path counts
%  are set to 0 if the path was not taken in P or if it was taken any number of 
%  times in Q.  The path counts are set to the P count if the P count is 
%  greater than 0 and the Q count is equal to zero.
%
%  CONDITION The condition evaluation counts are the sum of the counts in P and 
%  Q and the aggregate counts are the aggregate of the sum.
%
%  RELATION The equality counts are the sum of the counts in P and Q and the 
%  aggregate counts are the aggregate of the sum.  The min positive difference  
%  is the minimum from P and Q, and the max negative difference is the max from 
%  P and Q.

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/03/23 03:02:31 $

p = cvdata(p);
q = cvdata(q);

% Perform consistency checking
ref.type = '.';
ref.subs = 'checksum';

if ~isequal(subsref(p,ref),subsref(q,ref))
    error('Checksums must match for data union calculation');
end

out_metrics = perform_operation(p,q,'u = (lhs>0 & rhs==0).*lhs;','-');

% Form the output object
r = cvdata(p,q,out_metrics);

