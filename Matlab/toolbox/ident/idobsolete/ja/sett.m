% SETT   TH 構造と周波数関数でのサンプリング周期の設定
% 
%    THN = sett(TH, T) または、
%    GN = sett(G, T)
%
%   TH   :  THETA フォーマットのオリジナルモデル
%   T    :   サンプリング周期
%   THN  : THETA フォーマットの更新モデル。サンプリング周期は T。
%   または、
%   G    :  オリジナルの周波数関数
%   GN   :  目標サンプリング周期に準拠してスケーリングされた周波数をもつ
%           周波数関数
% 周波数関数に関して、SETT は、周波数のデフォルト範囲が設定された SPA, 
% ETFE, TH2FF, TRF の出力に対してのみ機能します。
%
% 参考:    FREQFUNC

%   Copyright 1986-2001 The MathWorks, Inc.
