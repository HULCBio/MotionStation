% AXES   任意の位置にaxesを作成
% 
% AXES('position'、RECT) は、指定した位置にaxesを表示し、そのハンドル
% 番号を出力します。
% RECT = [left、bottom、width、height] は、位置と大きさを指定します。
% これは、ボックスの片側の位置をFigureウィンドウの左下隅に対して、正規化
% された単位で設定します。(0,0)は左下隅で、(1.0,1.0)は右上隅です。
%
% AXES 自身では、デフォルトのフルウィンドウのaxesを作成し、そのハンドル
% 番号を出力します。
%
% AXES(H) は、ハンドル番号 H の軸をカレントの軸にします。
%
% axesオブジェクトのプロパティと、そのカレントの値を見るためには、GET(H)
% を実行してください。axesオブジェクトのプロパティとそれらが取り得るプロ
% パティ値を見るためには、SET(H) を実行してください。
%
% 参考：SUBPLOT, AXIS, FIGURE, GCA, CLA.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:31 $
%   Built-in function.
