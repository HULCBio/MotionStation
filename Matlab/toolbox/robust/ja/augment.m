% AUGMENT は、(状態空間型の)W1, W2, W3 を拡大して、2ポートプラントを作成
% します。
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGMENT(SYSG,SYSW1,SYSW2,SYSW3,DIM) 
% は、つぎのような重み付けをした拡大プラントの状態空間モデルを計算します。
%
%       W1 = sysw1:=[aw1 bw1;cw1 dw1] ---- 誤差信号'e'に対する重み
%       W2 = sysw2:=[aw2 bw2;cw2 dw2] ---- 制御信号'u'に対する重み
%       W3 = sysw3:=[aw3 bw3;cw3 dw3] ---- 出力信号'y'に対する重み
%
% (上の重みを、sysw1, sysw2, sysw3 を次元のない状態空間型[]と設定するこ
% とで、適用しないようにできます)
%
%       dim = [xg xw1 xw2 xw3]
% ここで、xg  : G(s) の状態の数
%                  xw1 : W1(s) の状態の数 (sysw1 = [] の場合、ゼロ)
%                  xw2 : W2(s) .... 等の状態数
%
% 拡大されたシステムは、P(s):= (a,b1,b2,c1,c2,d11,d12,d21,d22) となります。

% Copyright 1988-2002 The MathWorks, Inc. 
