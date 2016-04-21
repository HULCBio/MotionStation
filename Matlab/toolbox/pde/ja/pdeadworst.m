% PDEADWORST   精度の悪さに関係のある三角形要素を選択します。
%
% BT = PDEADWORST(P,T,C,A,F,U,ERRF,WLEVEL) は、BT に細分化する三角形のイ
% ンデックスを出力します。
%
% PDE 問題の形状は、三角形データ P, T によって与えられます。詳細は、IN-
% ITMESH を参照してください。
%
% C, A, F は、PDE 係数です。詳細は、ASSEMPDE を参照してください。
%
% U は、列ベクトルで与えられたカレントの解です。詳細は、ASSEMPDE を参照
% してください。
% 
% ERRF は、PDEJMPS で計算される誤差インジケータです。
%
% WLEVEL は、最も悪い誤差に対する誤差水準です。WLEVEL は、0と1の間でなけ
% ればなりません。
%
% 三角形は、判定基準 ERRF>WLEVEL*MAX(ERRF) を使って選択されます。
%
% 参考   ADAPTMESH, PDEJMPS



%       Copyright 1994-2001 The MathWorks, Inc.
