% WAVRECORD Windows オーディオ入力デバイスを使って、音声を録音
%
% WAVRECORD(N,FS,CH) は、Windows WAVE オーディオデバイスを使って、入力
% チャネル CH から、FS Hz のサンプリングレートで、N 個のオーディオ
% サンプルを録音します。標準のオーディオレートは、8000, 11025, 22050, 
% 44100 Hz です。CH は、1、または 2(モノラルかステレオ)です。設定しな
% ければ、FS = 11025 Hzで、CH = 1 です。
%
% WAVRECORD(..., DTYPE) は、DTYPE で設定したデータタイプを使って、データ
% を録音して、出力します。サポートしているデータタイプと対応するビット数
% をつぎに示します。
%        DTYPE     ビット数/サンプル
%       'double'      16
%       'single'      16
%       'int16'       16
%       'uint8'        8
%
% この関数は、32-bit  Windows マシンでのみ使用できます。
%
% 例題: 11.025 Hzでサンプリングした16ビットのオーディオデータ5秒分を録音して、
%         再生しましょう。
%       Fs = 11025;
%       y  = wavrecord(5*Fs, Fs, 'int16');
%       wavplay(y, Fs);
%
%   参考 ： WAVPLAY, WAVREAD, WAVWRITE.


%   Author: D. Orofino
%   Copyright 1988-2004 The MathWorks, Inc. 
