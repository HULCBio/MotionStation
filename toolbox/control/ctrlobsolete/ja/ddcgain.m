% DDCGAIN   離散システムの D.C. ゲイン
%
% K = DDCGAIN(A,B,C,D) は、離散状態空間システム(A, B, C, D) の定常状態
% ゲイン(D.C. または低周波数)を計算します。
%
% K = DDCGAIN(NUM,DEN) は、離散多項式伝達関数システム G(z) = NUM(z)/DEN(z) 
% の定常状態ゲインを計算します。ここで、NUM と DEN は、z の降ベキ順の多項式
% の係数を含んでいます。
%
% 参考 : DCGAIN.


%	Clay M. Thompson  7-6-90
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:38 $
