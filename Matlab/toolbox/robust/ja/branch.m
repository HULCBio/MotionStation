% BRANCH "TREE"変数のブランチ(オプションのシステム行列のデータ構造)
%
% [B1,B2,...,BN] = BRANCH(SYS) または、
% [B1,B2,...,BN] = BRANCH(SYS,V1,...VN) は、LTIシステムからN個のシステム
% データ行列[B1,...,BN]を出力します。
% オプションの入力V1,...,VNは、抽出される変数の名前の文字です。
% SYSに対する適切な名前V1,...,VNのリストは、BRANCH(SYS,0)で出力されます。
%
% [B1,B2,...,BN] = BRANCH(TR,PATH1,PATH2,...,PATHN) は、ツリーTRのN個の
% サブブランチを出力します。NARGIN==1の場合、ルートブランチは、数字イン
% デックスに従って連続的に出力されます。それ以外では、出力されるブランチ
% がパスPATH1,PATH2,...,PATHNによって設定されます。各々のパスは、通常、
% つぎの形式の文字列です。
%           PATH = '/name1/name2/.../namen'
% ここで、name1,name2等は、ルートツリーから対象のサブブランチまでのパス
% を定義するブランチ名の文字列です。一方、PATHを定義しているブランチの整
% 数インデックスを含む行ベクトルを使うこともできます。たとえば、
% S=TREE('a,b,c','foo',[49  50],'bar')の場合、BRANCH(S,'c')とBRANCH(S,3)
% は、共に値'bar'を出力します。
%
% 参考：ISTREE, TREE, MKSYS, BRANCH.



% Copyright 1988-2002 The MathWorks, Inc. 
