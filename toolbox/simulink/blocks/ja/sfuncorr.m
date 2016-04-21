% SFUNCORR   自己相関および相互相関を計算するS-function
%
% このM-ファイルは、Simulink S-Functionブロックにおいて利用するために設計さ
% れています。これは、システムの入力および出力をバッファにストアし、入力信号の
% パワースペクトル密度をプロットします。
%
% 入力引数は、つぎのとおりです。
% npts:      fftで用いるデータ点数(例. 128)
% HowOften:  fftのプロット間隔(例. 64)
% offset:    サンプル時間のオフセット(通常ゼロ)
% ts:        サンプル点の間隔(秒)
% cross:     相互相関に対しては1、自己相関に対しては0
% biased:    'biased'、または、'unbiased'
%
% cross correlatorは、時刻歴のプロットと 自己相関または相互相関のプロットを
% 与えます。
%
% 参考 : SFUNTMPL, XCORR, SFUNPSD.


% Copyright 1990-2002 The MathWorks, Inc.
