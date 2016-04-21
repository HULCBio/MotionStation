% IPERMUTE   配列の次元の並べ替えの逆操作
% 
% A = IPERMUTE(B,ORDER)は、permuteの逆です。IPERMUTE は、
% PERMUTE(A,ORDER) が B を生成するように、B の次元を並べ替えます。
% 作成された配列は A と同じ値をもちますが、ある特定の要素に必要と
% されるサブスクリプトの順番を、ORDER に指定することで並べ替えます。
% ORDER の要素は、1から N の数値の並べ替えでなければなりません。
%
% PERMUTEとIPERMUTEは、N次元配列に対する転置(.')の一般化です。
% 
% 例題：
%      a = rand(1,2,3,4);
%      b = permute(a,[3 2 1 4]);
%      c = ipermute(b,[3 2 1 4]); % a と c は等価
%
% 参考：PERMUTE.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:51:18 $
