% IMBOTHAT Bottom hat フィルタ操作
% IM2 = IMBOTHAT(IM,SE) は、グレースケール、または、バイナリ入力イメージ
% IM に、構造化要素 SE を使って、形態学的な bottom hat フィルタ操作を適
% 用します。SE は、関数 STREL で出力される構造化要素です。SE は、単一の
% 構造化要素オブジェクトで、複数の構造化要素オブジェクトを含む配列ではあ
% りません。
%
% IM2 = IMBOTHAT(IM,NHOOD) は、形態学的 bottom hat フィルタ操作を行いま
% す。ここで、NHOOD は、構造化要素のサイズと型を設定する0と1の要素のみ
% で作成されている配列です。これは、IMBOTHAT(IM,STREL(NHOOD)) と等価で
% す。
%
% クラスサポート
% -------------
% IM は、数値または logical で、非スパースでなければなりません。出力
% イメージは、入力イメージと同じクラスです。入力がバイナリ(logical)の
% 場合、構造化要素は平坦でなければなりません。
%
% 例題
% -------
% Tophat と bottom-hat フィルタ操作は、共に、イメージ内のコントラストを
% 強調するものです。手法は、オリジナルイメージを tophat でのフィルタリン
% グを行ったイメージに加え、その後、bottom-hat でのフィルタリングを行った
% イメージを引きます。
%
%       I = imread('pout.tif');
%       se = strel('disk',3);
%       J = imsubtract(imadd(I,imtophat(I,se)), imbothat(I,se));
%       imshow(I), title('Original')
%       figure, imshow(J), title('Contrast filtered')
%
% 参考：IMTOPHAT, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
