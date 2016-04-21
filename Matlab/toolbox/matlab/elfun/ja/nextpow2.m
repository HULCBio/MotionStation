% NEXTPOW2   指定した値以上の最小の2のベキ乗数
% 
% NEXTPOW2(N)は、2^P > =  abs(N)を満足する最小のPを出力します。この関数
% は、FFT演算で最も近い2のベキ乗数を見つける場合に役立ちます。Xがベクト
% ルの場合、NEXTPOW2(X)は、NEXTPOW2(LENGTH(X))になります。
%
% 参考：LOG2, POW2.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:50:33 $
