% BALREAL   状態空間実現のグラミアンに基づく平衡化
%
% SYSb = BALREAL(SYS) は、可到達、可観測で安定なシステム SYS の平衡化
% 状態空間実現を出力します。
%
% [SYSb,G,T,Ti] = BALREAL(SYS) は、平衡化実現のグラミアンの対角部を含む
% ベクトル G を出力します。行列Tは、xb = Tx によって、SYS を SYSb に状態
% 変換するために使います。Ti は、その逆行列です。
% 
% 平衡化されるグラミアン G の中の小さな要素は、モデルを低次元化するとき
% に、取り除くことができる状態量です。BALREALは、数値的に保証するために、
% 前処理として SSBAL を使って、平衡化を行います。
%      
% 参考 : MODRED, GRAM, SSBAL, SS


%	J.N. Little 3-6-86
%	Revised 12-30-88
%       Alan J. Laub 10-30-94
%	Copyright 1986-2002 The MathWorks, Inc. 
