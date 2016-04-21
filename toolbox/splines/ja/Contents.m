% Spline Toolbox
% Version 3.2.1 (R14) 05-May-2004 
%
% GUI
%   splinetool - いくつかのスプライン近似法のデモンストレーション
%   bspligui   - 節点の関数としてのB-スプラインに関する実験
%
% スプラインの作成
%                         
%   csape    - 種々の端点条件をもつキュービックスプライン補間
%   csapi    - 節点でない端点条件をもつキュービックスプライン補間
%   csaps    - キュービック平滑化スプライン
%   cscvn    - 自然または周期的なキュービックスプライン曲線
%   getcurve - キュービックスプライン曲線の対話的な作成
%   ppmak    - pp-型スプラインの組立て
%
%   spap2    - 最小二乗スプライン近似
%   spapi    - スプライン補間
%   spaps    - 平滑化スプライン
%   spcrv    - 均等な区分による制御点からのスプライン曲線
%   spmak    - B-型スプラインの組立て
%
%   rpmak    - rp-型有理スプラインの組立て
%   rsmak    - rB-型有理スプラインの組立て
%
%   stmak    - st-型有理スプラインの組立て
%   tpaps    - Thin-plate平滑化スプライン
%
% スプラインの操作 (B-型, pp-型, rB-型, st-型, ...の任意の型、
%                          1変数または多変数)
%   fnbrk    - 型の名前と構成要素
%   fnchg    - 型の構成要素の変更
%   fncmb    - 関数の算術
%   fnder    - 関数の微分
%   fndir    - 関数の方向微分
%   fnint    - 関数の積分
%   fnjmp    - 関数の飛び、すなわち、f(x+) - f(x-) 
%   fnmin    - (与えられた区間での)関数の最小値
%   fnplt    - 関数のプロット
%   fnrfn    - ある型のブレークポイント、あるいは、節点の改良
%   fntlr    - テイラー(Taylor)係数、あるいは、多項式
%   fnval    - 関数の評価
%   fnzeros  - (与えられた区間での)関数の零点
%   fn2fm    - 設定された型への変換
%
% 節点、ブレークポイント、サイトの手配
%   aptknt   - 適切な節点列
%   augknt   - 節点列の増加
%   aveknt   - 節点の平均
%   brk2knt  - 多重度をもつブレークポイントを節点に変換
%   chbpnt   - 適切なデータサイト (Chebyshev-Demko 点)
%   knt2brk  - 節点列からブレークポイントへ変換し、多重度を表示
%   knt2mlt  - 節点の多重度
%   newknt   - 新しいブレークポイントの分布
%   optknt   - 最適な節点の分布
%   sorted   - メッシュサイトに対するサイトの位置付け
%
% スプライン作成ツール
%   spcol    - B-スプライン選点行列
%   stcol    - 点在する変換選点行列
%   slvblk   - ほぼブロック対角な線形システムの解
%   bkbrk    - ほぼブロック対角な行列の一部
%   chckxywp - *AP* コマンドに対するチェックと調整
%
% スプライン変換ツール
%   splpp    - 局所的なB-係数から左のテイラー(Taylor)係数へ
%   sprpp    - 局所的B-係数から右のテイラー(Taylor)係数へ
%
% デモンストレーション
%   splexmpl - いくつかの簡単な例題
%   spalldem - B-型への導入
%   ppalldem - pp-型への導入
%   bspline  - B-スプラインとその多項式の構成要素をプロット
%   pckkntdm - 節点の選択
%   csapidem - キュービックスプライン補間のデモ
%   csapsdem - キュービック平滑化スプラインのデモ
%   spapidem - スプライン補間のデモ
%   getcurv2 - GETCURVE のスライドショーバージョン
%   histodem - ヒストグラムの平滑化のデモ
%   chebdem  - 等振動スプラインのデモ
%   difeqdem - ガウス点での選点によるODEの解法
%   spcrvdem - スプライン曲線のデモ
%   tspdem   - 2変数テンソル積スプラインのデモ
%
% 関数とデータ
%   franke   - Frankeの2変数テスト関数
%   subplus  - 正部分
%   titanium - テストデータ
%
% スプラインとツールボックスの情報
%   spterms  - spline toolboxの用語の説明
%
% 廃止された関数
%   pplst    - pp-型のスプラインについての利用可能な操作のまとめ
%   splst    - B-型のスプラインについての利用可能な操作のまとめ
%   bsplidem - いくつかのB-スプライン


%   Copyright 1987-2004  C. de Boor and The MathWorks, Inc.
