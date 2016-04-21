% XPCDNGDEMO xPC Targetを使用したDials & Gauges モデルのデモの使用法
%
% モデルxpctank と共に、 デモダイアルとゲージモデルxpctankpanel (リアルタイム
% で、xPC Target PC 上で実行しています)を実行するために、つぎのステップを実行
% してください。ただし、Target PC が正しく設定され、ダウンロードされたアプリ
% ケーションをアクセプトする準備ができていることが仮定されています。
%
%    1. はじめに、コマンドラインで、名前をタイプすることによりモデルxpctankを
%       開いてください。
%    2. Simulink Windowのメニューから、Tools|Real-Time Workshop|Build Modelを
%       選択して、モデルをビルドしてください。これにより、モデルをビルドし、
%       ダウンロードします。さらに、ベースMATLAB ワークスペースで'tg' と呼ばれ
%       る変数を作成します。この変数は、ターゲットマシンと通信したり、アプリ
%       ケーションの起動、停止などに使用されるxpc オブジェクトです。
%    3. モデルxpctank を閉じ、MATLABコマンドラインで名前を入力することによ
%       り、モデルxpctankpanelを開いてください。
%    4.（Simulinkウィンドウのダウンリスト、あるいは、Simulink メニューのチェッ
%       クのオプションで示された）Normalモードでのシミュレーションの間、シミュ
%       レーションを起動するために、Simulink|Startを選択してください。
%       これは、リアルタイムアプリケーションに接続され、対応する結果を
%       示します。
%
% モデル xpctankpanel内の、個々の'From xPC Target' と 'To xPC Target' ブロ
% ックに注意してください。これらは、xPC Targetと、Dials & Gauges とのインタフェ
% ースのキーです。これらは、Simulink Libraryにあり、Simulink Libraryブラウザ
% で、'xPC Target'，それから、 'Misc' を選択することにより、見つけることができ
% ます。


help(mfilename);

% $Revision: 1.2 $
%   Copyright 1996-2002 The MathWorks, Inc.
