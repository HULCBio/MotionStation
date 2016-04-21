function aa = unstkr(a,m,n)
%UNSTKR Unstack a long column vector (rowwise).
%
% [AA] = UNSTKR(A,M,N) unstacks a long column vector into m by n matrix
%        row by row.

% R. Y. Chiang & M. G. Safonov 5/85
% Revised 8-12-88 JNL
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

aa = zeros(n,m);
aa(:) = a;
aa = aa';
%
% ----- End of UNSTKR.M --- RYC/MGS %