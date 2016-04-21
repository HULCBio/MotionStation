% Simulink
%
% Version 6.0 (R14) 05-May-2004
%
% モデルの解析と組み込み関数
%
% シミュレーション sim           - Simulinkモデルのシミュレーション
% sldebug       - Simulinkモデルのデバッグ
% simset        - SIM Options構造体のオプションの定義
% simget        - SIM Options構造体の取得
%
% 線形化と平衡点の決定
% linmod        - 連続システムから線形モデルを抽出
% linmod2       - 線形モデルの抽出、アドバンスドな方法
% dlinmod       - 離散システムから線形モデルを抽出
% trim          - 定常状態の平衡点を求める
%
% モデルの作成
% close_system  - 開いているモデル、または、ブロックを閉じる
% new_system    - 新規の空のモデルウィンドウを作成
% open_system   - 既存のモデル、または、ブロックを開く
% load_system   - モデルを可視化せずに既存のモデルを読み込み
% save_system   - 開いているモデルを保存
% add_block     - 新規のブロックを付加
% add_line      - 新規のラインを付加。
% delete_block  - ブロックを削除
% delete_line   - ラインを削除
% find_system      - モデルの検索
% hilite_system    - モデル内のオブジェクトをHilite
% replace_block    - 既存のブロックを新規ブロックで置き換える
% set_param     - モデル、または、ブロックに対してパラメータ値を設定
% get_param     - モデルからシミュレーションパラメータ値を取得
% add_param     - モデルにユーザ定義の文字列のパラメータを追加
% delete_param  - モデルからユーザ定義のパラメータを削除
% bdclose       - Simulinkウィンドウを閉じる
% bdroot        - ルートレベルのモデル名
% gcb           - カレントブロック名の取得
% gcbh          - カレントブロックのハンドルの取得
% gcs           - カレントシステム名の取得
% getfullname   - ブロックの絶対パス名の取得 slupdate      - 1.xのモデルを
%                 3.xに更新
% addterms      - 未接続端子に終端子を付加
% boolean       - 数値配列をbooleanに変換
% slhelp        - Simulink ユーザーズガイド、または、ブロックヘルプ
%
% マスキング
% hasmask       - マスクをチェック
% hasmaskdlg    - マスクダイアログをチェック
% hasmaskicon   - マスクアイコンをチェック
% iconedit      - 関数ginputを用いたブロックアイコンの設計
% maskpopups    - マスクされたブロックのポップアップメニューアイテムの出力と
%                 変更
% movemask      - マスクされた組み込みブロックをマスクされたサブシステムと
%                 して再構成
%
% ライブラリ
% libinfo       - システムのライブラリ情報を取得
%
% 診断
% sllastdiagnostic - 最新の診断に関する配列
% sllasterror      - 最新のエラーに関する配列
% sllastwarning    - 最新のワーニングに関する配列
% sldiagnostics    - モデルに関するブロックカウントの取得と、状態のコンパイ
%                    ル
%
% ハードコピーとプリント
% frameedit     - 注釈付きモデルのプリントアウトに対するプリントフレームの編
%                 集
% print         - グラフ、または、Simulinkシステムのプリント、または、グラフを
%                 M-ファイルに保存
% printopt      - プリンタのデフォルト
% orient        - 用紙の方向の設定
%
% 参考 : BLOCKS , SIMDEMOS.


% Copyright 1990-2002 The MathWorks, Inc.
