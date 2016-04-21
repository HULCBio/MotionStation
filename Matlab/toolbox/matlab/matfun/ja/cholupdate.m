% CHOLUPDATE   Cholesky分解のランク1の更新
% 
% R = CHOL(A) が A のオリジナルのCholesky分解の場合、
% R1 = CHOLUPDATE(R,X) は、A + X*X' の上三角Cholesky分解を出力しま
% す。X は、適切な長さの列ベクトルです。CHOLUPDATE は、R の対角部分
% と上三角部分のみを使います。R の下三角部分は無視されます。
%
% R1 = CHOLUPDATE(R,X,'+') は、R1 = CHOLUPDATE(R,X) と同じです。
%
% R1 = CHOLUPDATE(R,X,'-') は、A - X*X' のCholesky分解を出力します。
% R が有効なCholesky分解でないか、ダウンデートされた行列が正定行列で
% ない場合はエラーメッセージが表示され、Cholesky分解は行えません。
%
% [R1,p] = CHOLUPDATE(R,X,'-') は、エラーメッセージを出力しません。p が0
% の場合は、R1 は A - X*X' のCholesky分解です。p が0より大きければ、
% R1はオリジナルの A のCholesky分解です。p が1の場合は、ダウンデートさ
% れた行列が正定行列でないので、CHOLUPDATE は失敗します。p が2の
% 場合は、R の上三角部分が有効なCholesky分解でないので、
% CHOLUPDATE は失敗します。
%
% CHOLUPDATE は、フル行列に対してのみ機能します。
%
% 参考：CHOL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:41 $
%   Built-in function.

