% DATASTATS   データの統計量
% DS = DATASTATS(XDATA) は、構造体 DS の中の XDATA に関するデータの統計
% 量を戻します。XDATA は、実数の列ベクトルである必要があります。XDATA が
% 複素数の場合、虚部は無視されます。
%
% 戻される構造体 DS は、つぎのフィールドを含んでいます。
%
%      ds.num       --- データの中の点数
%      ds.max       --- データの最大値
%      ds.min       --- データの最小値
%      ds.mean      --- データの平均
%      ds.median    --- データの中央値
%      ds.range     --- 最大値と最小値の差
%      ds.std       --- データの標準偏差
%    
% [XDS,YDS] = DATASTATS(XDATA,YDATA) は、構造体 XDS と YDS に、XDATA と 
% YDATA に関するデータ統計量を戻します。XDATA と YDATA は、実数の列ベク
% トルで、複素数入力の場合は、虚部を無視します。XDS と YDS が、上の場合
% と同じような構造体です。

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
