function r = plus(p,q),
%CVDATA/PLUS   Implement P+Q, data union.
%
%  When a test metric exists in only one of the arguments it will be copied 
%  from that argument into the result. When the same metric exists in both 
%  arguments the following union rules apply:
%
%  DECISION The path counts are the sum of the counts in P and Q and the 
%  aggregate counts are the aggregate of the sum.
%
%  CONDITION The condition evaluation counts are the sum of the counts in P 
%  and Q and the aggregate counts are the aggregate of the sum.
%
%  RELATION The equality counts are the sum of the counts in P and Q and the 
%  aggregate counts are the aggregate of the sum.  The min positive difference 
%  is the minimum from P and Q, and the max negative  difference is the max 
%  from P and Q.

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/03/23 03:02:25 $

p = cvdata(p);
q = cvdata(q);

% Perform consistency checking
ref.type = '.';
ref.subs = 'checksum';

if ~isequal(subsref(p,ref),subsref(q,ref))
    error('Checksums must match for data union calculation');
end

out_metrics = perform_operation(p,q,'u=lhs+rhs;','+');

% Form the output object
r = cvdata(p,q,out_metrics);

