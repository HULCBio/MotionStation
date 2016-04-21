% BIORWAVF 　双直交スプラインウェーブレットフィルタ
% [RF,DF] = BIORWAVF(W) は、文字列 W により設定された双直交ウェーブレットに関連
% した2つのスケーリングフィルタを出力します。
% 
% W = 'biorNr.Nd' で、Nr と Nd には、つぎの値を設定することができます。
% Nr = 1  Nd = 1 、3 、5
% Nr = 2  Nd = 2 、4 、6 、8
% Nr = 3  Nd = 1 、3 、5 、7 、9
% Nr = 4  Nd = 4
% Nr = 5  Nd = 5
% Nr = 6  Nd = 8
% 出力引数は、フィルタ係数です。
% RF は、再構成フィルタです。
% DF は、分解フィルタです。
%
% 参考： BIORFILT, WAVEINFO.



%   Copyright 1995-2002 The MathWorks, Inc.
