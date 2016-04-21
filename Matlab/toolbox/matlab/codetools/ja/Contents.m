% コードの作成とデバッグのためのコマンド
% $tokens{"name:1"} Version $tokens{"version:1"} $tokens{"release"} $tokens{"date"} 
%
% M-ファイルの編集と管理
% edit                   - M-ファイルの編集
% notebook               - Microsoft Word の m-book を開く (Windows のみ)。
% mlint                  - M-ファイルの矛盾点や疑問点の表示
% 
% ディレクトリツール
% contentsrpt            - 与えられたディレクトリの Contents.m の調査
% coveragerpt            - ラインカバレッジ分析のためにディレクトリをスキャン
します
% deprpt                 - ファイルまたはディレクトリをスキャンして、依存に
%                          ついて調査
% diffrpt                - Visual directory ブラウザ
% dofixrpt               - すべての TODO, FIXME, または NOTE メッセージについ
%                          て、ファイルあるいはディレクトリをスキャンします
% helprpt                - ヘルプに対してファイルまたはディレクトリをスキャン
%                          します
% mlintrpt               - すべての M-Lint メッセージに対して、ファイルまたは
%                          ディレクトリをスキャンします
% standardrpt            - Visual directory ブラウザ
%
% M-ファイルのプロファイル
% profile                - 関数の実行時間のプロファイル
% profview               - HTML プロファイラインタフェースの表示
% profsave               - HTML プロフィールレポートのスタティックバージョンの保存
% profreport             - プロファイラレポートの作成
% profviewgateway        - プロファイラ HTML ゲートウェイ関数
% opentoline             - エディタに関数ファイルの指定されたラインを開きます
% stripanchors           - プロファイラHTMLからMATLABコードを評価するアンカーの削除
%
%
% M-ファイルのデバッグ
% debug       - デバッグコマンドのリスト
% dbstop      - ブレークポイントの設定
% dbclear     - ブレークポイントの削除
% dbcont      - 実行の再開
% dbdown      - ローカルワークスペースの内容の変更
% dbstack     - 関数呼び出しスタックの表示
% dbstatus    - すべてのブレークポイントの表示
% dbstep      - 1行以上の実行
% dbtype      - 行番号付きのM-ファイルのリスト
% dbup        - ローカルワークスペースの内容の変更
% dbquit      - デバッグモードの終了
% dbmex       - MEX-ファイルのデバッグ(UNIXのみ)
%
% 変数の管理、監視、編集
% openvar                - グラフィカルな配列エディタにワークスペース変数を開く
% workspace              - ワークスペースの内容の表示
%
% ファイルシステムとサーチパスの管理
% filebrowser            - Current Directory ブラウザを開く、あるいは、前面に出します
% pathtool               - MATLAB サーチパスの表示、修正、保存

% Command Window と Command History ウィンドウ
% commandwindow          - Command Window を開くか、あるいは、
%　　　　　　　　　　　　　　前面にもってきます
% commandhistory         - Command History ウィンドウを開くか、あるいは、
%　　　　　　　　　　　　　　前面にもってきます

% GUI ユーティリティ
% datatipinfo            - 変数の簡単な記述を与えます
% editpath               - サーチパスの修正
% mdbstatus              - エディタ/デバッガに対する dbstatus
% mdbfileonpath          - エディタ/デバッガの補助関数
% mdbpublish             - Codepad publish 関数をコールする MATLAB 
%                          エディタ/デバッガのための補助関数
% workspacefunc          - Workspace ブラウザ要素のためのサポート関数
% notebookCaptureFigures - 図を保存するための Notebook ユーティリティルーチン
% notebookCompareFigures - 図の変更がない場合、0 を出力。変更がある場合、1 を
%                          出力。
%
% ディレクトリツール補助関数
% diff2asv               - 自動的に保存されたファイルがある場合、そのファイル
%                          と比較します
% diffcode               - ファイルの差分に適用する global alignment アルゴリズム
% fixcontents            - CONTENTSRPT に対する補助関数
% fixhelp                - HELPRPT に対する補助関数
% fixquote               - ディレクトリ名に現れるシングルクォートをダブルクォートに変換
% getcallinfo            - 呼び出された関数とそのコーリングラインを出力
% auditcontents          - 指定されたディレクトリの Contents.m の調査
% code2html              - HTML での表示のための MATLAB コードの準備
% visdiff                - 2要素の類似性を比較
% visdir                 - HTML ゲートウェイ関数をレポートするディレクトリ
% visdirgateway          - HTML ゲートウェイ関数をレポートするディレクトリ
% makecontentsfile       - 新しい Contents.m ファイルの作成
% mfiletemplate          - 新規 M-ファイルのためのテンプレート
% newfun                 - ファイル名と内容が与えられた場合に新しい関数を作成
% deleteconfirm          - ファイルの削除をダイアログボックスで確認します
%
% パブリッシングヘルパーファイル
% publish                - スクリプトの実行と結果の保存
% grabcode               - MATLABの生成した HTML デモファイルからM-コードを抜粋
% slide2mx               - MATLAB スタイルスライドショーを MX フォーマットに変換
% slide2script           - playshow フォーマットデモを script フォーマットに変換% snapshot               - M-ファイルの実行と結果の図の保存
% takepicture            - ファイルの実行、スナップショットをとる、イメージの保存
% all_m_to_html          - すべての新規または更新された m-ファイルデモを HTML に変換
% m2struct               - M-コードをセルに分ける
%
% その他のファイル
% uiimport               - データインポート用の GUI(Import Wizard)を起動
% arrayviewfunc          - 配列エディタ要素に対するサポート関数
% initdesktoputils       - デスクトップとデスクトップツールに対する MATLAB 
%                          パスの初期化
% makemcode              - 入力オブジェクト(複数可)に基づき、可読性の m-コード
%                          関数を作成します
% 廃止された関数
% mexdebug               - MEX-ファイルのデバッグ

%   Copyright 1984-$tokens{"year"} The MathWorks, Inc. 
