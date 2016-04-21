% CSCHUR   順序付けられた複素Schur分解
%
% [V,T,M,SWAP] = CSCHUR(A,ODTYPE)は、複素Schur分解を計算します。
%
%              V' * A * V  = T = |T1  T12|
%                                | 0   T2|,
%
%              m    = 安定な極の数(sまたはz平面)
%              swap = スワップ回転数
%
% "schur"で出力された順序付けされていないSchur型は、隣接する対角項をスワ
% ップするために、複素Givens回転を使って順序付けられます。
%
% 6種類の順番が選択できます。
%
%         odtype = 1 --- Re(eig(T1)) < 0, Re(eig(T2)) > 0
%         odtype = 2 --- Re(eig(T1)) > 0, Re(eig(T2)) < 0
%         odtype = 3 --- 固有値の実数部が小さい順
%         odtype = 4 --- 固有値の実数部が大きい順
%         odtype = 5 --- 固有値の絶対値が小さい順
%         odtype = 6 --- 固有値の絶対値が大きい順
%



% Copyright 1988-2002 The MathWorks, Inc. 
