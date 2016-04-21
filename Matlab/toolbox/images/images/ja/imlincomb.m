% IMLINCOMB イメージの線形結合を計算します。
% Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An) は、K1*A1 + K2*A2 + ... +Kn*An
% を計算します。A1, A2, ..., Anは、同じクラス、サイズをもつ実数、非スパース、
% 数値配列です。K1, K2, ..., Knは、スカラで、倍精度の実数です。
% Z は、A1と同じクラス、サイズをもちます。
%
% Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An,K) は、K1*A1 + K2*A2 +
% ... + Kn*An + Kを計算します。
%
% Z = IMLINCOMB(..., OUTPUT_CLASS) は、Z のクラスを指定します。
% OUTPUT_CLASSは、数値のクラス名を含む文字列です。
%
% IMADD や IMMULTIPLY のような個々の代数関数を入れ子状態でコールするより
% も、一組のイメージに、IMLINCOMB を使って、一連の代数処理を適用すること
% ができます。代数関数のコールを入れ子にし、入力配列が整数クラスの場合、
% 個々の関数は、つぎの関数に結果を渡す前に、結果に打ち切りや丸めを適用し
% ます。そのため、最終的な結果は、精度が落ちます。しかし、IMLINCOMB は、
% 最終的な結果に打ち切りや丸めを行う前に、すべての代数演算を一度に行います。
%
% 出力 Z の個々の要素は、倍精度の浮動小数点で、個々に計算されます。Z が
% 整数配列の場合、整数タイプの範囲を超えたZの出力要素は、打ち切られ、小数点
% 以下は丸められます。
%
% 例題1
% ---------
% 2のファクタを使って、イメージをスケールします。
%
%       I = imread('cameraman.tif');
%       J = imlincomb(2,I);
%       imshow(J)
%
% 例題2
% ---------
% 2つのイメージの差に、0を128にシフトする操作を付加
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imlincomb(1,I,-1,J,128); % K(r,c) = I(r,c) - J(r,c) + 128
%       imshow(K)
%
% 例題3
% ---------
% 指定した出力クラスを使用して2つのイメージを付加
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imlincomb(1,I,1,J,'uint16');
%       imshow(K,[])
%
% 参考 IMADD, IMCOMPLEMENT, IMDIVIDE, IMMULTIPLY, IMSUBTRACT.



%   Copyright 1993-2002 The MathWorks, Inc.
