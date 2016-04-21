% HOLD   カレントのグラフのホールド
% 
% HOLD ON は、カレントのプロットと、すべてのaxesのプロパティを保持する
% ので、続くグラフィックコマンドは既存のグラフに追加されます。
% HOLD OFF は、新たなプロットを描く前に、PLOT コマンドが前に描画した
% プロットを消去することでデフォルトのモードに戻り、すべてのaxesのプロ
% パティをリセットします。
% HOLD 自身では、保持状態を切り替えます。
% HOLD は、軸の autoranging プロパティには影響を与えません。
%
%
% HOLD ALL は、続くプロットコマンドがカラーやラインスタイルをリセット
% しないように、プロットとカレントのカラーやラインスタイルを保持します。
%
% HOLD(AX,...) は、Axes オブジェクト AX にコマンドを適用します。
%
% アルゴリズムの注意：
% HOLD ON は、カレントのfigureとaxesの NextPlot プロパティ を "add"に設定
% します。
% HOLD OFF は、カレントのaxesの NextPlot プロパティを "replace" に設定
% します。
%
% 参考：ISHOLD, NEWPLOT, FIGURE, AXES.


%   Copyright 1984-2002 The MathWorks, Inc. 
