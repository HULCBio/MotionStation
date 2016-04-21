function [a1cmp] = ortc(a1)
%ORTC Orthogonal complement of column matrix.
%
% [A1CMP] = ORTC(A1) produces an orthogonal complement of a column
%         type matrix via QR decomposition.
%

% R. Y. Chiang & M. G. Safonov 7/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%
[ra1,ca1] = size(a1);
if ra1 == ca1
     a1cmp = zeros(ra1);
else
     [u,r] = qr(a1);
     a1cmp = u(:,ca1+1:ra1);
end
%
% ----- End of ORTC.M ---- RYC/MGS 7/85 %