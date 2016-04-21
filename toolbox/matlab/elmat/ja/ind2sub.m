% IND2SUB   線形インデックスから複数サブスクリプトへの変換
% 
% IND2SUBは、配列内に設定した各インデックスに対応する等価なサブスクリプ
% トの値を出力します。
%
% [I,J] = IND2SUB(SIZ,IND)は、サイズがSIZの行列に対するインデックス行列
% INDに対応する等価な行と列のサブスクリプト値を含む配列IとJを出力します。
% 行列に対して、[I,J] = IND2SUB(SIZE(A),FIND(A>5))は、[I,J] = FIND(A>5)
% と同じ値を出力します。
%
% [I1,I2,I3,...,In] = IND2SUB(SIZ,IND)は、サイズがSIZの配列に対するINDと
% 等価なN次元配列のサブスクリプト値を含む、N個のサブスクリプトの配列I1、
% I2,..、Inを出力します。
%
% 参考：SUB2IND, FIND.


%   Copyright 1984-2003 The MathWorks, Inc. 
