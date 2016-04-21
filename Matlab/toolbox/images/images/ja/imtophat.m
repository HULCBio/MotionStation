% IMTOPHAT  Top hat フィルタ操作
% IM2 = IMTOPHAT(IM,SE) は、グレースケール、または、バイナリ入力イメージ 
% IM に、構造化要素 SE を使って、形態学的な top hat フィルタ操作を適用し
% ます。SE は、関数 STREL で出力される構造化要素です。SE は、単一の構造
% 化要素オブジェクトで、複数の構造化要素オブジェクトを含む配列ではありま
% せん。
%
% IM2 = IMTOPHAT(IM,NHOOD) は、形態学的 top hat フィルタ操作を行います。
% ここで、NHOOD は、構造化要素のサイズと型を設定する0と1の要素のみで作成
% されている配列です。これは、IMTOPHAT(IM,STREL(NHOOD)) と等価です。
%
% クラスサポート
% -------------
% IM は、数値または logical で非スパースでなければなりません。出力
% イメージは、入力イメージと同じクラスになります。入力がバイナリイメー
% ジ(logical)の場合、構造化要素は平坦でなければなりません。
%
% 例題
% -------
% Tophat フィルタ操作は、バックグランドが暗い場合に、不均質な照度を補正す
% るために使います。つぎの例題は、rice.tif イメージから不均質なバックグラ
% ンド照度を除去するために、円盤を使って、tophat フィルタ操作を行います。
% そして、imadjust と stretchlim を使って、結果をより簡単に可視化します。
%
%   I = imread('rice.tif');
%   imshow(I), title('Original')
%   se = strel('disk',12);
%   J = imtophat(I,se);
%   figure, imshow(J), title('Step 1: Tophat filtering')
%   K = imadjust(J,stretchlim(J));
%   figure, imshow(K), title('Step 2: Contrast adjustment')
%
% 参考： IMBOTHAT, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
