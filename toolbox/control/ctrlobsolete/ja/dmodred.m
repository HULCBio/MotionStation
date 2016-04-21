% DMODRED   離散時間モデルの状態の低次元化
%
% [Ab,Bb,Cb,Db] = DMODRED(A,B,C,D,ELIM) は、ベクトル ELIM で設定される
% 状態を削除することにより、モデルの次数を低減します。状態ベクトルは、
% 保持されるものを X1 に、削除するものを X2 と分割します。
%
%    A = |A11  A12|      B = |B1|    C = |C1 C2|
%        |A21  A22|          |B2|
%    
%    x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n]
%
% X2[n+1] は、X2[n] に設定され、結果の方程式を X1 について解きます。
% 結果のシステムは、より少ない状態数 LENGTH(ELIM) になり、ELIM 個の
% 状態量は、非常に高い周波数をもつものと考えることができます。
%
% 参考 : DBALREAL, BALREAL, MODRED


%   J.N. Little 9-4-86
%   Revised 8-26-87 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:50 $
