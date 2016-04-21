function code = bchenco(msg, n, k, pg);
%BCHENCO
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use BCHENC instead.

%   CODE = BCHENCO(MSG, N, K) encodes the K-column message MSG to N-column
%   codeword CODE by using BCH code method.
%
%   CODE = BCHENCO(MSG, N, K, PG) specifies the generator polynomial PG for the
%   BCH code.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

% routine check
if nargin < 3
    error('Not enough input variables');
end;
[n_msg, m_msg] = size(msg);
if m_msg ~= k
    error('The input dimension does not match the message length.')
end;

% code calculation.
if nargin < 4
    pg = bchpoly(n, k);
end;
[h, gen] = cyclgen(n, pg);
code = rem(msg * gen, 2);
%----- end of bchenco -----
