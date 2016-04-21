function [a1cmp] = ortr(a1)
%ORTR Orthogonal complement of row matrix.
%
% [A1CMP] = ORTR(A1) produces an orthogonal complement of a
%       row type matrix via the duality of ORTC.
%

% R. Y. Chiang & M. G. Safonov 7/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%
[app] = ortc(a1');
a1cmp = app';
%
% ----- End of ORTR.M ---- RYC/MGS 7/85 %