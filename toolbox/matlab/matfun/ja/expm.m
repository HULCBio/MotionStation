% EXPM    行列の指数
% 
% EXPM(X) は、行列 X の指数を計算します。EXPMは、スケーリングと2乗アルゴリ
% ズムを使い、Pade 近似によって計算されます。
%
% この方法で計算しなくても、X が固有ベクトル V と対応する固有値Dのフルセッ
% トの場合は、[V,D] = EIG(X) かつ EXPM(X) = V*diag(exp(diag(D)))/V で求ま
% ります。
%
% EXP(X) は、要素毎の計算を行います。
%
% 参考：LOGM, SQRTM, FUNM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:47 $
%   Built-in function.
