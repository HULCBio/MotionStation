% DPCMOPT 差分パルス符号変調パラメータを最適化
%
% PREDICTOR = DPCMOPT(TRAINING_SET, ORD) は、設定次数 ORD とトレーニング
% セットTRAINING_SET を使って、予測伝達関数を推定します。
%
% [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,LENGTH) は、
% 対応する最適化された CODEBOOK と PARTITION を出力します。LENGTH は、
% CODEBOOK の長さを記述する整数です。
%
% [PREDICTOR,CODEBOOK,PARTITION] = DPCMOPT(TRAINING_SET,ORD,INI_CODEBOOK)
% は、DPCM に対して最適化された予測伝達関数 P_TRAINS, CODEBOOK, および
% PARTITION を作成します。また、入力変数INI_CODEBOOK には、コードブック
% ベクトルの初期推定値を含むベクトル、または、CODEBOOK のベクトルサイズを
% 指定するスカラ整数のどちらかを設定することができます。
%
% 参考： LLOYDS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
