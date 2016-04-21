%TZERO は、IDMODEL の伝達零点を算出します。
%   Control System Toolbox が必要です。
%  
%   Z = TZERO(M)
%
%   IDMODEL M の伝達零点を出力します。
% 
%   [Z,GAIN] = TZERO(M) は、システムが SISO の場合、伝達関数ゲインも同時
%   に出力します。
%   
%   デフォルトでは、観測入力からの伝達零点のみを算出します。ノイズ入力か
%   らの零点も同時に得るためには、あらかじめ NOISECNV を利用して測定入力
%   に変換しておきます。




%   Copyright 1986-2001 The MathWorks, Inc.
