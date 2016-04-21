% [curVis,lastVis] = dspProcessFixptMaskParams(blk,visState,addlParams)
%
% blk          : 固定小数点が有効なブロック名。デフォルト値は 'gcb' の
%                出力です。
% visState     : 状態を更新することを可能にするこの関数コールの時間での
%                視覚化の設定。サポートされていない場合、視覚状態は、
%                get_param(blk,'maskvisibilities') をコールすることによって
%                初期化されます。
% lastVisState : 最後に適用された視覚状態。サポートされない場合、状態は、
%                visState に等しくなるよう初期化されます。
% addlParams   : 'Show additional parameters' チェックボックスによって
%                オンとオフの切り替えを行う(パラメータインデックスによる)
%                付加的なマスクパラメータの配列。
%
% この関数は、固定小数点が有効なブロックに対して、下に示されるパラメータ
% の視覚化のダイナミックなスイッチングを操作します。
%
% この関数は、2つの値を出力します。:
%  
% curVis  : 現在の視覚化設定の設定
% lastVis : 最後に適用された視覚化設定の設定
%
% この関数は、以下のパラメータ変数がブロックのマスクに存在するものと仮定
% します。:
%   
% additionalParams : 下に付加的なパラメータを表示するかしないかを示す
%                    チェックボックス
% dataType         : 'Fixed-point' と 'User-defined' と同じようにサポート
%                    される組み込みのデータタイプをリストするポップアップ
% wordLen          : dataType に 'Fixed-point' が選択されたときに有効に
%                    なるエディットボックス
% udDataType       : dataType に 'User-defined' が選択されたときに有効に
%                    なるエディットボックス
% fracBitsMode     : 2つの選択をもつポップアップ: Best precision' と
%                    'User-defined'
% numFracBits      : fracBitsMode が 'User-defined' のときに有効な
%                    チェックボックス
%   
% 注意: この関数は、'Show additional parameters' ボックスが VISIBLE の
%       ときのみコールされます。そうでない場合、最後に選択された設定は
%       必要でなく、最後に適用された設定の値を出力します。
%
% 注意: これは、DSP Blocksetのマスクユーティリティです。一般的な目的の
%       関数として使用されることを意図していません。


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:26 $
