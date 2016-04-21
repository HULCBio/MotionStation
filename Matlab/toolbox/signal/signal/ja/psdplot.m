% PSDPLOT は、パワースペクトル密度(PSD)データをプロットします。
%
% PSDPLOT(Pxx,W) は、W(単位は、rad/サンプル)に設定した周波数で計算した 
% PSD をプロットします。
% 
% PSDPLOT(Pxx,W,UNITS) は、プロット用の周波数(x-軸)の単位を設定します。
% UNITS は、'RAD/SAMPLE' (デフォルト) または 'Hz' のいずれかを使用できま
% す。
%
% PSDPLOT(Pxx,W,UNITS,YSCALE) は、PSD プロット用のY-軸のスケーリングを設
% 定します。YSCALE は、'LINEAR'、または、'DB' のいずれかを使用できます。%
% PSDPLOT(Pxx,W,UNITS,YSCALE,TITLESTRING) は、プロット図のタイトルを設定
% する文字列を指定します。
%
% 参考：   PERIODOGRAM, PWELCH, PEIG, PMTM, PMUSIC, PBURG, PCOV, PMCOV,
%          PYULEAR.



%   Author(s): R. Losada 
%   Copyright 1988-2002 The MathWorks, Inc.
