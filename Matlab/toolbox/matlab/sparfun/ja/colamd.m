% COLAMD  列の最小度合い置換に近似
%
% P = COLAMD (S) は、スパース行列 S に対して、最小度合いの置換ベクトル
% に近似した列を出力します。非対称行列 S に対して、S(:,P) は、S よりも、
% スパースな LU 分解になります。S(:,P)'*S(:,P) の Cholesky 分解も、S'*S 
% の Cholesky 分解よりも、スパースになります。COLAMD は、COLMMD より
% も高速で、より良い順列を出力します。
%
% 使用法：   P = colamd (S)
%            P = colamd (S, knobs)
%            [P, stats] = colamd (S)
%            [P, stats] = colamd (S, knobs)
%
% knobs は、オプションの2要素入力ベクトルです。S がm行n列の場合は、
% (knobs (1))*n よりも多くの要素をもる行は無視されます。(knobs (2))*m 個よ
% りも多くの要素をもつ列は、順番付けの前に削除され、出力転置行列 P の最
% 後に順番付けられます。knobs パラメータが存在しない場合は、knobs (1)
% と knobs (2)に対して、spparms ('wh_frac') が代わりに用いられます。
%
% stats は、オプションの20要素からなる出力ベクトルで、入力行列 S の順番
% と正当性に関する情報を示します。順番統計量は stats (1:3) で表わされ、
% stats(1)とstats(2) は、COLAMD により無視される密の行、列または空の
% 行、列の数です。stats(3) は、COLAMD で使用される内部データ構造体
% に適用されているガーベッジコレクションの回数で、おおよそ size 2.2*nnz(S)
% + 4*m + 7*n の整数部になります。
%
% MATLAB組み込み関数は、重複のない要素をもつ各列の中で非ゼロの行イン
% デックスを増加する順に、各列の要素数が非負である正しい型のスパース行
% 列を作成します。行列が正しい型でない場合は、COLAMD は継続される場合
% もあり、そうでない場合もあります。重複する部分が存在したり(行インデック
% スが同じ列の中に複数回表れる)、同じ列の中の行にインデックスに異常が
% ある場合は、COLAMD は、重複する部分を無視して、行列 S の内部コピー
% の各列をソートすることにより、これらのエラーを補正することができます。行
% 列が、他の原因で正しい型のものでなく、COLAMD が継続できない場合は、
% エラーメッセージがプリントされ、出力引数(P または stats)が出力されませ
% ん。COLAMD は、スパース行列をチェックする簡単な方法で、それが正しい
% 型の行列か否かを調べることができます。
%
% stats (4:7) は、COLAMD が継続可能であるかどうかの情報を提供します。
% stats(4)がゼロの場合行列はOK で、1の場合正しくないものです。stats(5)
% は、ソートされていない、または重複している要素を含んだ最も右の列を示
% し、そのような列が存在しない場合は0です。stats(6) は、stats(5)で与えられ
% る列インデックス内の順序良く配列されていない行インデックス、または、
% 重複の最新のものを含んでいます。そのような行インデックスが存在していな
% い場合はゼロです。stats(7)は、順序良く並んでいない行インデックス、また
% は、重複の数を示します。
%
% stats (8:20) は、COLAMD のカレントバージョンでは常にゼロです(将来のバ
% ージョンで利用)。
%
% 順番は、列削除ツリーの順番付けに従っています。
%
% Authors: 
%   Stefan I. Larimore and Timothy A. Davis, University of Florida,
%   (davis@cise.ufl.edu); in collaboration with John Gilbert, Xerox PARC,
%    and Esmond Ng, Oak Ridge National Laboratory.  This work was suppo-
%    rted by the National Science Foundation, under grants DMS-9504974 
%    and DMS-9803599.
%    COLAMD and SYMAMD are available at http://www.cise.ufl.edu/~davis/
%    colamd.
%
% Date:
%
%    January 31, 2000.  Version 2.0.  The above comments revised on
%    June 20, 2000 (no change to the code).
%
% Acknowledgements:
%
%    This work was supported by the National Science Foundation, under
%    grants DMS-9504974 and DMS-9803599.
%
% 参考： COLMMD, COLPERM, SSPARMS, SYMAMD, SYMMMD, SYMRCM.


%  Used by permission of the Copyright holder.  This version has been modified
%  by The MathWorks, Inc. and their revision information is below:
%  $Revision: 1.4.4.1 $ $Date: 2004/04/28 02:02:31 $

