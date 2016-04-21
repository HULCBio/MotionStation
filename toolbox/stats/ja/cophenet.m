% COPHENET   Cophenetic 係数
%
% C = COPHENETIC(Z,Y) は、Z の中のクラスタツリーの距離と Y の中の距離
% との間から Cophenetic 係数を計算します。Z は、関数 LINKAGE からの
% 出力です。Y は、関数 PDIST からの出力です。
% 
% Cophenetic 係数は、つぎのように定義されます。
% 
%                     sum((Z(i,j)-z)*(Y(i,j)-y)) 
%                     i<j             
%        c =   -----------------------------------------
%              sqrt(sum((Z(i,j)-z)^2)*sum((Y(i,j)-y)^2))
%                   i<j               i<j
%            
% Y(i,j) は、観測 i と j の距離で、y は、Y の平均値です。
% Z(i,j) は、接合時点で、観測 i と j の距離で、z = mean(Z) です。
% 
% 例題:
%
%      X = [rand(10,3); rand(10,3)+1; rand(10,3)+2];
%      Y = pdist(X);
%      Z = linkage(Y,'average');
%      c = cophenet(Z,Y);
%
% 参考 : PDIST, LINKAGE, INCONSISTENT, DENDROGRAM, CLUSTER, CLUSTERDATA.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $
