% RSIMGETRTP   モデルからパラメータ構造体を取得
% VAR = RSIMGETRTP('MODELNAME')
%
% RSIMGETRTPは、MATLABワークスペースから新規のパラメータをもつSimulinkブ
% ロック線図'modelname'を更新します。そして、RSIMGETRTPは、Rapid Simul-
% ation (RSim)ターゲットとして生成されたコードにおいて、完全なパラメータ
% 置換を意味するモデルのチェックサムを含む、新たな"rtP"構造体を出力しま
% す。RSimと共に利用するためには、変数をRSimが実行時に読み込む.matファイ
% ルに保存します。

%   Copyright 1994-2001 The MathWorks, Inc.
