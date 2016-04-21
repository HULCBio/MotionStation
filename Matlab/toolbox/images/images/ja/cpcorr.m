% CPCORR  相互相関を使って、コントロールポイントの位置を調整 
% INPUT_POINTS = CPCORR(INPUT_POINTS_IN,BASE_POINTS_IN,INPUT,BASE) は、
% 正規化した相互相関を使って、INPUT_POINTS_IN と BASE_POINTS_IN に指定
% したお互いのコントロールポイントの位置を調整します。
%
% INPUT_POINTS_IN は、入力イメージ内のコントロールポイントの座標を含む 
% M 行 2列の double の行列です。BASE_POINTS_IN は、ベースイメージ内のコ
% ントロールポイントの座標を含む M 行 2列の double の行列です。
%
% CPCORR は、INPUT_POINTS_IN と同じ大きさの double の行列 INPUT_POINTS 
% に調整したコントロールポイントを出力します。CPCORR が、コントロールポ
% イントの組で相関が存在しない場合、INPUT_POINTS は、その組に対して、
% INPUT_POINTS_IN と同じ座標を含みます。
%
% CPCORR は、4ピクセルまで、コントロールポイントの位置を移動します。調整
% された座標は、ピクセルの1/10の大きさの精度をもち、CPCORR は、イメージ
% 内容と粗いコントロールポイント選択からサブピクセル精度を得るように設計
% されています。
%
% INPUT イメージと BASE イメージは、効率的になるには、CPCORR と同じスケ
% ールをもっている必要があります。
%
% CPCORR は、つぎのいずれかが起こる場合、ポイントを調整することができま
% せん。
%     - ポイントが、イメージのエッジに非常に近い場合
%     - Inf、または、NaN を含むポイントの回りのイメージの領域
%     - 入力イメージの中の点の回りの領域が、ゼロの標準偏差をもっている
%     - 点の回りのイメージの領域の相関が低い
%
% クラスサポート
% -------------
% イメージは、クラス logical, uint8, uint16, または、double で、有限値
% を含んでいる必要があります。入力のコントロールポイントの組は、クラス
% double です。
%
% 例題
% --------
% つぎの例題は、CPCORR を使って、イメージ内に選択したコントロールポイント
% の細かいチューニングをするものです。INPUT_POINTS 行列と INPUT_POINTS_ADJ
% の値の中の違いに注意してください。
%
%       input = imread('lily.tif');
%       base = imread('flowers.tif');
%       input_points = [127 93; 74 59];
%       base_points = [323 195; 269 161];
%       input_points_adj = cpcorr(input_points,base_points,...
%                                 input(:,:,1),base(:,:,1))
%
% 参考：CP2TFORM, CPSELECT, NORMXCORR2, IMTRANSFORM.



%   Copyright 1993-2002 The MathWorks, Inc.

