% WATERSHED 　イメージの watershed 領域の検出
%
% L = WATERSHED(A) は、入力行列 A の watershed 領域を識別するラベル行列
% を計算します。A は、任意の次元をもつことができます。L の要素は、0より
% も大きい整数です。ラベル0の要素は、ユニークな watershed 領域に属して
% いません。これらは、"watershed"ピクセルと呼ばれます。ラベル1の要素は、
% 最初の watershed 領域に属し、ラベル2の要素は、2 番目の watershed 領域
% に、等々、属します。
%
% デフォルトで、WATERSHED は、2次元入力で8連結、3次元入力で26連結、高次元で、
% CONNDEF(NDIMS(A),'maximal') を使います。
%
% L = WATERSHED(A,CONN) は、指定した連結を使って、watershed 変換を計算し
% ます。CONN は、つぎのスカラ値のいずれかを設定できます。
%
%       4     2次元4連結近傍
%       8     2次元8連結近傍
%       6     3次元6連結近傍
%       18    3次元18連結近傍
%       26    3次元26連結近傍
%
% 連結度は、CONN に対して、0と1を要素とする3 x 3 x 3 x ... x 3 の行列を
% 使って、任意の次元に対して、より一般的に定義できます。値1は、CONN の中
% 心要素に関連して近傍の位置を設定します。CONN は、中心要素に対して、対
% 称である必要があります。
%
% クラスサポート
% -------------
% A は、任意の次元の数値または logical で、非スパースでなければなりま
% せん。出力配列 L は、 double です。
%
% 例題(2-D)
% -------------
%   1. 2つの円のオブジェクトが重なったバイナリイメージを作成
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(2*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, imshow(bw,'n'), title('bw')
%
%   2. バイナリイメージの補数の距離変換を計算
%
%       D = bwdist(~bw);
%       figure, imshow(D,[],'n'), title('Distance transform of ~bw')
%
%   3. 距離変換の補数を取り、ピクセルが、-Inf で存在するオブジェクトに
%      含ませないようにします。
%
%       D = -D;
%       D(~bw) = -Inf;
%
%   4. Watershed変換を計算し、RGB イメージとして結果のラベル付きの行列を
%      表示します。
%
%       L = watershed(D); 
%       rgb = label2rgb(L,'jet',[.5 .5 .5]);
%       figure, imshow(rgb,'n'), title('Watershed transform of D')
%
% 例題(3-D)
% -------------
%   1.2つの重なり合った球を含む3次元イメージを作成します。
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(3*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y,z] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2 + ...
%           (z-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2 + ...
%           (z-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, isosurface(x,y,z,bw,0.5), axis equal, title('BW')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   2. 距離変換を計算
%
%       D = bwdist(~bw);
%       figure, isosurface(x,y,z,D,radius/2), axis equal
%       title('Isosurface of distance transform')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   3. 距離変換の補数を取り、オブジェクトでないピクセルを -Inf に設定し、
%      watershed 変換を計算します。
%
%       D = -D;
%       D(~bw) = -Inf;
%       L = watershed(D);
%       figure, isosurface(x,y,z,L==2,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%       figure, isosurface(x,y,z,L==3,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
% 参考： BWLABEL, BWLABELN, REGIONPROPS.



%   Copyright 1993-2002 The MathWorks, Inc.
