% ALIGN  uicontrols と axes の整列
% 
% ALIGN(HandleList,HorizontalAlignment,VerticalAlignment) は、ハンドル
% リスト内のオブジェクトを整列します。左辺の引数を付加することは、出力
% されるオブジェクトの更新された位置を出力することになり、一方、figure上
% のオブジェクトの位置には変更がありません。整列ツールのコールは、
% 
%   Positions=ALIGN(CurPositions,HorizontalAlignment,VerticalAlignment)
% 
% を使い、初期位置の行列から更新された位置行列を出力します。
%
% HorizontalAlignment に設定できる値は、
%     None, Left, Center, Right, Distribute, Fixed
%
% VerticalAlignment に設定できる値は、
%     None, Top, Middle, Bottom, Distribute, Fixed
%
% すべての整列オプションは、オブジェクトを囲んだボックスの中のオブジェクト
% を整列します。Distribute と Fixed は、オブジェクトを囲んだボックスの
% 左下にオブジェクトを整列します。Distribute は、オブジェクトを等間隔に
% 配置しますが、Fixed は、オブジェクト間の(ポイント単位の)距離を固定した
% まま配置します。
%
% Fixed が HorizontalAlignment または VerticalAlignment に対して使用
% される場合は、距離は追加引数に従って変更されます。
%   
% ALIGN(HandleList,'Fixed',Distance,VerticalAlignment)
% ALIGN(HandleList,HorizontalAlignment,'Fixed',Distance)
% ALIGN(HandleList,'Fixed',HorizontalDistance,'Fixed',VerticalDistance)


%   Copyright 1984-2002 The MathWorks, Inc.
