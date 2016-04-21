% ハンドルグラフィックス
% 
% Figureウィンドウの作成と制御
% figure        - figureウィンドウの作成
% gcf           - カレントのfigureのハンドル番号を取得
% clf           - カレントのfigureを消去
% shg           - グラフウィンドウを表示
% close         - figureのクローズ
% refresh       - figureを再描画
% refreshdata   - figure にプロットされたデータの更新
% openfig       - 新しいコピーのオープンまたはセーブしているfigureのオープン
% 　　　　　　   
% axesの作成と制御
% subplot       - 複数のaxesの作成
% axes          - 任意の位置にaxesを作成
% gca           - カレントのaxesのハンドル番号の取得
% cla           - カレントのaxesの消去
% axis          - 軸のスケーリングと外観の制御
% box           - 軸の境界
% caxis         - 擬似カラー軸のスケーリング
% hold          - カレントグラフのホールド
% ishold        - ホールド状態の出力
%
% ハンドルグラフィックスオブジェクト
% figure        - figureウィンドウの作成
% axes          - axesの作成
% line          - lineの作成
% text          - textの作成
% patch         - patchの作成
% rectangle     - 長方形、角の丸い長方形、楕円の作成
% surface       - surfaceの作成
% image         - imageの作成
% light         - lightの作成
% uicontrol     - ユーザインタフェースコントロールの作成
% uimenu        - ユーザインタフェースメニューの作成
% uicontextmenu - ユーザインタフェースコンテキストメニューの作成
%
% ハンドルグラフィックスの操作
% set          - オブジェクトのプロパティの設定
% get          - オブジェクトのプロパティの取得
% reset        - オブジェクトのプロパティのリセット
% delete       - オブジェクトの削除
% gco          - カレントのオブジェクトのハンドル番号の取得
% gcbo         - カレントのコールバックオブジェクトのハンドル番号の取得
% gcbf         - カレントのコールバックfigureのハンドル番号の取得
% drawnow      - ペンディング中の描画イベントの消去
% findobj      - 指定したプロパティ値をもつオブジェクトの検出
% copyobj      - グラフィックスオブジェクトとその子のコピーの作成
% isappdata    - アプリケーション定義のデータの検出
% getappdata   - アプリケーション定義のデータ値の取得
% setappdata   - アプリケーション定義のデータの設定
% rmappdata    - アプリケーション定義のデータの削除
%
% ハードコピーと印刷
% print       - グラフ、Simulinkシステムの印刷またはM-ファイルに保存
% printopt    - プリンタのデフォルト
% orient      - 用紙の方向の設定
%
% ユーティリティ
% closereq   - Figureのクローズを要求する関数
% newplot    - NextPlotプロパティのためのM-ファイルのプリアンブル
% ishandle   - グラフィックスのハンドル番号の検出
%
% ActiveX クライアント関数 (PCのみ)
% actxcontrol   - ActiveXコントロールの作成
% actxserver    - ActiveXサーバの作成
%
% 参考： GRAPH2D, GRAPH3D, SPECGRAPH, WINFUN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:55:30 $
