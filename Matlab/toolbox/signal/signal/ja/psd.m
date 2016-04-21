% PSD は、パワースペクトル密度の推定を行います。
% Pxx = PSD(X,NFFT,Fs,WINDOW) は、Welchの平均化、修正ピリオドグラム法を
% 使って、離散時間信号ベクトル X のパワースペクトル密度を求めます。
% 
% X は、オーバラップの部分に分け、その各々で、関数 DETREND の FLAG で設
% 定した方法を使って、トレンドの除去を行い、その結果に WINDOW パラメータ
% を使ってウインドウ操作を行い、長さが NFFT になるようにゼロを付加します。
% 各部分での長さ NFFT のDFT の結果の大きさの二乗の平均を使って、Pxx を作
% 成します。Pxx は、NFFT が偶数の場合、NFFT/2+1 で、NFFT が奇数の場合、
% (NFFT+1)/2 になり、また、信号 X が複素数の場合、NFFT になります。WIN-
% DOW にスカラ値が設定されている場合、その長さのHanning ウィンドウが使わ
% れます。Fs は、スペクトル推定に影響しないサンプリング周波数で、プロッ
% トでの　X-軸のスケーリングに使用します。
%
% [Pxx,F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP) は、PSD を計算する周波数ベク
% トルを Pxx と同じ大きさで出力します。ここで、X の部分は、NOVERLAP 個の
% サンプル分オーバラップしています。
%
% [Pxx, Pxxc, F] = PSD(X,NFFT,Fs,WINDOW,NOVERLAP,P) は、Pxx に対する 
% P*100 %の信頼区間を出力します。ここで、P は、0から1の間のスカラ値です。
%
% PSD(X,...,DFLAG) は、X にウィンドウを前もって適用した結果に対して、ト
% レンド除去方法を指定するDFLAG を、'linear', 'mean', 'none' のいずれか
% ら設定できます。DFLAG は、引数の中で任意の位置(X の部分以外)に設定でき
% ます。たとえば、PSD(X,'mean') です。
% 
% 出力引数を設定しない PSD は、カレントの Figure ウインドウに PSD をプロ
% ットし、P が設定されている場合は、信頼区間も表示します。
%
% パラメータ対するデフォルト値は、NFFT = 256 (または LENGTH(X) と比べて
% 小さいほう)、NOVERLAP = 0, WINDOW = HANNING(NFFT), Fs = 2, P = .95, 
% DFLAG = 'none' です。デフォルトパラメータを使用するには、空行列を設定
% するか、省略してください。たとえば、PSD(X,[],10000) です。
%
% 注意：
% Welch 法は、サンプリング周波数(1/Fs)でスケーリングするようになっていま
% す。詳細は、関数 PWELCH を参照してください。
%
% 参考：   PWELCH, CSD, COHERE, TFE.
%          ETFE, SPA, ARX(System Identification Toolbox)

%   Copyright 1988-2001 The MathWorks, Inc.
