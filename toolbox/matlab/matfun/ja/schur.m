% SCHUR   Schur分解
% 
% [U,T] = SCHUR(X) は、X = U*T*U' かつ U'*U = EYE(SIZE(U)) であるような、
% Schur行列 T とユニタリ行列 U を出力します。X は正方でなければなりません。
%
% T = SCHUR(X) は、Schur行列 T のみを出力します。
%
% X が複素数行列の場合は、行列 T に複素Schur型を出力します。複素Schur型は、
% 対角要素に X の固有値をもつ上三角行列です。
%
% X が実数の場合は、2つの異なる分解が可能です。
% SCHUR(X,'real') は、実固有値は対角要素上に、複素固有値は2行2列のブロッ
% クで、対角線上に配置されます。
% SCHUR(X,'complex') は、X が複素固有値の場合、三角行列で複素数になります。
% SCHUR(X,'real') が、デフォルトです。
%
% 実Schur型から複素Schur型への変換については、RSF2CSF を参照してください。
%
% 参考 ORDSCHUR, QZ.

%   Copyright 1984-2002 The MathWorks, Inc. 

