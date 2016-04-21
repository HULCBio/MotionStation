% DELAY2Z   z=0 での極、または、周波数応答データ(FRD)の位相シフトによる
%           遅れの置き換え
%
% 離散時間のTF, ZPKまたはSSモデル SYS に対して、
% 
%   SYS = DELAY2Z(SYS) 
% 
% は、すべての時間遅れを Z = 0 の極へマッピングします。つまり、k サン
% プル分の遅れは、(1/z)^k で置き換えられます。
% 
% FRD モデルに対して、DELAY2Z は、すべての時間遅れを周波数応答データに
% 吸収させます。連続時間、離散時間FRDのどちらに対しても適用できます。
%
% 参考 : HASDELAY, PADE, LTIMODELS.


%	 P. Gahinet 8-28-96
%	 Copyright 1986-2002 The MathWorks, Inc. 
