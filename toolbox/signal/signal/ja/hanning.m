% HANNING Hanningウィンドウ
%
% HANNING(N)は、N点の対称なHanningウィンドウを列ベクトルとして出力します。
% また、ウィンドウサンプルの最初と最後にゼロが重み付けされているものは含
% まれないことに注意してください。
%
% HANNING(N,'symmetric')は、HANNING(N)と同じ結果を出力します。
%
% HANNING(N,'periodic')は、周期的なN点のHanningウィンドウを出力し、最初
% にゼロが重み付けされているウィンドウサンプルを含みます。
% 
% 注意：最初と最後の点がｍ重みゼロのHanningウインドウを得るには、関数HA-
% NNを使ってください。
%
% 参考：   BARTLETT, BLACKMAN, BOXCAR, CHEBWIN, HAMMING, HANN, 
%          KAISER, TRIANG.

%   Copyright 1988-2001 The MathWorks, Inc.
