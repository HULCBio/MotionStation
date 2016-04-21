% SFUNPSD   fftを用いたスペクトル解析を行うS-function
%
% このM-ファイルは、Simulink S-Functionブロックにおいて利用するために
% 設計されています。
% これは、システムの入力および出力をバッファにストアし、入力信号のパワー
% スペクトル密度をプロットします。
%
% 入力引数は、つぎのとおりです。
%       npts:               fftで用いるデータ点数(例. 128)
%       HowOften:       fftのプロット間隔(例. 64)
%       offset:             サンプル時間のオフセット(通常ゼロ)
%       ts:                  サンプル点の間隔(秒)
%       averaging:       psdを平均化するかどうか
%
% 時刻歴のプロットと 瞬間的なpsdと平均psdの2つまたは3つのプロットが出力され
% ます。
%
% 参考 : FFT, SPECTRUM, SFUNTMPL, SFUNTF.


% Copyright 1990-2002 The MathWorks, Inc.
