% JOINICON   複素数の "Join" または "Split" ブロックに対するアイコンを生成
% 
% [X,Y] = JOINICON(ORIENT,POLAR,SPLIT) は、complex join(または、方向が
% 逆である split) ブロックを示すためにマスクされたブロック内部のプロット
% コマンド内で使われるベクトルを出力します。
%
% ORIENT は、ブロックの方向を示す文字列
%       up    ==> 下から上方向
%	    down  ==> 上から下方向
%       left  ==> 右から左方向
%       right ==> 左から右方向
%
% POLAR は、極座標表示法(大きさと角度)を使うか否かを示します。
% SPLIT は、(Join に対応する)Split を表示するか否かを設定します。


%    T. Krauss, 12-9-94
%    Revised: D. Orofino
%    Copyright 1995-2002 The MathWorks, Inc.
%    $Revision: 1.6.6.1 $  $Date: 2003/07/22 21:03:49 $
