% CONTOURS   長方形でないサーフェスに対するコンタープロット
% 
% CONTOURS は、実際にコンタープロットを描画するために、CONTOUR, CONTOUR3,
% CONTOURF で使用するコンター行列 C を計算します。
% CONTOURS(...) は、CONTOURS(X,Y,Z,...) では(SURF と同様に)パラメトリック
% サーフェスを指定できること以外は、CONTOURC と同じです。
% C = CONTOURS(Z) は、行列 Z の値を平面からの高さとして、行列 Z に対する
% コンター行列を計算します。
% C = CONTOURS(X,Y,Z) は、X と Y がベクトルのとき、Z に対するX軸とY軸の
% 範囲を設定します。X と Y は、Z と同じサイズの行列で、SURF のように
% サーフェスを指定します。
% CONTOURS(Z,N) と CONTOURS(X,Y,Z,N) は、自動的に選択されたデフォルト値
% を変更して、N レベルのコンターラインを計算します。
% CONTOURS(Z,V) と CONTOURS(X,Y,Z,V) は、ベクトル V で指定された値に
% コンターラインをもつ、LENGTH(V) レベルのコンターラインを計算します。
% 
% コンター行列 C は、コンターラインを指定する2行の行列です。連続する描画
% セグメントは、コンター値、(x,y) の組の個数、(x,y) 自身を含んでいます。
% セグメントは、つぎのように追加されます。
% 
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
% 
% 参考：CONTOUR, CONTOUR3, CONTOURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:49 $
