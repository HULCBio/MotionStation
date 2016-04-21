% TRISURF   三角形サーフェスプロット
% 
% TRISURF(TRI,X,Y,Z,C) は、M行3列の面の行列 TRI で定義される三角形を
% サーフェスとして表示します。TRI の行は、頂点 X,Y,Z を含むベクトルの
% インデックスを含んでいて、1つの三角形の面を定義します。カラーは、
% ベクトル C によって定義されます。
%
% TRISURF(TRI,X,Y,Z) は、C = Z を使用するので、カラーはサーフェスの高さに
% 比例します。
%
% H = TRISURF(...) は、patchオブジェクトのハンドル番号を出力します。
%
% TRISURF(...,'param','value','param','value'...) は、patchオブジェクトの
% 作成時に使用する、パッチのパラメータ名と値の組合わせを使うことができます。
%
% 例題：
%
%   [x,y]=meshgrid(1:15,1:15);
%   tri = delaunay(x,y);
%   z = peaks(15);
%   trisurf(tri,x,y,z)
%
% 参考：PATCH, TRIMESH, DELAUNAY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:31 $
