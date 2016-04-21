% DARE   離散時間代数Riccati 方程式を解きます
%
%
% [X,L,G,RR] = DARE(A,B,Q,R,S,E) は、離散時間代数Riccati 方程式のユニークで対
% 称な安定化解 X を求めます。
%                                         -1 
%      E'XE = A'XA - (A'XB + S)(B'XB + R)  (A'XB + S)' + Q 
%
% または、(R が、正則の場合)
%                                   -1             -1                 -1
%      E'XE = F'XF - F'XB(B'XB + R)  B'XF + Q - SR  S'  with  F:=A-BR  S'
%
% R, S, E は、省略されると、デフォルト値 R = I, S = 0, E = I が設定されます。
% 解 X の他に、 CARE は、ゲイン行列 
%                         -1
%           G = (B'XB + R)  (B'XA + S'),
% と閉ループの固有値ベクトル L　(すなわち、EIG(A-B*G,E)) も出力します。
%
% [X,L,G,REPORT] = DARE(...) は、つぎの値をもつ診断 REPORT を出力します。
%   * 行列が虚軸に非常に近い固有値をもつ場合、-1 
%   * 有界な安定化解 X が存在しない場合、-2 
%   *  X が存在して有界な場合、相対残差のFrobenius ノルム。
% この構文は、 X が存在しない場合、エラーメッセージを表示しません。
%
% [X1,X2,D,L] = DARE(A,B,Q,...,'factor') は、2つの行列 X1, X2 と、
% X = D*(X2/X1)*D であるような対角のスケーリング行列Dを返します。
% ベクトル L は、閉ループ固有値を含みます。関連する Hamiltonian 行列が、
% 虚軸上に固有値をもつ場合、すべての出力は空です。
%
% 参考 : CARE.


% Copyright 1986-2002 The MathWorks, Inc.
