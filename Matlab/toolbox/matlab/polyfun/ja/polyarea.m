% POLYAREA   多角形の面積
% 
% POLYAREA(X,Y) は、ベクトル X と Y の頂点で指定される多角形の面積を出力
% します。X と Y が同じサイズの行列の場合は、POLYAREA は X と Y の列で
% 定義される多角形の面積を出力します。X と Y が配列の場合は、POLYAREA は
% X と Y の最初に1でない次元に多角形の面積を出力します。
%
% 多角形のエッジは交差してはいけません。交差する場合は、POLYAREA は、
% 右回りに囲んだ領域と、左回りに囲んだ領域の差の絶対値を出力します。
%
% POLYAREA(X,Y,DIM) は、次元 DIM の頂点により指定される多角形の面積を
% 出力します。
%
% 入力 X,Y のサポートクラス
%      float: double, single

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:01:41 $
