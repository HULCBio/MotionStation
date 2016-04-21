% NORMHINF   連続系のH∞ノルム
%
% [NMHINF] = NORMHINF(A,B,C,D,tol)、または、[NMHINF] = NORMHINF(SS_,tol)は、
% 与えられた状態空間実現のHINFノルムを計算します。ここでは、つぎのハミルト
% ニアンの虚軸上で固有値の二分探索法を採用しています。
%
%                        -1           -1
%       H(gam) = | A + BR  D'C     -BR  B'        |
%                |       -1                -1     |
%                |C'(I+DR  D')C    -(A + BR  D'C)'|
%
% ここで、R = gam^2 I - D'D > 0です。Hが虚軸上に固有値をもつとき、HINFノル
% ムは"gam"と等しくなります。
%
% HINFノルムの上界と下界の初期推定は、つぎのようになります。
%
%       上界: max_sigma(D) + 2*sum(Hankel SV(G))
%       下界: max{max_sigma(D), max_Hankel SV(G)}
%
% サーチアルゴリズムは、2つの隣接する"gam's"の相対誤差が"tol"よりも小さい
% ときに終了します。"tol"が与えられなければ、tol = 0.001です。



% Copyright 1988-2002 The MathWorks, Inc. 
