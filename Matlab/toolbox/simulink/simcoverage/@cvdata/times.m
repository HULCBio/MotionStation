function r = times(p,q),
%CVDATA/TIMES  Implement P*Q, data intersection.
%
%  When a test metric exists in only one of the arguments, the intersection
%  will be empty.  Otherwise, the following rules apply:
%
%  DECISION The path counts are the minimum of the count in P and the count in 
%  Q and the aggregate counts are calculated from the minimum
%
%  CONDITION The condition evaluation counts are the sum of the counts in P and 
%  Q and the aggregate counts are the agregate of the sum.
%
%  RELATION The equality counts are the sum of the counts in P and Q and the 
%  aggregate counts are the aggregate of the sum.  The min positive difference is 
%  the minimum from P and Q, and the max negative difference is the max from P 
%  and Q.

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/03/23 03:02:16 $

p = cvdata(p);
q = cvdata(q);

% Perform consistency checking
ref.type = '.';
ref.subs = 'checksum';

if ~isequal(subsref(p,ref),subsref(q,ref))
    error('Checksums must match for data union calculation');
end

out_metrics = perform_operation(p,q,'u = min([lhs'';rhs''])'';','*');

% Form the output object
r = cvdata(p,q,out_metrics);

