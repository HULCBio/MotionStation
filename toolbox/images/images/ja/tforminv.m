% TFORMINV 　空間的な逆変換を適用
% X が行列の場合、U = TFORMINV( X, T ) は、X の各行に T で定義した逆変換
% を適用します。T は、MAKETFORM, FLIPTFORM, CP2TFORM で作成した TFORM 構
% 造体です。X は、M 行 T.ndims_out 列で、X の各行は、T の出力空間の点を表
% します。U は、M 行 T.ndims_out 列の行列で、U の各行は、T の入力空間の中
% の点を表します。そして、X の対応する行の逆変換になります。
%
% X が、(T.ndims_out が1の場合、インプリシットに後に続くシングルトン次元
% を含む)(N+1)次元の配列の場合、TFORMINV は、各点 X(P1,P2,...,PN,:) に変
% 換を適用します。SIZE(X,N+1) は、T.ndims_in と等しくなります。U は、U
% (P1,P2,...PN,:) の中の各変換の結果を含む(N+1)次元配列です。SIZE(U,I) 
% は、SIZE(X,I) に等しくなります。I = 1,...,N で、SIZE(U,N+1) は、T.ndi-
% ms_in と同じです。
% 
% 例題
% -------
% (0,0), (6,3), (-2,5)を頂点とする三角形を((-1,-1), (0,-10), (-2,5)を頂
% 点とする三角形に写像するアフィン変換を作成します。
%
%       u = [0 0; 6 3; -2 5];
%       x = [-1 -1; 0 -10; 4 4];
%       tform = maketform('affine',u,x);
%   
% TFORMINV を x に適用して、結果を検証します。
%
%       tforminv(x,tform)  % 結果は、u と等しくなるはずです。
%
% 参考： TFORMINV, MAKETFORM, FLIPTFORM, CP2TFORM.



%   Copyright 1993-2002 The MathWorks, Inc.
