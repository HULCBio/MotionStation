% SUBIMAGE   1つの Figure 内に複数のイメージを表示
%
% SUBIMAGE は、SUBPLOT と組み合わせて、複数のイメージを1つの Figure に
% 表示させることができます。これは、異なるカラーマップを使っている場合
% も実行できます。SUBIMAGE は、異なるカラーマップにより生じる問題を避け
% るために、表示目的でイメージをトゥルーカラーに変換して使います。
%
% SUBIMAGE(X,MAP) は、カレントの軸の中に、カラーマップ MAP を使って
% インデックス付きイメージ X を表示します。
%
% SUBIMAGE(I) は、カレント軸に強度イメージ I を表示します。
%
% SUBIMAGE(BW) は、カレント軸にバイナリイメージ BW を表示します。
%
% SUBIMAGE(RGB) は、カレント軸にトゥルーカラーイメージ RGB を表示しま
% す。
%
% SUBIMAGE(x,y,...) は、デフォルトでない空間座標系を使ってイメージを
% 表現します。
%
% H = SUBIMAGE(...) は、イメージオブジェクトのハンドル番号を出力します。
% 
%
% クラスサポート
% -------------
% 入力イメージは、logical、uint8、uint16、または、double のいずれの
% クラスもサポートしています。
%
% 例題
% ----
%       load trees
%       [X2,map2] = imread('forest.tif');
%       subplot(1,2,1), subimage(X,map)
%       subplot(1,2,2), subimage(X2,map2)
%
% 参考：IMSHOW, SUBPLOT



%   Copyright 1993-2002 The MathWorks, Inc.  
