% MPOWER   LTIモデルのベキ乗計算
%
% MPOWER(SYS,K) は、SYS^K の実行時にコールされ、ここで、SYS は入力と出力
% の数が同数のLTIモデルで、K は整数でなければいけません。結果は、つぎの
% LTIモデルになります。
%  * K>0 の場合、SYS * ... * SYS (K回) 
%  * K<0 の場合、INV(SYS) * ... * INV(SYS) (K回)
%  * K = 0 の場合、静的ゲイン EYE(SIZE(SYS))
%
% 書式 SYS^K は、手書きで書く時のように、伝達関数を設定できて便利です。
% たとえば、つぎのように設定することができます。
% 
%          - (s+2) (s+3)
%   H(s) = ------------
%          s^2 + 2s + 2
% 
% は、つぎのように入力します。
% 
%   s = tf('s')
%   H = -(s+2)*(s+3)/(s^2+2*s+2) 
%
% 参考 : TF, PLUS, MTIMES, LTIMODELS.


%   Copyright 1986-2002 The MathWorks, Inc. 
