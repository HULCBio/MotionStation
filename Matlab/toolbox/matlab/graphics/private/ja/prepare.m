% PREPARE   印刷用にFigureまたはSimulinkモデルを修正
% スクリーン上と用紙上の出力が常に同じことが望ましいわけではありません。スクリー
% ンの上の暗いバックグランドは、用紙ではトナーを浪費します。明るい色のラインやテ
% キストは、標準のグレイスケールプリンタ上では非常に見にくくなります。PRINTへの
% 引数といくつかのFigureプロパティの状態は、出力用にFigureやモデルを描画するとき
% に必要な変更を指定します。
%
% 例題:
% 
%    pj = PREPARE( pj、h ); %PrintJob pjとFigure/モデルhを修正
%
% 参考：PRINT, PRINTOPT, RESTORE, PREPAREHG, PREPAREUI.

%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:49 $
%   Copyright 1984-2002 The MathWorks, Inc. 
