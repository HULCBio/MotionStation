% Symbolic Math Toolbox
% Version 3.1 (R14) 05-May-2004
%
% 計算
%   diff        - 微分
%   int         - 積分
%   limit       - 極限値
%   taylor      - Taylor級数
%   jacobian    - Jacobian行列
%   symsum      - 級数の総和 
%
% 線形代数
%   diag        - 対角行列の作成、または、対角成分の抽出
%   triu        - 上三角行列
%   tril        - 下三角行列
%   inv         - 逆行列
%   det         - 行列式
%   rank        - ランク
%   rref        - 行の階段型
%   null        - ヌル空間に対する基底
%   colspace    - 列空間に対する基底
%   eig         - 固有値と固有ベクトル
%   svd         - 特異値と特異ベクトル
%   jordan      - Jordan正準型
%   poly        - 特性多項式
%   expm        - 行列指数
%
% 簡略化
%   simplify    - 簡略化
%   expand      - 展開
%   factor      - 因数分解
%   collect     - 係数をまとめる
%   simple      - 最も短い表現の検索
%   numden      - 分子と分母
%   horner      - 入れ子の多項式表現
%   subexpr     - 共通する部分式による式の書き換え
%   subs        - シンボリックな代入
%
% 方程式の解法
%   solve       - 代数方程式のシンボリックな解
%   dsolve      - 微分方程式のシンボリックな解
%   finverse    - 逆関数
%   compose     - 関数の合成
%
% 可変精度の演算
%   vpa         - 可変精度の演算
%   digits      - 可変精度の設定
%
% 積分変換
%   fourier     - フーリエ変換
%   laplace     - ラプラス変換
%   ztrans      - Z-変換
%   ifourier    - 逆フーリエ変換
%   ilaplace    - 逆ラプラス変換
%   iztrans     - 逆Z-変換
%
% 変換
%   double      - シンボリック行列を倍精度に変換
%   poly2sym    - 係数ベクトルをシンボリック多項式に変換
%   sym2poly    - シンボリック多項式を係数ベクトルに変換
%   char        - シンボリックオブジェクトを文字列に変換
%
% 基本演算
%   sym         - シンボリックオブジェクトの作成
%   syms        - シンボリックオブジェクト作成のショートカット
%   findsym     - シンボリック変数の決定
%   pretty      - シンボリック式のプリティプリント
%   latex       - シンボリック式のLaTeX表現
%   ccode       - シンボリック式のCコード表現
%   fortran     - シンボリック式のFortran表現
%
% 特殊関数
%   sinint      - 正弦積分関数
%   cosint      - 余弦積分関数
%   zeta        - Riemannのzeta関数
%   lambertw    - LambertのW関数
%
% 文字列の取り扱いのユーティリティ
%   isvarname   - 有効な変数名のチェック(MATLAB TOOLBOX)
%   vectorize   - シンボリック式のベクトル化
%
% 教育的なグラフィカルアプリケーション
%   rsums       - Riemann和
%   ezcontour   - 簡単なコンタープロット
%   ezcontourf  - 簡単な塗りつぶしコンタープロット
%   ezmesh      - 簡単なメッシュ(サーフェス)プロット
%   ezmeshc     - メッシュとコンターの簡単な組み合わせプロット
%   ezplot      - 関数の簡単なプロット
%   ezplot3     - 3次元パラメトリック曲線の簡単なプロット
%   ezpolar     - 簡単な極座標プロット
%   ezsurf      - 簡単なサーフェスプロット
%   ezsurfc     - サーフェスとコンターの簡単な組み合わせプロット
%   funtool     - 関数計算機
%   taylortool  - Taylor級数計算機
%
% デモ
%   symintro    - Symbolic Toolboxの紹介
%   symcalcdemo - 計算のデモンストレーション
%   symlindemo  - シンボリックな線形代数のデモ
%   symvpademo  - 可変精度の演算のデモ
%   symrotdemo  - 平面回転の問題
%   symeqndemo  - シンボリックな式の解法のデモ
%
% Mapleへのアクセス(Student Editionでは使用できません)
%   maple       - Mapleのカーネルへのアクセス
%   mfun        - Maple関数の数値評価
%   mfunlist    - MFUNの関数のリスト
%   mhelp       - Mapleのヘルプ
%   procread    - Mapleのプロシージャの挿入(Extended Toolboxが必要です)

%   Copyright 1993-2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/09/14 14:00:58 $
