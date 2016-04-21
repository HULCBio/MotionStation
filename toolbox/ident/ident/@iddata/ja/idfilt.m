% IDDATA/IDFILT は、データをフィルタリングします。
% ZF = IDFILT(Z,N,Wn)、または、ZF = IDFILT(Z,FILTER)
%
%   Z  : 出入力データ、IDDATA オブジェクト 
%   ZF : フィルタを適用するデータ。Z が IDDATA の場合、ZF です。
%        他の場合、ZF の列は、Z の列に対応します。
%   N  : 使用するフィルタの次数
%   Wn : カットオフ周波数を、Nyquist周波数をベースに表現したもの
%        Wn がスカラの場合、ローパスフィルタを使用
%        Wn = [Wl Wh] の場合、バンドパスフィルタを使用。
%
% ZF = IDFILT(Z,N,Wn,'high')、または、ZF = IDFILT(Z,N,[Wl Wh],'stop') を
% 使って、ハイパスまたはバンドストップフィルタを使用することもできます。
%
% [ZF,THFILT] = IDFILT(Z,N,Wn) は、IDMODEL としてフィルタを出力します。
% 
% 参考： IDDATA/DETREND, IDDATA/RESAMPLE

%   L. Ljung 10-1-89, 3-3-95.
%   The code is adopted from several routines in the Signal Processing
%   Toolbox.


% $Revision: 1.4 $
% Copyright 1986-2001 The MathWorks, Inc.
