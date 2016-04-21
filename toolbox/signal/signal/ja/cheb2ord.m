% CHEB2ORD Chebyshev II 型フィルタの次数推定
%
% [N, Wn] = CHEB2ORD(Wp, Ws, Rp, Rs)は、通過帯域の変動がRp dB以下で、遮
% 断帯域に少なくともRs dBの減衰をもつディジタル Chebyshev II 型フィルタ
% の最小次数Nを出力します。通過帯域Wpと遮断帯域Wsは、0 から 1 までの値で、
% 通過帯域と遮断帯域のエッジ周波数で、1はπラジアンに相当します。
% 
% 例題： 
%     ローパス:       Wp = .1,      Ws = .2
%     ハイパス:       Wp = .2,      Ws = .1
%     バンドパス:     Wp = [.2 .7], Ws = [.1 .8]
%     バンドストップ: Wp = [.1 .8], Ws = [.2 .7]
%
% CHEB2ORDは、仕様を満足するChebyshev カットオフ周波数 Wn を出力します。
% 
% [N, Wn] = CHEB2ORD(Wp, Ws, Rp, Rs, 's')は、アナログフィルタを設計しま
% す。この場合、WpとWsの周波数はラジアン/秒単位です。
%
% 参考： CHEBY2, CHEB1ORD, BUTTORD, ELLIPORD.



%   Copyright 1988-2002 The MathWorks, Inc.
