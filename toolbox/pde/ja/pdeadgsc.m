% PDEADGSC   相対許容規範を使って、三角形を選択します。
%
% BT = PDEADGSC(P,T,C,A,F,U,ERRF,TOL) は、BT で細分化されるべき三角形の
% インデックスを出力します。
%
% PDE 問題の形状は、三角形データ P, T によって与えられます、詳細は、IN-
% ITMESH を参照してください。
%
% C, A, F は、PDE 係数です。詳細は、ASSEMPDE を参照してください。
%
% U は、列ベクトルで与えられたカレントの解です。詳細は、ASSEMPDE を参照
% してください。
%
% ERRF は、PDEJMPS で計算される誤差インジケータです。
%
% TOL は、誤差の許容範囲パラメータです。
%
% 三角形は、SCALE が以下のように計算されるところで、判定基準 ERRF>TOL*
% SCALE を使って選択されます。
% CMAX を C の最大値とします。
% AMAX を A の最大値とします。
% FMAX を F の最大値とします。
% UMAX を U の最大値とします。
% 形状を含む最も小さい正方形の辺をLとします。
%
% SCALE = MAX(FMAX*L^2,AMAX*UMAX*L^2,CMAX*UMAX) とします。このスケーリン
% グは、方程式のスケーリングと形状とは独立にパラメータ TOL を作ります。
% 
% 参考   ADAPTMESH, PDEJMPS



%       Copyright 1994-2001 The MathWorks, Inc.
