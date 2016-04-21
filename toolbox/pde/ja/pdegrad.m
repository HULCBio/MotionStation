% PDEGRAD   PDE 問題の解の勾配を計算します。
% [UX,UY] = PDEGRAD(P,T,U) は、各三角形の中心で解釈された grad(U) を出力
% します。
% 
% PDE 問題の形状は、三角形データ P と T によって与えられます。詳細は、
% INITMESH を参照してください。
%
% 解ベクトル U のフォーマットは、ASSEMPDE に記述されています。
%
% [UX,UY] = PDEGRAD(P,T,U,SDL) は、計算をリスト SDL にあるサブドメインに
% 制限します。
% 
% 参考   ASSEMPDE, INITMESH, PDECGRAD



%       Copyright 1994-2001 The MathWorks, Inc.
