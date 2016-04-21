% PRINTPREPARE 　印刷用のfigureまたはSimulinkモデルを修正する方法
%
% スクリーン上の情報と印刷物の情報は、必ずしも同じものではありません。
% スクリーンに暗い背景を用いると、トナーを大量に使用することになります。
% 明るい色のラインやテキストは、標準的なグレースケールプリンタでは
% 非常に見辛くなります。PRINT への引数やfigureのプロパティの状態の中
% には、出力用のfigureまたはモデルをレンダリングをして、どのような変更が
% 必要かを決定するものがあります。
% 
% 例：
%   pj = PRINTPREPARE( pj, h ); %　PrintJob pj と figure/モデル h を変更
%
% 参考：PRINT, PRINTOPT, PRINTRESTORE.


%   Copyright 1984-2002 The MathWorks, Inc. 
