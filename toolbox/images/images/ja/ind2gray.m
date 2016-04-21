% IND2GRAY   インデックス付きイメージを強度イメージへ変換
%   I = IND2GRAY(X,MAP) は、カラーマップ MAP をもつイメージ X を強度イ
%   メージ I に変換します。IND2GRAY は、輝度を変更しないで、入力イメー
%   ジから色調と彩度情報を取り除きます。
%
%   クラスサポート
% -------------
%   X は、uint8、uint16、または、double のいずれのクラスもサポートして
%   います。I は、クラス double です。
%
%   例題
%   ----
%       load trees
%       I = ind2gray(X,map);
%       imshow(X,map), figure, imshow(I)
%
%   参考：GRAY2IND, IMSHOW, RGB2NTSC



%   Copyright 1993-2002 The MathWorks, Inc.  
