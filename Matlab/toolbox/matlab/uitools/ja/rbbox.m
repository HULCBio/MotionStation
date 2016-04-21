% RBBOX  ラバーバンドボックス
%
% RBBOX は、カレントfigure内のラバーバンドボックスを初期化し、トラック
% します。これは、ボックスの初期長方形サイズを0に設定し、figureの 
% CurrentPoint にボックスを配置し、この点からのトラッキングを始めます。
%
% RBBOX(initialRect) は、[x y width heigh] を使って、ラバーバンドの初期の
% 位置とサイズを設定します。ここで、x と y は左下隅を、width と height は
% 大きさを設定します。initialRect は、カレントfigureの Units プロパティ
% により設定される単位で、figureの左下隅から測ります。ポインタの位置に
% 最も近いボックスの隅は、RBBOX がボタンアップのイベントを受け入れるまで、
% ポインタの動きに従います。
%
% RBBOX(initialRect,fixedPoint) は、固定したままのボックスの隅を設定します。
% すべての引数は、カレントfigureの Units プロパティで指定され、figure 
% ウィンドウの左下隅から測ります。fixedPoint は、2要素 [x,y]からなる
% ベクトルです。トラッキングポイントは、fixedPoint で定義された固定の隅
% から対角の関係にある隅方向に移動します。
%
% RBBOX(initialRect,fixedPoint,stepSize) は、ラバーバンドボックスが更新
% される頻度を設定します。トラッキングポイントがfigureの単位 stepSize を
% 超える場合は、RBBOX はラバーバンドボックスを再描画します。デフォルトの 
% stepSize は1です。
%
% finalRect = RBBOX(...) は、4要素 [x y width height] から構成されるベク
% トルで、x と y は ボックスの左下隅の x と y の座標で、width と height 
% はボックスの大きさです。
%
% マウスボタンは、RBBOX がコールされる場合にダウン状態になります。
% RBBOX は、WAITFORBUTTONPRESS と共に、ButtondownFcn の中または M-ファイル
% のいずれかで使うことができ、ダイナミックな挙動を制御することができます。
%
% 例題：
%
%   figure;
%   pcolor(peaks);
%   k = waitforbuttonpress;
%   point1 = get(gca,'CurrentPoint');    % ボタンダウンの検出
%   finalRect = rbbox;                   % figure単位の出力
%   point2 = get(gca,'CurrentPoint');    % ボタンアップの検出
%   point1 = point1(1,1:2);              % x と y の抽出
%   point2 = point2(1,1:2);
%   p1 = min(point1,point2);             % 位置と大きさの計算
%   offset = abs(point1-point2);         % 
%   x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
%   y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
%   hold on
%   axis manual
%   plot(x,y,'r','linewidth',5)          % ボックスの回りに選択した
%                                        % 領域の描画
%
% 参考：WAITFORBUTTONPRESS, DRAGRECT.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:44 $
%   Built-in function.
