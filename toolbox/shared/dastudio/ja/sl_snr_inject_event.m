% sl_snr_inject_event   Grand Unified Search と Replace へのイベントの投入
%
% 使用法: sl_snr_inject_event (ev) の ev は以下の中の1つを設定します。
%   'search'        つぎに一致するための検索
%   'replace'       現在一致するものを置き換え
%   'replaceAll'    さらに一致したものすべてを置き換え
%   'help'          ヘルプの取得
%   'cancel'        このダイアログを閉じる
%   'regExp'        正規表現による検索
%   'matchWord'     正確な単語のみの一致
%   'containsWord'  直接含まれる単語での一致
%   'fieldsToggle'  チェックボックスのフィールドの表示のトグル
%   'labels'        ラベルの検索のトグル
%   'names'         ラベルの検索のトグル
%   'descriptions'  ラベルの検索のトグル
%   'document'      ラベルの検索のトグル
%   'customCode'    ラベルの検索のトグル
%   'typesToggle'   チェックボックスのタイプの表示のトグル
%   'states'        状態の検索のトグル
%   'charts'        チャートの検索のトグル
%   'junctions'     ジャンクションの検索のトグル
%   'transitions'   遷移の検索のトグル
%   'data'          データの検索のトグル
%   'events'        イベントの検索のトグル
%   'targets'       ターゲットの検索のトグル
%   'machine'       マシンの検索のトグル
%   'chartScope'    検索範囲をチャートに設定
%   'machineScope'  検索範囲をマシンに設定
%   'replaceThis'   カレントオブジェクト内で一致するすべてを置き換え
%   'refreshTypes'  該当する場合、文字列のタイプをリフレッシュ
%   'simulation'    シミュレーションモードで実行するための検索の設定
%                   (デフォルト)
%   'standAlone'    スタンドアロンモードで実行するための検索の設定
%   'reset'         検索のリセット(必要であれば図の再表示)
%   'kill'          図(および、スタンドアロンモードの状態マシン)の無効化
%   'mouse_up'      マウスアップアクションの表示
%   'mouse_down'    マウスダウンアクションの表示
%   'mouse_moved'   マウスムーブアクションの表示
%   'view'          チャートまたはエクスプローラ内のカレントのアイテム
%                   のビュー
%   'properties'    カレントのアイテムに対するプロパティダイアログのビュー
%   'explore'       エクスプローラ内のカレントのアイテムのビュー
%   'escape'        マウスモードのリセット
%   'matchCase'     大文字小文字を区別して使用するトグル
%   'preserveCase'  指定された文字の大きさ(大文字/小文字)に変換して
%                   使用するトグル


%   Tom Walsh August 2000
%   J Breslau September 2000
%
%   Copyright 2000-2002 The MathWorks, Inc.
