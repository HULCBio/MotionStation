% TRIPLOT  2次元三角形のプロット
%
% TRIPLOT(TRI,X,Y) は、M 行3列の行列 TRI の中に定義されてる三角形を表示
% します。TRI の行は、1つの三角形を定義するインデックスを X,Yに含んだもの
% です。デフォルトのラインカラーはブルーです。 
%
% TRIPLOT(TRI,X,Y,COLOR) は、文字列 COLOR を使って、ラインカラーを設定
% します。
%
% H = TRIPLOT(...) は、表示される三角形のハンドルのベクトルを戻します。
%
% TRIPLOT(...,'param','value','param','value'...) は、プロットを作成する
% ときに使用する付加的なラインのパラメータ名と値を設定します。
%
% 例題：
%
%   rand('state',0);
%   x = rand(1,10);
%   y = rand(1,10);
%   tri = delaunay(x,y);
%   triplot(tri,x,y)
%
% 参考：TRISURF, TRIMESH, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
