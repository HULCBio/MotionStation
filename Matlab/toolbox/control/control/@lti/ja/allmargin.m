% ALLMARGIN   すべての安定余裕とクロスオーバ周波数
%
%
% S = ALLMARGIN(SYS) は、SISO開ループモデル SYS のゲイン、位相、遅延余裕と対応
% するクロスオーバ周波数に関する詳細を出力します。
%
% 出力 S は、つぎのフィールドをもつ構造体です。
%  * GMFrequency: すべて、-180 度のクロスオーバ周波数 (rad/sec単位)
%  * GainMargin: 対応するゲイン余裕 (g.m.= 1/G ここで、G は、クロスオーバでのゲイン) 
%  * PMFrequency: すべて、0 dB のクロスオーバ周波数(rad/sec単位)
%  * PhaseMargin: 対応する位相余裕(度単位)* DelayMargin: 対応する遅延余裕 
%    (連続系では秒、離散系ではサンプル時間を単位にします)
%  * Stable: ノミナル閉ループが安定な場合1、その他の場合0です。
%
% 参考 : MARGIN, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
