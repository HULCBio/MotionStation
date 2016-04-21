% SPECTRUM   1つまたは2つのデータ列のパワースペクトル推定 
% P = SPECTRUM(X,NFFT,NOVERLAP,WIND) は、Welch の平均化する周波数解析法
% を使って、信号のベクトル X のパワースペクトル密度を計算します。信号 X 
% は、オーバラップした部分を含んで分割され、個々の部分は、トレンドを除去
% し、WINDOW パラメータによりウインドウを適用し、長さが NFFT 以下の場合、
% ゼロを付加します。各部分の長さ NFFT の DFT の大きさの二乗したものが平
% 均化され、Pxx を作成します。P は、P = {Pxx  Pxxc] の型の2列の行列です。
% 2列目の Pxxc は、95%の信頼区間を示すものです。P の行数は、NFFT が偶数
% の場合、NFFT/2+1で、奇数の場合、(NFFT+1)/2 です。また、信号 X が複素数
% の場合は、NFFT になります。WINDOW がスカラの場合、この長さの Hanning 
% ウインドウが使われます。
%
% [P,F] = SPECTRUM(X,NFFT,NOVERLAP,WINDOW,Fs) は、サンプリング周波数 Fs 
% を使って、PSD を推定したPxx と同じ長さの周波数ベクトルを出力します。
% PLOT(F,P(:,1)) は、真の周波数に対するパワースペクトル推定をプロットし
% ます。
%
% [P, F] = SPECTRUM(X,NFFT,NOVERLAP,WINDOW,Fs,Pr) は、Pr を0から1の間の
% スカラ値で設定すると、PSDに対して、デフォルトの95%の信頼区間ではなく、
% Pr*100 %の信頼区間を出力します。
%
% 出力引数を設定しないで、SPECTRUM(X) のみを使用すると、カレントの Fig-
% ure ウインドウに PSD を信頼区間と共にプロットします。
%
% デフォルト値は、NFFT は、256とA の長さの内、短い値、WINDOW = HANNING
% (NFFT)、NOVERLAP = 0、Fs = 2、Pr = 0.95 です。デフォルト値を使用する場
% 合は、使用したいデフォルト設定値以降のパラメータを省略するか、空行列を
% 使用します。たとえば、SPECTRUM(X,[],128) です。
%
% P = SPECTRUM(X,Y) は、2つの数列 X と Y のスペクトル解析を行います。
% SPECTRUM は、つぎの要素をもつ8列からなる配列を出力します。
% 
%   P = [Pxx Pyy Pxy Txy Cxy Pxxc Pyyc Pxyc]
% 
% ここで、
%   Pxx  = X-ベクトルのパワースペクトル密度
%   Pyy  = Y-ベクトルのパワースペクトル密度
%   Pxy  = クロススペクトル密度
%   Txy  = X から Y = Pxy./Pxx への複素伝達関数
%   Cxy  = X と Y = (abs(Pxy).^2)./(Pxx.*Pyy) との間のコヒーレンス関数
%   Pxxc,Pyyc,Pxyc = 信頼範囲
% 
% すべての入力と出力のオプションは、単入力の場合と全く同じものです。
% 
% 出力引数を設定しないで、SPECTRUM(X,Y)のみでの使用は、プロット毎にポー
% ズを設定しながら、連続的に、Pxx, Pyy, abs(Txy), angle(Txy), Cxy をプロ
% ットします。
%
% SPECTRUM(X,...,DFLAG) は、X にウィンドウを前もって適用した結果に対して、
% トレンド除去方法を指定する、DFLAG を、'linear', 'mean', 'none' のいず
% れかから設定できます。DFLAG は、引数の中で任意の位置(X の部分以外)に設
% 定できます。たとえば、SPECTRUM(X,'none') です。
%
% 参考：   PSD, CSD, TFE, COHERE, SPECGRAM, SPECPLOT, DETREND, 
%          PMTM, PMUSIC. 
%          ETFE, SPA, ARX(Identification Toolbox)

%   Copyright 1988-2001 The MathWorks, Inc.
