% GDARE  離散時間の代数Riccati方程式に対する一般化されたソルバ
%
%
% [X,L,REPORT] = GDARE(H,J,NS) は、つぎの形のSymplectic pencil に関連する
% 離散時間代数Riccati方程式のユニークで対称な安定化解 X を求めます。
%
%                     [  A   F   B  ]       [ E   0   0 ]
%         H - t J  =  [ -Q   E' -S  ]  - t  [ 0   A'  0 ]
%                     [  S'  0   R  ]       [ 0  -B'  0 ]
%
% 3番目の入力 NS は、行列 A の行のサイズです。
%
% オプションで、GDARE は、閉ループ固有値のベクトル L と、つぎの値をもつ診断
% REPORT を出力します。 
%    * Symplectic pencil が虚軸に単位円上に固有値をもつ場合、-1
%    * 有限の安定化解 X が存在しない場合、-2 
%    * 有限な安定化解 X が存在する場合、0 
% この構文は、X が存在しない場合、エラーメッセージを出力しません。
%
% [X1,X2,D,L] = GDARE(H,J,NS,'factor') は、2つの行列 X1, X2 と、
% X = D*(X2/X1)*D であるような対角のスケーリング行列Dを返します。ベクトル L は、
% 閉ループ固有値を含みます。Symplectic pencil が、単位円上に固有値をもつ場合、
% すべての出力は空です。
%
% [...] = GDARE(H,...,'nobalance') では、データのオートスケーリング機能を
% 無効にします。
%
% 参考 : DARE, GCARE.


% Copyright 1986-2002 The MathWorks, Inc.
