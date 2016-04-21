% SPALLOC   スパース行列に対するメモリ割り当て
% 
% S = SPALLOC(M,N,NZMAX) は、NZMAX 個の非ゼロ要素を保存するためのスペース
% をもつ、サイズが M 行 N 列の全要素がゼロのスパース行列を作成します。
%
% たとえば、
% 
%     s = spalloc(n,n,3*n);
%     for j = 1:n
%         s(:,j) = (3個の非ゼロ要素をもつスパース列ベクトル);
%     end
%
% 参考：SPONES, SPDIAGS, SPRANDN, SPRANDSYM, SPEYE, SPARSE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:53 $
