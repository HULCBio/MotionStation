% IMADJUST   イメージの強度値、または、カラーマップを調整
%   J = IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA) は、強度
%   イメージ I の LOW_IN から HIGH_IN までの範囲の値を、LOW_OUT から 
%   HIGH_OUT の範囲にマッピングすることにより J を作成します。LOW_IN 
%   より小さい値は LOW_OUT に、HIGH_IN よりも大きい値は HIGH_OUT に
%   マッピングします。[LOW_IN HIGH_IN] や [LOW_OUT HIGH_OUT] が空行列
%   の場合、デフォルトの[0 1]を使います。
%
%   NEWMAP = IMADJUST(MAP,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA)
%   は、インデックス付きイメージに関連したカラーマップを変換します。
% 
%   LOW_IN、HIGH_IN、LOW_OUT、HIGH_OUT、GAMMA がスカラの場合、同一の
%   マッピングが、赤、緑、青の成分に適用されます。各カラー成分毎に、ユ
%   ニークなマッピングは、つぎの場合に有効です。
%   
%   LOW_IN and HIGH_IN が、1行3列のベクトル、または、LOW_OUT と 
%   HIGH_OUT が1行3列のベクトル、または、GAMMA が1行3列のベクトルのい
%   ずれかの場合、再スケーリングされたカラーマップ、NEWMAP は、MAP と
%   同じサイズです。
%
%   RGB2 = IMADJUST(RGB1,...) は、RGB イメージ RGB1 の各イメージ平面
%   (赤、緑、青)を調整します。カラーマップの調整を行って、各平面にユ
%   ニークなマッピングを適用できます。
%
%   HIGH_OUT < LOW_OUT の場合、出力イメージは逆になることに注意してく
%   ださい。すなわち、写真のような変換のようになります。
%
% 　関数 STRETCHLIM は、IMADJUST と共に使い、コントラストの引き伸ばしを
%   自動的に計算します。
%
% クラスサポート
% -------------
%   入力イメージ(カラーマップではありません)を含む構文に対して、入力イ
%   メージは、uint8、uint16、または、double のいずれのクラスもサポート
%   しています。出力イメージは、入力イメージと同じクラスです。カラー
%   マップを含む構文に関しては、入力と出力のカラーマップは、クラス 
%   double です。
%
% 例題
% ----
%       I = imread('pout.tif');
%       J = imadjust(I,[0.3 0.7],[]);
%       imshow(I), figure, imshow(J)
%
%       RGB1 = imread('flowers.tif');
%       RGB2 = imadjust(RGB1,[.2 .3 0; .6 .7 1],[]);
%       imshow(RGB1), figure, imshow(RGB2)
%
% 参考 : BRIGHTEN, HISTEQ, STRETCHLIM



%   Copyright 1993-2002 The MathWorks, Inc.  
