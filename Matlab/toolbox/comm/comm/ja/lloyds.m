% LLOYDS Lloyd アルゴリズムを使用して、量子化パラメータを最適化
%
% [PARTITION, CODEBOOK] = LLOYDS(TRAINING_SET, INI_CODEBOOK) は、Lloyd 
% アルゴリズムを使用して、指定したトレーニングベクトル TRAINING_SET に
% 基づいて、スカラ量子化 PARTITION と CODEBOOK を最適化します。変数 
% TRANING_SET のデータは、量子化するメッセージソースの典型的なデータで
% なければなりません。INI_CODEBOOK は、コードブック値の初期推定値です。
% 最適化された CODEBOOK のベクトル長は、INI_CODEBOOK と同じです。
% INI_CODEBOOK がベクトルでなくスカラ整数であるとき、それは望ましい 
% CODEBOOK ベクトルの長さです。PARTITION のベクトル長は、CODEBOOK の
% ベクトル長から1を引いた長さになります。相対歪み値が10^(-7)より小さい
% とき、最適化処理を終了します。
% 
% [PARTITION, CODEBOOK] = LLOYDS(TRAINING_SET, INI_CODEBOOK, TOL) は、
% 最適化の許容範囲を与えます。
% 
% [PARTITION, CODEBOOK, DISTORTION] = LLOYDS(...) は、最適化の最終歪み値
% を出力します。
% 
% [PARTITION, CODEBOOK, DISTORTION, REL_DISTORTION] = LLOYDS(...) は、
% 計算の終了時に、相対歪み値を出力します。 
%
% 参考： QUANTIZ, DPCMOPT.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
