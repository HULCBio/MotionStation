% PYULEAR   Yule-Walker 法を使って、パワースペクトル密度(PSD)を計算
% Pxx = PYULEAR(X,ORDER) は、離散時間信号ベクトル X の PSD を Pxx に出力
% します。Pxx は、単位周波数に対するパワーの分布を示すものです。周波数は、
% rad/サンプルで示します。ORDER は、PSD を作成するために使用する自己回帰
% (AR)モデルの次数です。PYULEAR は、デフォルトの256の FFT を使って、Pxx 
% の長さを決定します。
%
% PYULEAR は、実数信号の場合、デフォルトで、片側 PSD で、複素数信号の場
% 合、両側 PSD になります。片側 PSD は、入力信号のすべてのパワーを含んで
% いることに注意してください。
%
% Pxx = PYULEAR(X,ORDER,NFFT) は、 PSD 推定を計算するために FFT の長さを
% 設定します。実数に対して、NFFT が偶数の場合、(NFFT/2+1)で、奇数の場合
% (NFFT+1)/2 です。複素数では、Pxxは、長さが常に NFFT になります。空の場
% 合、デフォルトは256です。
%
% [Pxx,W] = PYULEAR(...) は、PSD を計算する正規化された角周波数からなる
% ベクトル W を出力します。W の単位は、rad/サンプルです。実数信号に対し
% て、W は、NFFT が偶数の場合[0,pi]の区間に広がり、NFFT が奇数の場合[0,
% pi)の範囲になります。複素数信号の場合、W は、常に、[0.2*pi)の区間です。
%
% [Pxx,F] = PYULEAR(...,Fs) は、サンプリング周波数を Hz 単位で設定し、Hz
% 毎にパワースペクトル密度を出力します。F は、Hz 単位の周波数ベクトルで、
% ここで設定されている周波数で、PSD を計算します。実数信号に対して、Fは、
% NFFT が偶数の場合[0,Fs/2]で、奇数の場合[0,Fs/2)の範囲に広がります。複
% 素数信号に対して、Fは、常に、[0,Fs)の範囲です。Fsを空にすると、デフォ
% ルトのサンプリング周波数1 Hz を使います。 
%
% [Pxx,W] = PYULEAR(...,'twosided') は、[0,2*pi) 区間での PSD を計算しま
% す。そして、 [Pxx,F] = PYULEAR(...,Fs,'twosided') は、[0,Fs) 区間での 
% PSD を計算します。'onesided' は、オプションで設定できますが、X が実数
% のときにのみ適用できることに注意してください。文字列 'twosided' または
% 'onesided' は、入力引数の中で ORDER の後の任意の位置に設定できます。
%
% 出力引数を設定しない PYULEAR(...) は、カレントの Figure ウインドウに単
% 位周波数に対する PSD の大きさを dB 単位でプロットします。
%
% 例題：
%      randn('state',1);
%      x = randn(100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x);
%      pyulear(y,4,[],1000);       % NFFT のデフォルト値 256 を使用
%
% 参考：   PBRUG, PCOV, PMCOV, PMTM, PMUSIC, PWELCH, PERIODOGRAM, 
%          PEIG, ARYULE, PRONY, PSDPLOT.



%   Copyright 1988-2002 The MathWorks, Inc.
