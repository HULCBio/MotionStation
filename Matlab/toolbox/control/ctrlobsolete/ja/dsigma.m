% DSIGMA   離散時間線形システムの特異値周波数応答
%
% DSIGMA(A,B,C,D,Ts) (または、オプションとして、RCT では、SIGMA(SS_,Ts)) 
% は、行列の特異値プロットを作成します。
%                                       -1
%                 G(w) = C(exp(jwT)I-A) B + D 
% 
% これらは、周波数の関数です。特異値は、Bode 線図の大きさの応答を MIMO 
% システムに拡大したものです。周波数の範囲と点数は、自動的に選択されます。
% 正方システムに対して、DSIGMA(A,B,C,D,Ts,'inv') は、逆行列の特異値を
% 作成します。
%                -1                    -1      -1
%             G (w) = [ C(exp(jwT)I-A) B + D ]
% DSIGMA(A,B,C,D,Ts,W) または、DSIGMA(A,B,C,D,Ts,W,'inv')  は、特異値応答
% を計算する周波数点を示すベクトル W を設定します。単位は、rad/sec です。
% エリアジングは、Nyquist 周波数(pi/Ts)より高い周波数で生じます。左辺に
% 出力引数を設定しない場合、
% 
%        [SV,W] = DSIGMA(A,B,C,D,Ts,...)
%        [SV,W] = SIGMA(SS_,Ts,...)    (Robust Control Toolbox のユーザ用)
% 
% 周波数ベクトル W と、MIN(NU,NY)を列とし、length(W)を行とする行列 SV を
% 出力します。ここで、NU は入力数、NY は出力数です。スクリーン上にプロット
% 表示を行いません。特異値は、大きい順に出力されます。
%
% 参考 : SIGMA, LOGSPACE, SEMILOGX, NICHOLS, NYQUIST, BODE.


%   Clay M. Thompson  7-10-90
%   Revised A.Grace 2-12-91, 6-21-92
%   Revised W.Wang 7/24/92
%   Revised P. Gahinet 5-7-96
%   Revised M. Safonov 9-12-97 & 4-18-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:56 $
