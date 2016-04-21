% データタイプと構造体
%
% データタイプ (クラス)
% double          - 倍精度に変換
% char            - キャラクタ配列（文字列）の作成
% logical         - 数値を論理値に変換
% cell            - セル配列の作成
% struct          - 構造体配列の作成または変換
% single          - 単精度に変換
% uint8           - 符号なし8ビット整数に変換
% uint16          - 符号なし16ビット整数への変換
% uint32          - 符号なし32ビット整数への変換
% uint64          - 符号なし64ビット整数への変換
% int8            - 符号付き8ビット整数への変換
% int16           - 符号付き16ビット整数への変換
% int32           - 符号付き32ビット整数への変換
% int64           - 符号付き64ビット整数への変換
% inline          - INLINEオブジェクトの作成
% function_handle - 関数ハンドル配列
% javaArray       - Java 配列の作成
% javaMethod      - Java メソッドの起動
% javaObject      - Java オブジェクトコンストラクタの起動
%
% クラス判定関数
% isnumeric       - 数値配列に対して True 
% isfloat         - 単精度および倍精度の浮動小数点配列に対して True
% isinteger       - 整数データタイプの配列に対して True
% islogical       - 論理配列に対して True
% ischar          - 文字配列に対して True (文字列)
% 
% 多次元配列関数
% cat         - 配列の結合
% ndims       - 配列の次元数
% ndgrid      - N次元関数や補間に対する配列の作成
% permute     - 配列の次元の再配列
% ipermute    - 配列の次元の再配列の逆操作
% shiftdim    - 次元のシフト
% squeeze     - 1の次元(シングルトン次元)の削除
%
% セル配列関数
% cell        - セル配列の作成
% cellfun     - セル配列を引数とする関数
% celldisp    - セル配列の内容を表示
% cellplot    - セル配列の構造をグラフィカルに表示
% cell2mat    - 1つの行列内に行列のセル配列を結合
% mat2cell    - 行列のセル配列内の行列を分解
% num2cell    - 数値配列をセル配列に変換
% deal        - 入力を出力へ分配
% cell2struct - セル配列を構造体配列に変換
% struct2cell - 構造体配列をセル配列に変換
% iscell      - セル配列の検出
%
% 構造体関数
% struct      - 構造体配列の作成または変換
% fieldnames  - 構造体配列のフィールド名の取得
% getfield    - 構造体配列のフィールドの内容の取得
% setfield    - 構造体配列のフィールドの設定
% rmfield     - 構造体配列のフィールドの削除
% isfield     - 構造体配列内のフィールドの検出
% isstruct    - 構造体配列の検出
% orderfields - 構造体配列のフィールドの順番の並べ替え
%
% 関数ハンドル関数
% @               - function_handleの作成
% func2str        - function_handle 配列を文字列に変換
% str2func        - 文字列を function_handle 配列に変換
% methods         - function_handle に関連した関数のリスト
%
% オブジェクト指向プログラミング関数
% class           - オブジェクトの作成とオブジェクトクラスの出力
% struct          - オブジェクトを構造体配列に変換
% methods         - クラスのメソッド名とプロパティ名のリスト
% methodsview     - クラスのメソッド名とプロパティの表示
% isa             - 与えられたクラスのオブジェクトの検出
% isjava          - Javaオブジェクトの検出
% isobject        - MATLAB オブジェクトの検出
% inferiorto      - 下位クラスの関係
% superiorto      - 上位クラスの関係
% substruct       -  SUBSREF/SUBSASGNに対する構造体引数を作成
%
% オーバロード可能な演算子
% minus       - 減算 a-bに対するオーバロード手法
% plus        - 加算 a+bに対するオーバロード手法
% times       - 乗算 a.*bに対するオーバロード手法
% mtimes      - 行列の乗算 a*bに対するオーバロード手法
% mldivide    - 行列の左除算 a\bに対するオーバロード手法
% mrdivide    - 行列の右除算 a/bに対するオーバロード手法
% rdivide     - 配列の右除算 a./bに対するオーバロード手法
% ldivide     - 配列の左除算 a.\bに対するオーバロード手法
% power       - 配列のベキ乗 a.^bに対するオーバロード手法
% mpower      - 行列のベキ乗 a^bに対するオーバロード手法
% uminus      - 単項減算 -aに対するオーバロード手法
% uplus       - 単項加算 +aに対するオーバロード手法
% horzcat     - 水平結合 [a b]に対するオーバロード手法
% vertcat     - 垂直結合 [a;b]に対するオーバロード手法
% le          - 比較演算 a< = bに対するオーバロード手法
% lt          - 比較演算 a<bに対するオーバロード手法
% gt          - 比較演算 a>bに対するオーバロード手法
% ge          - 比較演算 a> = bに対するオーバロード手法
% eq          - 比較演算 a == bに対するオーバロード手法
% ne          - 比較演算 a~ = bに対するオーバロード手法
% not         - 論理演算 ~aに対するオーバロード手法
% and         - 論理演算 a&bに対するオーバロード手法
% or          - 論理演算 a|bに対するオーバロード手法
% subsasgn    - a(i) = b、a{i} = b、a.field = bに対するオーバロード手法
% subsref     - a(i)、a{i}、a.fieldに対するオーバロード手法
% colon       - a:bに対するオーバロード手法
% end         - a(end)に対するオーバロードメソッド
% transpose   - 行列転置 a.'
% ctranspose  - 複素転置 a'
% subsindex   - x(a)に対するオーバロード手法
% loadobj     - .MATファイルからオブジェクトを読み込む場合の呼び出し
% saveobj     - .MATファイルにオブジェクトを保存する場合の呼び出し


%   Copyright 1984-2002 The MathWorks, Inc.
