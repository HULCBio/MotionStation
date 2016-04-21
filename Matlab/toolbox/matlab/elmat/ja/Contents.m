% 基本行列と行列操作
%
% 基本行列
% zeros       - 要素がすべて0である配列の作成
% ones        - 要素がすべて1である配列の作成
% eye         - 単位行列
% repmat      - 配列の複製と拡大
% rand        - 一様分布の乱数
% randn       - 正規分布の乱数
% linspace    - 線形に等間隔なベクトルの作成
% logspace    - 対数的に等間隔なベクトルの作成
% freqspace   - 周波数応答用の周波数間隔の設定
% meshgrid    - 3次元プロットのためのX配列とY配列の作成
% accumarray  - アキュミュレーションによる配列の構成
% :           - 等間隔のベクトルの作成と行列のインデックス
%
% 基本的な配列の情報
% size        - 行列のサイズ
% length      - ベクトルの長さ
% ndims       - 配列の次元数
% numel       - 要素数
% disp        - 行列またはテキストの表示
% isempty     - 空行列の検出
% isequal     - 同じ配列の検出
% isequalwithequalnans - 配列の数値要素の検出
% isnumeric   - 数値配列の検出
% isfloat     - 単精度および倍精度の浮動小数点配列に対して True
% isinteger   - 整数データタイプの配列に対して True 
% islogical   - 論理配列の検出
% logical     - 数値を論理値に変換
%
% 行列の操作
% cat         - 配列の連結
% reshape     - サイズの変更
% diag        - 対角行列と行列の対角要素
% blkdiag     - ブロックの対角置換
% tril        - 行列の下三角部分
% triu        - 行列の上三角部分
% fliplr      - 左右方向への行列要素の交換
% flipud      - 上下方向への行列要素の交換
% flipdim     - 指定した次元に沿った行列の置換
% rot90       - 行列の90度回転
% :           - 定間隔のベクトルと行列のインデックス
% find        - 非ゼロ要素のインデックスを求めます
% end         - 最終インデックス
% sub2ind     - 複数のサブスクリプトから線形インデックスに変換
% ind2sub     - 線形インデックスを複数のサブスクリプトに変換
%
% 多次元配列関数
% ndgrid      - N次元関数に対する配列の生成と補間
% permute     - 配列の次元の変更
% ipermute    - 配列の次元の変更の逆操作
% shiftdim    - 次元のシフト
% circshift   - 配列を循環的にシフト
% squeeze     - 単一の次元の削除
%
% 配列ユーティリティ関数
% isscalar    - スカラーに対して True
% isvector    - ベクトルに対して True
%
% 特殊変数と定数
% ans         - 最新の出力
% eps         - 浮動小数点での相対精度
% realmax     - 正の最大浮動小数点数
% realmin     - 正の最小浮動小数点数
% pi          - 3.1415926535897....
% i、j        - 虚数単位
% inf         - 無限大
% NaN         - 不定値
% isnan       - 不定値の検出
% isinf       - 無限要素の検出
% isfinite    - 有限要素の検出
% why         - 簡潔な答え
%
% 特殊行列
% compan      - コンパニオン行列
% gallery     - Higham のテスト行列
% hadamard    - Hadamard行列
% hankel      - Hankel行列
% hilb        - ヒルベルト行列
% invhilb     - 逆ヒルベルト行列
% magic       - 魔方陣
% pascal      - Pascal行列
% rosser      - 古典的対称固有値のテスト問題
% toeplitz    - Toeplitz行列
% vander      - Vandermonde行列
% wilkinson   - Wilkinsonの固有値テスト行列


%   Copyright 1984-2002 The MathWorks, Inc.
