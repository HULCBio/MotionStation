% FEEDBK は、閉ループの状態空間実現を行います。
%
% [SS_] = FEEDBK(SS_1,FBTYPE,SS_2)、または、
% [A,B,C,D] = FEEDBK(A1,B1,C1,D1,FBTYPE,A2,B2,C2,D2) は、5つの一般的なタ
% イプの負のフィードバックの状態空間閉ループ伝達関数を計算します。
%
% fbtype = 1 ---- 前進ループ, I; フィードバックループ, (A1,B1,C1,D1).
% fbtype = 2 ---- 前進ループ, (A1,B1,C1,D1); フィードバックループ, I.
% fbtype = 3 ---- 前進ループ, (A1,B1,C1,D1); フィードバックループ, 
%                 (A2,B2,C2,D2).
% fbtype = 4 ---- 状態フィードバック: A2 <-- F.
% fbtype = 5 ---- 出力: A2 <-- H.
%

% Copyright 1988-2002 The MathWorks, Inc. 
