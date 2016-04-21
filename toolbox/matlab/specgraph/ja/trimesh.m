% TRIMESH   三角形メッシュプロット
% 
% TRIMESH(TRI,X,Y,Z,C) は、M行3列の面の行列 TRI で定義される三角形を、
% メッシュとして表示します。TRI の行は、頂点 X,Y,Z を含むベクトルのイン
% デックスを含んでいて、1つの三角形の面を定義します。エッジの色は、
% ベクトル C によって定義されます。
%
% TRIMESH(TRI,X,Y,Z) は、C = Z を使用するので、色はサーフェスの高さに
% 比例します。
%
% TRIMESH(TRI,X,Y) は、2次元プロット内に三角形を表示します。
%
% H = TRIMESH(...) は、パッチオブジェクトのハンドル番号を出力します。
%
% TRIMESH(...,'param','value','param','value'...) は、パッチオブジェクトの
% 作成時に使用する、パッチのパラメータ名と値の組合わせを使うことができます。
% 
% 例題：
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trimesh(tri,x,y,z)
%
% 参考：PATCH, TRISURF, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:30 $
