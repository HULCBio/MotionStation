% NOISECNV は、ノイズチャンネルを測定チャンネルに変換します。
% 
%   Modc = NOISECNV(Model,Noise)
%
% Model は、任意の IDMODEL オブジェクト(IDGREY, IDARX, IDPOLY, IDSS)で
% す。Modc は、Model と同じクラスのモデルで、測定入力とノイズ源を共に測定
% 入力として取り扱います。
%
% 2つの場合があります。Noise = 'N'(正規化) の場合、まず、独立で単位分
% 散をもつようにノイズ源を正規化します。また、Noise = 'I' (イノベーション)
% の場合、正規化はなされず、ノイズ源はイノベーション過程として残ります。
%
% より詳しく見てみましょう。Model をつぎの型で表現します。
% 
%   y = G u + H e;  
% 
% または、状態空間型
% 
%   x(t+1) = Ax(t) + Bu(t) + Ke(t)
%   y(t) = Cx(t) + Du(t) + e(t)
% 
% ここでは、モデルのイノベーションが存在しています。e の分散は、Model.No-
% iseVariance = L*L' です。
%   
% Noise = 'Innovations' を利用すると、Modc はつぎのモデルを表現します。
% (デフォルトでは、Noise = 'Innovations'です。)
% 
%   y = [G H] [u;e] 
% 
% または、状態空間型
% 
%   x(t+1) = Ax(t) + [B K][u(t);e(t)]
%   y(t) = Cx(t) + [D I][u(t);e(t)];
% 
% これは、Nu+Ny の入力チャンネルをもっています。入力チャンネル e は、
% InputNames 'e@yk' で与えられます。ここで、'yk' は、k 番目の OutputNa-
% me で、k 番目の出力チャンネルで"e に影響する"ものを意味します。この場
% 合、Modcに対してTFDATA , ZPKDATA等を利用することで、伝達関数GとHを抽出
% します。
%
% Noise = 'Normalize' を利用すると、まず、正規化 e = Lv がなされます。v 
% は独立なチャンネルで、単位分散をもつ白色ノイズです。これは、共分散行列
% L*L' をもつ白色ノイズになります。
% 
% Modc は、モデル
% 
%   y = [G HL][u;v]
% 
% または、状態空間型
% 
% x(t+1) = Ax(t) + [B KL][u(t);v(t)]
% y(t) = Cx(t) +[D L][u(t);v(t)]
% 
% となります。ここで、Nu+Ny 個の入力チャンネルをもっています。入力チャン
% ネル v は、InputNames'v@yk' で与えられます。'yk' は、k 番目のチャンネ
% ルの OutputName で、k 番目の出力チャンネルで"v に影響するもの"を意味し
% ます。Modcに対してTFDATA , ZPKDATA等を利用することで、伝達関数GとHを抽
% 出します。すなわち、STEP を Modc に適用した場合、ノイズレベルが反映さ
% れます。
%
% G, H, ノイズ分散の中の不確かさ情報は、Model から Modc に適切に変換され
% ます。



%   Copyright 1986-2001 The MathWorks, Inc.
