% CPSELECT コントロールポイント選択ツール
% CPSELECT は、2つの関連したイメージからコントロールポイントを選択できる
% グラフィカルユーザインタフェースです。
%
% CPSELECT(INPUT,BASE) は、CPSTRUCT に、コントロールポイントを出力しま
% す。INPUT は、BASE イメージの座標システムに、取り込むために必要なイメ
% ージです。INPUT と BASE は、グレースケールイメージを含むファイルを識
% 別する文字列、または、グレースケールイメージ、または、文字列を含む変
% 数のいずれかです。
%
% CPSELECT(INPUT,BASE,CPSTRUCT_IN) は、CPSTRUCT_IN にストアするコントロ
% ールポイントの初期集合をもつ CPSELECT を起動します。このシンタックスは、
% CPSTRUCT_IN に前もってセーブしたコントロールポイントをもつ CPSELECT を
% 再起動します。
%
% CPSELECT(INPUT,BASE,XYINPUT_IN,XYBASE_IN) は、コントロールポイントの初
% 期の組の集合を使って、CPSELECT を起動します。XYINPUT_IN と XYBASE_IN 
% は、それぞれ、INPUT 座標と BASE 座標をストアした M 行 2 列の行列です。
%
% H = CPSELECT(INPUT,BASE,...) は、ツールのハンドル H を出力します。DIS-
% POSE(H) と H.dispose は、共に、コマンドラインからツールをクローズできま
% す。
%
% クラスサポート
% -------------
% 入力イメージは、uint8, uint16, double または、logical のいずれのクラス
% でも構いません。
%
%   例題
%   --------
% セーブしたイメージと共に、ツールを起動します。
%       aerial = imread('westconcordaerial.png');
%       cpselect(aerial(:,:,1),'westconcordorthophoto.png')
%
% ワークスペースイメージとポイント群と共に、ツールを起動します。
%       I = checkerboard;
%       J = imrotate(I,30);
%       base_points = [11 11; 41 71];
%       input_points = [14 44; 70 81];
%       cpselect(J,I,input_points,base_points);
%
% 参考：CPCORR, CP2TFORM, IMTRANSFORM.


%   Copyright 1993-2002 The MathWorks, Inc.
