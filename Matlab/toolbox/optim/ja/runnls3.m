% RUNNLS3   LSQNONLIN に対する 'JacobMult' オプションのデモンストレーション
%
% この例題は、F(x) = 0 形式の構造化された非線形方程式問題の解法を示します。
% ここで F=G(y) で、y はスパースなSPD(対称正定システム Ay=G(x) を解くことで
% 求まります。
% F(x) は3重対角Jacobian行列をもちます。
% Jacobian行列の要素は計算されますが、厳密なJacobianは形成されません。


%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/05/01 13:00:17 $
