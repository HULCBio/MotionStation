% シンボリックな分解解析
% 
% count = SYMBFACT(A) は、上三角行列が A の上三角行列である、対称行列
% の上三角Cholesky因子に対する行のカウントからなるベクトルを出力します。
% 分解中にキャンセルはないと仮定しています。このルーチンは、chol(A) 
% よりも高速です。
%
% count = SYMBFACT(A,'col') は、A'*A を(明示的に作成せずに)解析します。
% count = SYMBFACT(A,'sym') は、p = symbfact(A) と同じです。
%
% オプションの出力値があります。
%
% [count,h,parent,post,R] = symbfact(...) は、つぎのものも出力します。
%      消去ツリーの高さ
%      消去ツリー
%      消去ツリーのpostordering置換
%      構造体が chol(A) の構造体と等しい0-1行列 R
%
% 参考：CHOL, ETREE, TREELAYOUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:40 $
