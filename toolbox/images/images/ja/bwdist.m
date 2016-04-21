% BWDIST 距離変換
% D = BWDIST(BW) は、バイナリイメージ BW のユークリッド距離変換を計算し
% ます。BW の中の各ピクセルに対して、距離変換は、BW の中のピクセルとそ
% の最近傍のゼロでないピクセルの間の距離である数字を割り当てます。BWDIST
% は、デフォルトで、ユークリット距離計量を使います。BW は、ある次元を持
% たせることができます。D は、BW と同じサイズです
%
% [D,L] = BWDIST(BW) は、最近傍変換を計算し、ラベル行列 L として、それを
% 出力します。L は BW や D と同じサイズです。L の各要素は、BW の最近傍の
% ゼロでないピクセルの線形インデックスを含んでいます。
%
% [D,L] = BWDIST(BW,METHOD) は、METHOD の値に依存して、変更した距離変換を
% 計算させます。METHOD は、'cityblock', 'chessboard', 'quasi-euclidean', 
% 'euclidean' のいずれかを設定することができます。METHOD は、指定しない場
% 合、デフォルトの'euclidean'を使います。METHOD は、短縮することもできます。
%
% 異なる方法は、異なる距離計量に対応します。2次元で、(x1,y1) と (x2,y2)
% の cityblock 距離は、abs(x1-x2) + abs(y1-y2) となります。chessboard 距
% 離は、max(abs(x1-x2) と abs(y1-y2)) です。Quasi-Euclidean 距離は、つぎ
% のようになります。
%
%   abs(x1-x2) > abs(y1-y2) の場合、abs(x1-x2) + (sqrt(2)-1)*abs(y1-y2)
%   その他の場合、　　　　　　　    (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2)
%
% Euclidean 距離は、sqrt((x1-x2)^2 + (y1-y2)^2) です。
%
% 注意
% ----
% BWDIST は、真の Euclidean 距離変換を計算するために高速のアルゴリズムを
% 使っています。特に、2 次元の場合は、高速です。他の方法は、教育的な考え
% だけで、用意されています。しかし、異なる距離変換は、多次元入力イメージ
% に対して、しばしば、かなりの高速になることがあります。特に、非ゼロ要素
% が多く存在する場合です。
%
% クラスサポート
% -------------
% BW は、数値配列または logical です。また非スパースでなければなりませ
% ん。D と L は、BW と同じサイズの double 行列です。
%
% 例題
% --------
% つぎに、ユークリッド距離変換の簡単な例題を示します。
%
%       bw = zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,L] = bwdist(bw)
%
% この例題は、2次元の距離変換について、4つの方法を比べたものです。
%
%       bw = zeros(200,200); bw(50,50) = 1; bw(50,150) = 1;
%       bw(150,100) = 1;
%       D1 = bwdist(bw,'euclidean');
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), subimage(mat2gray(D1)), title('Euclidean')
%       hold on, imcontour(D1)
%       subplot(2,2,2), subimage(mat2gray(D2)), title('City block')
%       hold on, imcontour(D2)
%       subplot(2,2,3), subimage(mat2gray(D3)), title('Chessboard')
%       hold on, imcontour(D3)
%       subplot(2,2,4), subimage(mat2gray(D4)), title('Quasi-Euclidean')
%       hold on, imcontour(D4)
%
% つぎの例題 は、中心に一つの非ゼロのピクセルを含む3次元の距離変換に対
% する等値面プロットを比べたものです。
%
%       bw = zeros(50,50,50); bw(25,25,25) = 1;
%       D1 = bwdist(bw);
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), isosurface(D1,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Euclidean')
%       subplot(2,2,2), isosurface(D2,15), axis equal, view(3)
%       camlight, lighting gouraud, title('City block')
%       subplot(2,2,3), isosurface(D3,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Chessboard')
%       subplot(2,2,4), isosurface(D4,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Quasi-Euclidean')
%
% 参考：WATERSHED.



%   Copyright 1993-2002 The MathWorks, Inc.
