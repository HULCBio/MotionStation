% CLUSTER   LINKAGE 出力からクラスタを構成
%
% T = CLUSTER(Z,'CUTOFF',C) は、クラスタツリー Z からクラスタを構成します。
% Z は、関数 LINKAGE で作成された大きさ(M-1)行3列の行列です。 C は、 
% LINKAGE により生成された階層的なツリーをクラスタに分けるために使用する
% しきい値です。クラスタは、inconsistent値が CUTOFF より小さい場合、作成
% されます(INCONSISTENT参照)。出力 T は、オリジナルデータの各観測値に対する
% クラスタ数を含む大きさ M のベクトルです。 
%
% T = CLUSTER(Z,'MAXCLUST',N) は、Z に設定されている階層的なツリーから
% 形成するクラスタの最大数を、Nで指定します。
%
% T = CLUSTER(...,'CRITERION','CRIT') は、指定した基準を使って、クラスタを
% 形成します。ここで、'CRIT' は、'inconsistent' 、あるいは、'distance'の
% いずれかです。
%
% T = CLUSTER(...,'DEPTH',D) は、ツリーでの D の深さに対するinconsistent値を
% 評価します。デフォルトでは、D=2です。
%
% 参考 : PDIST, LINKAGE, COPHENET, INCONSISTENT, CLUSTERDATA.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $   $Date: 2003/02/12 17:11:06 $
