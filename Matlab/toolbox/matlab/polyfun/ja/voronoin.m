%VORONOIN  N-次元 Voronoi線図
% [V,C] = VORONOIN(X) は、X のVoronoi線図のVoronoi頂点 V と、Voronoi
% セル C を出力します。V は、n次元空間での numv 個のVoronoi頂点からなる
% numv 行 n 列の配列です。各行は、Voronoi頂点に対応します。C は、各要素
% が対応するVoronoiセルの頂点のVのインデックスである、ベクトルセル配列
% です。X は、m行n列配列で、m個のn次元の点を表わします。
%
% VORONOIN は、Qhull を使用します。
% 
%   [V,C] = VORONOIN(X,OPTIONS) は、Qhull のオプションとして
% 使用されるように、文字列 OPTIONS のセル配列を指定します。
% デフォルトのオプションは、
%      2D および 3D 入力に対して、{'Qbb'}
%      4D および より高次元の入力に対して、{'Qbb','Qx'}
% OPTIONS が [] の場合、デフォルトのオプションが使用されます。
% OPTIONS が {''} の場合、オプションは使用されません。デフォルトのもの
% も使用されません。
% Qhull オプションについての詳細は、http://www.qhull.org. を
% 参照してください。
%   
% 例題 1:  
%      X = [0.5 0; 0 0.5; -0.5 -0.5; -0.2 -0.1; -0.1 0.1; 0.1 -0.1; 0.1 0.1]
%     [V,C] = voronoin(X) 
% の場合、
% C の内容を見るために、つぎのコマンドを使います。  
%      for i = 1:length(C), disp(C{i}), end
%
% 特に、5番目のVoronoiセルは、4点 V(10,:), V(5,:), V(6,:), V(8,:) から
% 構成されています。
% 
% 
% 2次元の場合、C の中の頂点は隣り合った順にリストされ、すなわち、それら
% を結合することにより、閉多角形(voronoi線図)が作成されます。3次元、
% またはそれ以上の次元では、頂点は昇順にリストされます。voronoi線図の
% 特定のセルを作成するには、CONVHULLN を使用して、そのセルのファセットを
% 計算、つまり5番目のVoronoiセルを生成します。
% 
%      X = V(C{5},:); 
%      K = convhulln(X); 
%
% 例題 2:
%      X = [-1 -1; 1 -1; 1 1; -1 1];
%      [V,C] = voronoin(X)
% は、エラーとなりますが、デフォルトオプションに'Qz' を追加すると役立つことを
% 示します。
%      [V,C] = voronoin(X,{'Qbb','Qz'})
%
% 参考 VORONOI, QHULL, DELAUNAYN, CONVHULLN, DELAUNAY, CONVHULL. 

%   Copyright 1984-2003 The MathWorks, Inc. 
