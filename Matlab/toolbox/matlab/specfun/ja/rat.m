% RAT   有理数近似
% 
% [N,D] = RAT(X,tol) は、abs(N./D - X) < =  tol*abs(X) の範囲で、N./D が 
% X に近似するような2つの整数行列を出力します。有理数近似は、連分数の
% 展開によって作られます。tol のデフォルト値は、1.e-6*norm(X(:),1) です。
%
% S = RAT(X) または RAT(X,tol) は、連分数展開を文字列として出力します。
%
% MATLABのFORMAT RATの内部で、デフォルトの tol を使った同じアルゴリズム
% が使用されます。
%
% 参考：FORMAT, RATS.


%   Cleve Moler, 10-28-90, 12-27-91, 9-4-92, 4-27-95.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:28 $
