% DELAY2Z   z = 0 での極、または、周波数応答データ(FRD)の位相シフトに
%           よる遅れの置き換え
%
% 離散時間の TF, ZPK またはSSモデル SYS に対して、
% 
%   SYS = DELAY2Z(SYS) 
% 
% は、すべての時間遅れを Z = 0 の極へマッピングします。つまり、kサンプル分
% の遅れは、(1/z)^k で置き換えられます。
% 
% FRD モデルに対して、DELAY2Z は、すべての時間遅れを周波数応答データに
% 吸収させます。連続時間、離散時間 FRD のどちらに対しても適用できます。
%
% 参考 : HASDELAY, PADE, LTIMODELS.


%	 P. Gahinet 8-28-96
%	 Copyright 1986-2002 The MathWorks, Inc. 
