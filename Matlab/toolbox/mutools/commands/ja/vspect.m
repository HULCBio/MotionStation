% function P = vspect(x,y,m,noverlap,window)
%
% Signal Processing ToolboxのSPECTRUMのようにモデル化されたスペクトル解
% 析ルーチンです。X(とオプションでY)は、時間の定義域の列を表わすVARYING
% 行列です。M点のfftが、NOVERLAP点のオーバラップと共に使われます。WINDOW
% は、オプションの文字列で、ウィンドウを指定します(デフォルトは'hanning'
% です)。現在、Signal Processing toolboxでサポートされているオプションは、
% 'hanning', 'hamming', 'boxcar', 'blackman', 'bartlett', 'triang'です。%
% 出力されたVARYING行列Pは、列[Pxx Pyy Pxy Txy Cxy]をもちます。Pxx(Pyy)
% は、X (Y)のパワースペクトルで、Pxyはクロススペクトル、Txyは伝達関数、
% Cxyは、コヒーレンスです。単一の入力列に対しては、Pxxのみが出力されます。
% 出力される独立変数は、ラジアン/秒単位の周波数です。信号Y(または、単一
% 信号の場合にはX)は、信号ベクトルです。各々の出力に対して、伝達関数が計
% 算されます。これは、単入力多出力伝達関数の推定に対応します。Pの各行は、
% 適切なYの行に対応します。
%
% 参考: FFT, IFFT, SPECTRUM, VFFT, VIFFT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
