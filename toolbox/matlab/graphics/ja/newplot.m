% NEWPLOT は、NextPlot プロパティのための M-ファイルです。
% 
% NEWPLOT は、NextPlot に従ってグラフィックス用にfigure、axesを用意
% します。
% 
% H = NEWPLOT は、用意したaxesのハンドルを出力します。
% H = NEWPLOT(HSAVE) は、axesを用意して出力しますが、HSAVE に表れる
% オブジェクトのハンドルを削除しません。HSAVE が指定されている場合は、
% HSAVE を含むfigureとaxesがカレントのfigureのカレントaxesの代わりに用意
% されます。HSAVE が空の場合、NEWPLOT は、入力なしでコールされたように
% 動作します。
% 
% NEWPLOT は、低水準のオブジェクト作成コマンドのみを使って、グラフを描画
% するグラフィック M-ファイル関数の初めに設定する標準のプリアンブルコマンド
% です。NEWPLOT は、"適切な操作"を行います。言い換えれば、オブジェクトの
% NextPlot プロパティの設定を基に、プロット内にどのaxesやfigureを描画する
% かを決定し、適切なaxesのハンドルを出力します。
%
% 適切な操作とは、
%
% まず、グラフィックスに対するfigureの用意です。figureの NextPlot が
% 'replace' の場合は、CLF RESET を使ってカレントfigureをクリアし、リセット
% します。または、NextPlot が 'replacechildren' の場合は、CLF を使って
% カレントfigureをクリアします。または、NextPlot が'add' の場合は、カレント
% figureをそのまま使用し、figureが存在しない場合は、figureを作成します。
% figureが用意されたとき、その NextPlot を 'add' に設定し、そのfigure内に
% axesを準備します。
% 
% NextPlot が 'replace' の場合は、CLA RESET を使ってカレントのaxesをクリア、
% リセットし、NextPlot が 'replacechildren' の場合は、CLA を使ってカレントの
% axesをクリアし、NextPlot が 'add' の場合は、カレントaxesをそのまま再利用し、
% axesが存在しない場合は、axesを作成します。
%
% 参考：HOLD, ISHOLD, FIGURE, AXES, CLA, CLF.


%   Copyright 1984-2002 The MathWorks, Inc. 
