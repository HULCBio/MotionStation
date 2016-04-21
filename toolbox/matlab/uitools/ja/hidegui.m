% HIDEGUI   GUIの表示/非表示
% 
% HIDEGUI は、コマンドラインから、カレントのfigureを非表示にします。
% HIDEGUI(state) は、カレントのfigureの非表示状態を設定します(state は、
% 'on'  'off', 'callback' のいずれかです)。
% state = HIDEGUI は、カレントのfigureの非表示状態を出力します。
% HIDEGUI(H,state) は、オブジェクトHの非表示状態を設定または確認します。
%
% この関数は、HandleVisibility プロパティへのインタフェースを提供します。
% このプロパティは、子オブジェクトの親のリスト内でオブジェクトのハンドル
% 番号が視覚可能であるときを決定します。オブジェクトの HandleVisibility が
% 'off' の場合、ハンドル番号は子オブジェクトの親のリスト内で視覚可能では
% ありません。このオブジェクトは、PLOT、CLOSE、GCF、GCA、GCO、FINDOBJ
% のような、オブジェクト階層からオブジェクトを評価する関数からは、視覚可能
% ではありません。オブジェクトの HandleVisibility が、'callback' の場合は、
% ハンドル番号はコールバック中は視覚可能ですが、コールバックが実行されて
% いないときにコマンドラインから呼び込まれた関数からは見えません。
% HandleVisibility が 'on' のとき、ハンドル番号は常に視覚可能です。
%
% HandleVisibility は、NextPlot 'new' の替わりで、コマンドラインからの関数
% 実行によって起こる不適切なダメージから、GUIを保護します。NextPlot 'new'
% は、NextPlot に従う PLOT のような高レベルグラフィックス関数からfigureを
% 保護する一方で、GCF、GCA、GCO、FINDOBJ によってハンドル番号が出力され
% たり CLOSE または CLOSE('all') によって操作されることから、ハンドルを
% 保護していませんでした。
%
% GUIの作成中に、HIDEGUI または HandleVisibility を使うと、コマンドライン
% から呼び込まれる関数からGUIのfigureのハンドル番号は、その点以降はオブ
% ジェクト階層内では視覚可能ではありません。この理由により、GUI作成の
% 最後で、HIDEGUI を呼び出すことを推奨します。そうすると、GC Fや GCA の
% ような関数に依存する作成コードは、通常通り実行します。


%   Damian Packer, Revised by Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:08:13 $
