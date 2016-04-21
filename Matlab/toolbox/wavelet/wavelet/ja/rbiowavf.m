% RBIOWAVF 　　逆双直交スプラインウェーブレットフィルタ
% [RF,DF] = RBIORWAVF(W) は、文字列 W により設定された双直交ウェーブレットに関連
% した2つのスケーリングフィルタを出力します。W = 'rbiorNd.Nr' で、Nd と Nr は、
% つぎの値を使うことができます。
% 
% Nd = 1  Nr = 1 、3 or 5
% Nd = 2  Nr = 2 、4 、6 or 8
% Nd = 3  Nr = 1 、3 、5 、7 or 9
% Nd = 4  Nr = 4
% Nd = 5  Nr = 5
% Nd = 6  Nr = 8
% 出力引数は、フィルタ係数です。
% RF は、再構成フィルタです。
% DF は、分解フィルタです。



%   Copyright 1995-2002 The MathWorks, Inc.
