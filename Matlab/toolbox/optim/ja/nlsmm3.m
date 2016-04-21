% NLSMM3   構造化された行列の乗算 (snlsf3)
%
% Jacobian行列の要素 Jac は、配列 A にストアされます。
%
% つぎのように計算します。
%         VV = Jac'*Jac*UU (flag  = 0)
%         VV = Jac*UU      (flag > 0) .
%         VV = Jac'*UU     (flag < 0)
%
% S は使用されません。
%
%**********************************************************************


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:02:23 $
