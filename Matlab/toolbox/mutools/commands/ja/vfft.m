% function yout = vfft(yin,n)
%
% VARYING行列YINに対して長さNのFFTを行います。Nはオプションで、デフォル
% トはYINの中の独立変数の数です。NがYINの中の独立変数の数よりも大きい場
% 合、データにはゼロが付け加えられます。Nが独立変数の数よりも小さい場合、
% 打切られます。実際の計算には、MATLAB関数FFTが使われます。
%
% YINは秒単位の時間スケールで、YOUTはラジアン/秒単位の周波数スケールを使
% って出力されると仮定します。時間スケールは、単調で、最初の区間のみが周
% 波数スケールを求めるために使われます。
%
% 参考:  FFT, IFFT, VIFFT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
