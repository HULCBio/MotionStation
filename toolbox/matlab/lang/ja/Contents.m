% プログラミング言語コンストラクター
%
% 制御フロー
% if          - 条件付き実行ステートメント
% else        - IFステートメントの条件
% elseif      - IFステートメントの条件
% end         - FOR、WHILE、SWITCH、TRY、IFステートメントの終了
% for         - 特定回数のステートメントの繰り返し
% while       - 不定回数のステートメントの繰り返し
% break       - WHILEまたはFORループの実行の終了
% continue    - FORまたはWHILEループのつぎの繰り返し作業を制御
% switch      - 式に基づきcase文間で切り替えます
% case        - SWITCHステートメントのcase文
% otherwise   - デフォルトのSWITCHステートメントのcase文
% try         - TRYブロックの始まり
% catch       - CATCHブロックの始まり
% return      - 呼び出し関数に戻ります
% error       - エラーメッセージの表示と関数の中止
% rethrow     - エラーを再発行して関数の中止
%
% 評価と実行
% eval        - MATLAB表現を含む文字列の実行
% evalc       - キャプチャを使ったMATLAB表現の評価
% feval       - 文字列で指定された関数の実行
% evalin      - ワークスペース内で式を評価
% builtin     - オーバロードされたメソッドから組込み関数を実行
% assignin    - ワークスペース内に変数を割り当てます
% run         - スクリプトの実行
%
% スクリプト、関数、変数
% script        - MATLABスクリプトとM-ファイル
% function      - 新しい関数の追加
% global        - グローバル変数の定義
% persistent    - persistent(固定)変数
% mfilename     - 現在、実行中のM-ファイル名
% lists         - カンマで区切られたリスト
% exist         - 変数または関数が定義されているかどうかのチェック
% isglobal      - グローバル変数の検出
% mlock         - clearコマンドからM-ファイルを保護
% munlock       - mlock状態を解除
% mislocked     - M-ファイルがクリアできない場合、真
% precedence    - MATLABでの演算優先順位
% isvarname     - 変数名が正しいか否かのチェック
% iskeyword     - 入力がキーボードか否かのチェック
% namelengthmax - MATLAB名の最大長
% genvarname    - 正しい MATLAB 変数名の構成
%
% 引数の取り扱い
% nargchk     - 入力引数の数のチェック
% nargoutchk  - 出力引数の数のチェック
% nargin      - 関数の入力引数の数
% nargout     - 関数の出力引数の数
% varargin    - 可変の入力引数の数
% varargout   - 可変の出力引数の数
% inputname   - 入力引数名
%
% メッセージの表示
% error       - エラーメッセージの表示と関数の中止
% warning     - ワーニングメッセージの表示
% lasterr     - 最新のエラーメッセージ
% lastwarn    - 最新のワーニングメッセージ
% disp        - 配列の表示
% display     - 配列表示用のオーバロード関数
% fprintf     - 書式付きメッセージの表示
% sprintf     - 書式付きデータを文字列に書き出します
%
% 対話的入力
% input       - ユーザ入力の要求
% keyboard    - M-ファイルからキーボードを呼び出します
% pause       - ユーザ応答を待ちます
% uimenu      - ユーザインタフェースメニューの作成
% uicontrol   - ユーザインタフェースコントロールの作成
%
% その他
% checkSyntacticWarnings - シンタクチックワーニングについて M-ファイルをチェック
%   Copyright 1984-2004 The MathWorks, Inc. 
