% CPSTRUCT2PAIRS  CPSTRUCT を正しい組み合わせのコントロールポイントに変換
% [INPUT_POINTS, BASE_POINTS] = CPSTRUCT2PAIRS(CPSTRUCT) は、(CPSELECT 
% で作成する)CPSTRUCT を入力引数として、INPUT_POINT と BASE_POINTS に正
% しい組み合わせのコントロールポイントの座標を出力します。CPSTRUCT2PAIRS
% は、一致していないポイントと予測されるポイントを削除します。
%
% 例題
%   -------
% cpselect を実行します。
%
%       cpselect('lily.tif','flowers.tif')
%
% CPSELECT を使って、イメージの中のコントロールポイントをピックアップし
% ます。ファイル(File)メニューから"ワークスペースへの保存(Save To Work-
% space)"を選択して、ワークスペースにポイント群を保存します。"保存(Save)"
% ダイアログボックスで、"すべてのポイントを含んだ構造体(Structure with 
% all points)"チェックボックスをチェックし、"入力ポイント(Input poins)"
% と"ベースポイント(base points)"のチェックを解除します。OK をクリックし
% ます。CPSTRUCT2PAIRS を使って、CPSTRUCT から入力ポイントとベースポイン
% トを抽出します。
%
%       [input_points,base_points] = cpstruct2pairs(cpstruct);
%
% 参考： CP2TFORM, CPSELECT, IMTRANSFORM.



%   Copyright 1993-2002 The MathWorks, Inc. 
