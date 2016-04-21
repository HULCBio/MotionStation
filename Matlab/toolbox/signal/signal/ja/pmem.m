% PMEM   MEM(最大エントロピー法)を使って、パワースペクトル密度を計算
% Pxx = PMEM(X,ORDER,NFFT) は、MEM 法を使って、信号ベクトル X のパワース
% ペクトル密度を計算します。ORDER は、AR モデル方程式のモデル次数です。
% NFFT は、FFT の長さで、周波数グリッドを決定します。X がデータ行列の場
% 合、各列は、異なるセンサまたは実験からの測定値と考えます。Pxx は、NFFT
% が偶数の場合、長さ(NFFT/2+1)、奇数の場合、(NFFT+1)/2です。Xが複素数の
% 場合、長さは NFFT になります。NFFT はオプションで、デフォルト値は256で
% す。
%
% [Pxx,F] = PMEM(X,ORDER,NFFT,Fs) は、PSD が計算される周波数ベクトルを出
% 力します。ここで、Fs は、サンプル周波数です。Fsはデフォルトで 2Hzです。
%
% PMEM(X,ORDER,'corr'), PMEM(X,ORDER,NFFT,'corr'), PMEM(X,ORDER,NFFT,...
% Fs,'corr') は、相関行列 X を使います。X は、正方行列です。
%
% [Pxx,F,A] = PMEM(X,ORDER,NFFT) は、Pxx をベースにしたモデル係数のベク
% トル A を出力します。
%
% 出力引数を設定しない場合は、PMEM は、使用可能なフィギュアに PSD をプロ
% ットします。
% 
% デフォルト値を使用する場合は、空行列を設定してください。たとえば、つぎ
% のように設定します。
% 
%     PMEM(X,8,400,[],'corr').
%
% 参考：   PBURG, PCOV, PMCOV, PMTM, PMUSIC, PWELCH, PYULEAR, LPC, PRONY

%   Copyright 1988-2001 The MathWorks, Inc.
