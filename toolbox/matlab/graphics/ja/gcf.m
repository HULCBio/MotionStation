% GCF   カレントのfigureのハンドル番号の取得
% 
% H = GCF は、カレントのfigureのハンドル番号を出力します。カレントの
% figureは、PLOT、TITLE、SURF のようなグラフィックスコマンドが描画する
% ウィンドウです。
%
% カレントのfigureのハンドル番号は、ルートのプロパティ CurrentFigure に
% 格納され、GET を使って参照したり、FIGURE や SET を使って修正できます。
%
% figure内に含まれるuimenuとuicontrolをクリックするか、figureの描画領域
% をクリックすると、figureがカレントになります。
%
% カレントのfigureは、スクリーン上で一番前面にある必要はありません。
%
% GCF は、コールバック中にはコールバックを実行しているfigureのハンドル番
% 号を得ることはできません。この目的のためには、GCBO を使ってください。
% 
% 参考：FIGURE, CLOSE, CLF, GCA, GCBO, GCO, GCBF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:46 $
