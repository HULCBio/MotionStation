% PDECGRAD   PDE の解のフラックス c*grad(u) の計算
%
% [CGXU,CGYU] = PDECGRAD(P,T,C,U) は、各三角形の中点で解釈されたフラック
% ス c*grad(u) を出力します。
%
% PDE 問題の形状は、三角形データ P と T によって与えられます。詳細は、
% INITMESH を参照してください。
%
% PDE 問題の係数 C は、多種多様な方法で与えることができます。詳細は、
% ASSEMPDE を参照してください。
%
% 解ベクトル U のフォーマットは、ASSEMPDE に記述されています。
%
% 係数 C が時間に依存する場合は、[CGXU,CGYU] = PDECGRAD(P,T,C,U,TIME) に
% なります。TIME は、時刻です。
%
% [CGXU,CGYU] = PDECGRAD(P,T,C,U,TIME,SDL) は、リスト SLD にあるサブドメ
% インに計算を制限します。
%
% 参考   ASSEMPDE, INITMESH, PDEGRAD



%       Copyright 1994-2001 The MathWorks, Inc.
