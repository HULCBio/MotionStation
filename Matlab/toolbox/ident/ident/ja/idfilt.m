% IDDATA/IDFILT   データのフィルタリング
% 
% ZF = IDFILT(Z,N,Wn)、または、ZF = IDFILT(Z,FILTER)
%
%   Z      : 出力 - 入力データで、行列、または、IDDATA オブジェクトの型
%            をしています。 
%   ZF     : フィルタリングされたデータ。Z が、IDDATA の場合、ZF もIDD-
%             ATA になります。その他の場合、ZF の列は、Z の列に対応しま
%             す。
%   FILTER : SISO 線形システムで、LTI、または、IDMODEL オブジェクト、ま
%            たは、セル配列{a,b,c,d}(状態空間行列)、または、{num,den}(分
%            子と分母)のいずれかで設定したものです。
%   N      : 使用するフィルタの次数で、フィルタは、標準的な Butterworth 
%            フィルタです。
%   Wn     : Nyquist 周波数を1として、正規化したカットオフ周波数
%            Wn がスカラの場合、ローパスフィルタが使われます。
%            Wn = [Wl Wh] の場合、通過帯域 Wn をもつバンドパスフィルタが
%            使われます。
%
% ZF = IDFILT(Z,N,Wn,'high')、または、ZF = IDFILT(Z,N,[Wl Wh],'stop') を
% 使って、ハイパスフィルタや、バンドストップフィルタを使うこともできます。
%
% 最後の引数 'causal'/'noncausal' はフィルタリングのモードを決定します:
% ZF = IDFILT(Z,...,'Causal') は、データに対して、因果性を保ったフィルタ
% リングをし、一方、ZF = IDFILT(Z,...,'Noncausal') は、ゼロ位相の非因果
% 性のフィルタリングを行います。
%
% [ZF,MFILT] = IDFILT(Z,N,Wn) を使って、フィルタは、一つの IDMODEL とし
% て出力されます。
%
% 参考： IDDATA/DETREND と IDDATA/RESAMPLE


%   L. Ljung 10-1-89, 3-3-95.
%   The code is adopted from several routines in the Signal Processing
%   Toolbox.
%   Copyright 1986-2001 The MathWorks, Inc.
