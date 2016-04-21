% ケーススタディ番号 1 : ガラス管製造工場
%
% このケースステディでは、ガラス管工場からデータを得ています。実験とデー
% タに関して、つぎの文献で議論されています。
%
% V. Wertz, G. Bastin and M. Heet: Identification of a glass tube
% drawing bench. Proc. of the 10th IFAC Congress, Vol 10, pp 334-339
% Paper number 14.5-5-2. Munich August 1987.
%
% その工程での出力は、製造した管の厚さと直径となります。入力は、管内の空
% 気圧と製造速度となります。
%
% このチュートリアルで、速度入力から管厚出力までのモデルを求めます。
%
% まず、生データを見てみます。データを半分に分割し、ひとつをモデル推定に、
% もうひとつを結果の検証に利用します:

%   Copyright 1986-2001 The MathWorks, Inc.
