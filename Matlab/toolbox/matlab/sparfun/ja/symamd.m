% SYMAMD  対称な近似最小度合いの置換
% 
% P = SYMAMD (S) は、S(p,p) が、S よりもよりスパースなCholesky因子をもつ
% ような置換ベクトル p を出力します。ここで、S は、対称正定行列です。
% しばしば、SYMAMD は、対称で正定でない行列にも機能します。SYMAMD は、
% SYMMMD よりも高速で、より良い順序を出力します。行列 S は、対称と仮定
% されます。厳密に下三角形部分のみが参照されます。S は、正方行列でなけ
% ればなりません。
%
%    Usage:  P = symamd (S)
%            P = symamd (S, knobs)
%            [P, stats] = symamd (S)
%            [P, stats] = symamd (S, knobs)
%
% knobs は、オプションのスカラ入力引数です。S が n 行n 列の場合、knobs*n 
% 要素より多くの列と行は、順序付けされる前に除去され、出力置換 P の最後
% の部分に順序付けられます。knobs パラメータが存在しない場合は、spparms 
% ('wh_frac') が代わりに用いられます。
%
% stats は、オプションの20要素からなる出力ベクトルで、入力行列 S の順序
% や正当性に関するデータを出力します。順序統計量は、stats (1:3) に出力
% されます。stats (1) = stats (2) は、SYMAMD により無視される密の行や列、
% または、空の行や列の数で、stats (3) は、SYMAND により使用された内部
% データ構造に適用されたガーベッジコレクションの数
% (約 8.4*nnz(tril(S,-1)) + 9*n )です。
%
% MATLAB組み込み関数は、重複のない要素をもつ各列の中で、非ゼロの行イン
% デックスを増加する順、各列の要素数が非負である正しい型のスパース行列を
% 作成します。行列が正しい型でない場合は、SYMAND は継続されるか、あるいは
% されないかもしれません。重複する部分が存在したり(行インデックスが同じ
% 列の中に複数回表れる)、同じ列の中の行にインデックスに異常がある場合は、
% SYMAMD は、重複する部分を無視して、行列 S の内部コピーの各列をソート
% することにより、これらのエラーを補正することができます。行列が、他の
% 原因で正しい型のものでなく、SYMAMD が連続でない場合、エラーメッセージ
% がプリントされ、出力引数(P または stats)が戻されません。SYMAMD は、
% スパース行列をチェックする簡単な方法で、それが正しい型の行列か否かを
% 調べることができます。
%
% stats (4:7) は、SYMAMD が継続可能かどうかの情報を提供します。stats(4) 
% がゼロの場合は行列はOK で、無効な場合は1です。stats(5) は、ソートされて
% いない、または重複している要素を含む最も右の列を示し、そのような列が
% 存在しない場合は0です。stats(6) は、stats(5) で与えられた列インデックス内
% の順序良く配列されていない行インデックス、または重複するうちの最新のもの
% を含んでいます。そのような行インデックスが存在しない場合はゼロです。
% stats(7) は、順序良く並んでいない行インデックス、または重複する行イン
% デックスの数を示します。
%
% stats (8:20) は、SYMAMD のカレントバージョンでは常にゼロです(将来の
% バージョンで利用)。
%
% 順番は、列消去ツリーのpost-orderingに従っています。
%
%    Authors:
%
%    The authors of the code itself are Stefan I. Larimore and Timothy A.
%    Davis (davis@cise.ufl.edu), University of Florida.  The algorithm was
%    developed in collaboration with John Gilbert, Xerox PARC, and Esmond
%    Ng, Oak Ridge National Laboratory.
%
%    Date:
%
%       January 31, 2000.  Version 2.0.  The above comments revised on
%       June 20, 2000 (no change to the code).
%
%    Acknowledgements:
%
%       This work was supported by the National Science Foundation, under
%       grants DMS-9504974 and DMS-9803599.
%
% 参考 ： COLMMD, COLPERM, SSPARMS, COLAMD, SYMMMD, SYMRCM.


%  Used by permission of the Copyright holder.  This version has been modified
%  by The MathWorks, Inc. and their revision information is below:
%  $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:03:39 $

