function [aa] = unstkc(a,m,n)
%UNSTKC Unstack a long column vector (columnwise).
%
% [AA] = UNSTKC(A,M,N) unstacks a long column vector into m by n matrix
%        column by column.

% R. Y. Chiang & M. G. Safonov 5/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

aa = ones(m,n);
aa(:) = a;
%
% ------- End of UNSTKC.M ---- RYC/MGS 5/85 %