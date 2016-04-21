% XPCTARGETSPY - xPC Target スパイ GUI
% 
% XPCTARGETSPY は、ユーザのホスト PC 上にターゲットスクリーンの出力が表示
% 可能な xPC Target スパイウインドウをオープンします。XPCTARGETSPY の挙動
% は、ユーザのカレント xPC 環境のプロパティ TargetScope の値に依存します。
% 
% TargetScope が機能しない場合、Text 出力が毎秒毎に連続してホストに転送さ
% れ、フィギュアに表示されます。TargetScope が機能している場合、Graphics 
% スクリーンへの転送は、連続的には行なわれません。スクリーン内容の更新を初
% 期化するために、ターゲットスパイウインドウ内にマウスを移動し、左クリック
% を行なってください。これは、ターゲットグラフィックスカードが、VGA モード
% の場合、非常に多くのデータを読み込むためです。

% Copyright 1994-2002 The MathWorks, Inc.
