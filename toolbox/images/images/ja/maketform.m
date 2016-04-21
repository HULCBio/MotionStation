% MAKETFORM は、幾何学変換構造体を作成します。T = MAKETFORM(TRANSFORM-
% TYPE,...) は、TFORMFWD, TFORMINV, FLIPTFORM, IMTRANSFORM, TFORMARRAY 
% と共に使う多次元幾何学的変換構造体('TFORM struct') を出力します。
% TRANSFORMTYPE は、'affine', 'projective', 'custom', 'box', 'composi-
% te'のいずれかを指定します。.
%
% T = MAKETFORM('affine',A) は、N-次元のアフィン変換に対する TFORM 構造
% 体を作成します。A は、正則な実数 (N+1) 行 (N+1) 列、または、(N+1) 行 N 
% 列の行列です。A が、(N+1) 行 (N+1) 列の場合、A の最後の列は、[zeros(N,
% 1); 1]とします。その他の場合、A は、その最後の列が、[zeros(N,1); 1] に
% なるように、自動的に拡大されます。A は、TFORMFWD(U,T) のようなフォワー
% ド変換を定義し、U は、1 行 N 列のベクトルで、X = U * A(1:N,1:N) + A(N+1,
% 1:N) となる1 行 N 列のベクトル X を出力します。T は、フォワード変換と逆
% 変換を両方もっています。
%
% T = MAKETFORM('projective',A) は、N-次元の射影変換に対する TFORM を作成
% します。A は、正則な実数 (N+1) 行 (N+1) 列の行列です。A(N+1,N+1) にゼロ
% を設定することはできません。A は、TFORMFWD(U,T) のようなフォワード変換
% を定義できます。ここで、U は、1 行 N 列のベクトルで、X = W(1:N)/W(N+1) 
% となる1 行 N 列のベクトル X を出力します。ここで、W = [U 1] * A です。
% T は、フォワード変換と逆変換を両方もっています。
%   
% T = MAKETFORM('affine',U,X) は、U の各行を X の対応する行にマッピングす
% る2次元のアフィン変換に対する TFORM 構造体を作成します。U と X は、それ
% ぞれ 3 行 2 列で、入力と出力の三角形の頂点を設定します。頂点は、直線上
% に存在することはできません。
%
% T = MAKETFORM('projective',U,X) は、U の各行を X の対応する行にマッピン
% グする2次元射影変換に対する TFORM 構造体を作成します。U と X は、それぞ
% れ 4 行 2 列で、入力と出力の四辺形の頂点を設定します。頂点は、直線上に
% 存在することはできません。
%
% T = MAKETFORM('custom',NDIMS_IN,NDIMS_OUT,FORWARD_FCN,INVERSE_FCN,....
% TDATA) は、ユーザが設定した関数ハンドルとパラメータをベースにカスタム
% の TFORM 構造体を作成します。NDIMS_IN と NDIMS_OUT は、入力と出力の次
% 元数です。FORWARD_FCN と INVERSE_FCN は、フォワード関数と逆関数への関
% 数ハンドルです。これらの関数は、シンタックス X = FORWARD_FCN(U,T) と 
% U = INVERSE_FCN(X,T) をサポートしています。ここで、U は、P 行 NDIMS_IN 
% 列の行列で、その行は、変換の入力空間の中の点で、X は、P 行 NDIMS_OUT 
% 列の行列で、その行は、変換の出力空間の中の点です。TDATA は、任意の MAT-
% LAB 配列で、カスタム変換のパラメータを保存するために、一般には、使われ
% ます。T の "tdata"フィールドを通して、FORWARD_FCN と INVERSE_FNC にアク
% セスすることができます。FORWARD_FCN、または、INVERSE_FCN のどちらかが、
% 空の場合、少なくとも INVERSE_FCN は、TFORMARRAY、または、IMTRANSFORM 
% のどちらかと共に、T を使って定義する必要があります。
%
% T = MAKETFORM('composite',T1,T2,...,TL)、または、T = MAKETFORM('compo-
% site', [T1 T2 ... TL]) は、T1, T2, ..., TL のフォワード関数や逆関数の関
% 数的な組み合わせになるフォワード関数と逆関数の TFORM を作成します。たと
% えば、L = 3 の場合、TFORMFWD(U,T) は、TFORMFWD(TFORMFWD(TFORMFWD(U,T3),
% T2),T1) と同じになります。T1 から TL までの要素は、入力次元と出力次元の
% 数に関して整合性を保っている必要があります。T は、要素変換のすべてが、
% フォワード変換関数を定義している場合のみ、定義されたフォワード変換関数
% をもっています。T は、要素変換のすべてが、逆変換関数を定義している場合
% のみ、定義された逆変換関数をもっています。
%
% T = MAKETFORM('box',TSIZE,LOW,HIGH)、または、T = MAKETFORM('box',INBOU-
% NDS, OUTBOUNDS) は、N-次元のアフィン TFORM 構造体 T を作成します。TSIZE
% は、正の整数の N 要素ベクトルで、LOW と HIGH も、N 要素をもつベクトルで
% す。変換は、外側の頂点 ONES(1,N) と TSIZE、または、 別の頂点 INBOUNDS
% (1,:) と INBOUND(2,:) のいずれかで設定される入力"ボックス"を、対するも
% のの頂点 LOW と HIGH、または、OUTBOUNDS(1,:) と OUTBOUNDS(2,:) のいずれ
% かで定義された出力ボックスにマッピングします。
%
% LOW(K) と HIGH(K) は、TSIZE(K) が1でない限り、お互いに異なります。1の場
% 合、K-番目の次元に関するアフィンスケールファクタは、1.0 と仮定していま
% す。同様に、INBOUNDS(1,K) と INBOUNDS(2,K) は、OUTBOUNDS(1,K) と OUTBO-
% UNDS(1,K) が同じでない限り、異なります。また、その逆の関係も成り立ちま
% す。'box' TFORM は、イメージ、または、配列の行と列のサブスクリプトをあ
% る"world"座標系に配置するときに、通常、使われます。
%
% 例題
% -------
% アフィン変換を作成し、適用します。
%
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       tformfwd([10 20],T)
%       I = imread('cameraman.tif');
%       I2 = imtransform(I,T);
%       imshow(I2)
%
% 参考： FLIPTFORM, IMTRANSFORM, TFORMARRAY, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.
