% SUBAXES   軸をタイル状に作成
% 
% [SubAxes,OtherAxes,NumDeleted] = SUBAXES(P,M,Position,FIG,Offset) は、
% FIG ウインドゥの正規化表現で指定された Position を小さな軸の P 行 M 列
% の行列に分割し、それぞれの軸ハンドル番号を一つのベクトルにまとめて出力
% します。軸は、列方向に順序付けられます。OtherAxes は、figureの中の
% 他の軸のベクトルで、NumDeleted は、SUBAXES で削除された軸の番号です。
%
% オプションの引数 Position と FIG のデフォルトは、それぞれ、get(FIG,
% 'DefaultAxesPosition') と newfig です。Offset は、挿入された軸の Pos-
% ition で指定された外側エッジからの割合です。デフォルトでは、Offset は 
% [0.01 0.01] です。最初の要素は水平方向のオフセットで、2番目の要素は垂
% 直方向のオフセットです。p = 1 の場合、Offset(2) = 0 になります。m = 1 
% の場合、Offset(1) = 0 になります。それで、subaxes(1,1) は、軸が一つで
% あるとして考えた場合と同じ位置に軸を与えます。
%
% サブ軸の組が同じ次元の同じ位置に存在する場合、SUBAXES は、これらの軸の
% ハンドルを出力します。この関数は、古い軸を削除せず、新しい軸も作成しま
% せん。
%
% 一方、SUBAXES は、Position と交差する軸を削除しますが、Position で厳密
% に一致する(単)軸は削除しません。
%
% 注意：
% すべての軸の単位は、正規化されていると仮定します。
% Box プロパティが on になっている軸を作成します。
% X/YTickLabelMode に関する知識を習得してください。


%       Author(s): A. Potvin, 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:26 $
