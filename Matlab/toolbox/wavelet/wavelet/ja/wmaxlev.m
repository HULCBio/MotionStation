% WMAXLEV 　最大ウェーブレット分割レベル
% WMAXLEV は、不必要に高いレベル値を避けるのに有効です。
%
% L = WMAXLEV(S,'wname') は、文字列 'wname' (WFILTERS 参照)で指定されたウェーブ
% レットを使って、大きさ S の信号またはイメージを分割する最大レベルを出力します。
%
% WMAXLEV は、分解の許される最大レベルを出力します。しかし、一般には、その値より
% 小さい値を使ってください。1次元では通常5を、2次元の場合では、通常3をそれぞれ使
% ってください。
%
% 参考： WAVEDEC, WAVEDEC2, WPDEC, WPDEC2.



%   Copyright 1995-2002 The MathWorks, Inc.
