% 演算子と特殊キャラクタ
%
% 数値演算子
% plus       - 加算                              +
% uplus      - 単項加算                          +
% minus      - 減算                              -
% uminus     - 単項減算                          -
% mtimes     - 行列の乗算                        *
% times      - 配列の乗算                        .*
% mpower     - 行列のベキ乗                      ^ 
% power      - 配列のベキ乗                      .^ 
% mldivide   - バックスラッシュ、行列の左除算    \
% mrdivide   - スラッシュ、行列の右除算          /
% ldivide    - 配列の左除算                      .\
% rdivide    - 配列の右除算                      ./
% kron       - Kroneckerのテンソル積             kron
%
% 比較演算子
% eq         - 等しい                             =  = 
% ne         - 等しくない                        ~ = 
% lt         - より小さい                        <
% gt         - より大きい                        >
% le         - より小さいまたは等しい            < = 
% ge         - より大きいまたは等しい            > = 
%
% 論理演算子
%              Short-circuit 論理和             &&     
%              Short-circuit 論理積             ||     
% and        - 要素ごとの論理積                  &      
% or         - 要素ごとの論理和                  |      
% not        - 否定                              ~
% xor        - 排他的論理和
% any        - ベクトルに非ゼロ要素があるかどうかのテスト
% all        - ベクトルのすべての要素が非ゼロであるかどうかのテスト
%
% 特殊演算子
% colon      - コロン                            : 
% paren      - 丸括弧とサブスクリプト           ( )
% paren      - 鍵括弧                           [ ]
% paren      - 中括弧とサブスクリプト           { }
% punct      - 関数ハンドル作成                  @
% punct      - 小数点                            .
% punct      - 構造体のフィールド                .
% punct      - 親ディレクトリ                    ..
% punct      - 継続記号                          ...
% punct      - セパレータ                        ,
% punct      - セミコロン                        ;
% punct      - コメント文                        %
% punct      - OSコマンドの実行                  !
% punct      - 割り当て                           = 
% punct      - 引用符                            '
% transpose  - 転置                              .'
% ctranspose - 複素共役転置                      '
% horzcat    - 水平方向の連結                   [,]
% vertcat    - 垂直方向の連結                   [;]     
% subsasgn   - サブスクリプトを付けた割り当て   ( ),{ },.   
% subsref    - サブスクリプトを付けた参照       ( ),{ },.   
% subsindex  - サブスクリプトのインデックス
%
% ビット単位の演算
% bitand     - ビット単位の論理積
% bitcmp     - 補数ビット
% bitor      - ビット単位の論理和
% bitmax     - 最大の浮動小数点整数
% bitxor     - ビット単位の排他的論理和
% bitset     - ビットの設定
% bitget     - ビットの取り出し
% bitshift   - ビット単位のシフト
%
% 集合演算子
% union      - 和集合
% unique     - 一意的な要素
% intersect  - 共通部分
% setdiff    - 差集合
% setxor     - 排他的論理和
% ismember   - 集合内のメンバの検出
% 
% 参考： ARITH, RELOP, SLASH, FUNCTION_HANDLE.

% 追加のヘルプファイル
% arith      - 算術演算子
% relop      - 関係演算子
% slash      - 行列の除算

%   Copyright 1984-$tokens{"year"} The MathWorks, Inc.
