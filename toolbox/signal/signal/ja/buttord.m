% BUTTORD Butterworthフィルタの次数推定
%
% [N, Wn] = BUTTORD(Wp, Ws, Rp, Rs)は、通過帯域の損失がRp dB以下で、遮断
% 帯域に少なくともRs dBの減衰をもつ、ディジタルButterworthフィルタの最小
% 次数Nを出力します。通過帯域Wp と 遮断帯域Wsは、0 から 1 までの値で、通
% 過帯域と遮断帯域のエッジ周波数です。ここで、1はπラジアンに相当します。
%
% 例題：
%     ローパス:    　 Wp = .1,      Ws = .2
%     ハイパス:   　　Wp = .2,      Ws = .1
%     バンドパス:     Wp = [.2 .7], Ws = [.1 .8]
%     バンドストップ: Wp = [.1 .8], Ws = [.2 .7]
%
% BUTTORD は、仕様を満足するために、関数 BUTTER を使った、Butterworthカ
% ットオフ周波数(あるいは、"3 dB 周波数")Wnを出力します。
%
% [N, Wn] = BUTTORD(Wp, Ws, Rp, Rs, 's')は、アナログフィルタを設計します。
% この場合、WpとWsの周波数はラジアン/秒単位です。
% 
% また、Rpが3dBの場合、関数 BUTTER のWnと関数BUTTORDのWpは等価になります。
%
% 参考：   BUTTER, CHEB1ORD, CHEB2ORD, ELLIPORD.



%   Copyright 1988-2002 The MathWorks, Inc.
