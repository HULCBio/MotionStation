% QZ   一般化固有値に対するQZ分解
% 
% [AA, BB, Q, Z, V] = QZ(A,B) は、正方行列 A と B に対して、Q*A*Z = AA かつ
% Q*B*Z = BB であるような上三角行列 AA と BB、左乗算と右乗算による変換
% 行列を含むユニタリ行列 Q と Z、一般固有ベクトル行列 V を出力します。
% 
% [AA, BB, Q, Z, V, W] = QZ(A,B) は、列が一般化固有ベクトルである行列 V と 
% W も出力します。
%
% 複素行列に対して、AA と BB は三角行列になります。実数行列に対して、QZ
% (A,B,'real') は、1行1列および2行2列の対角ブロックを含む準三角行列 AA をも
% つ実分解を行い、一方、QZ(A,B,'complex') は、三角行列 AA をもつ可能な複素
% 分解を行います。旧バージョンとの互換性のため、'complex' がデフォルトです。
% 
% AAが三角行列の場合は、AA と BB の対角要素
%       alpha = diag(AA), beta = diag(BB),
% は、
%       A*V*diag(beta) = B*V*diag(alpha)
%       diag(beta)*W'*A = diag(alpha)*W'*B
% を満たす一般化固有値です。
%
%       lambda = eig(A,B)
% により出力される固有値は、alphaとbetaの比率です。
%       lambda = alpha./beta
% AA がが三角行列でない場合は、フルシステムの固有値を得るために、2行2列
% のブロックを削除する必要があります。
% 
% 参考 ORDQZ, SCHUR, EIG.

%   Copyright 1984-2002 The MathWorks, Inc. 

