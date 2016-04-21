% TFORMFWD  フォワード空間変換を適用
% U が、行列の場合、X = TFORMFWD(U,T) は、T に定義したフォワード変換を 
% U の各行に適用します。T は、MAKETFORM, FLIPTFORM, CP2TFORM で作成され
% た TFORM 構造体です。U は、M 行 T.ndims_in 列の行列で、U の各行は、T 
% の入力空間の点を表しています。X は、M 行 T.ndims_out 列の行列で、各行
% は、T の出力空間の中の点を表します。そして、U の対応する行のフォワード
% 変換になります。
%
% U が、(N+1)-次元の配列(T.ndims_in が、1 の場合、インプリシットなシング
% ルトン次元を含む)の場合、TFORMFWD は、各点 U(P1,P2,...,PN,:) に変換を適
% 用します。SIZE(U,N+1) は、T.ndims_in と等しくなる必要があります。X は、
% X(P1,P2,...PN,:) に各変換の結果を含む (N+1)-次元配列になります。SIZE(X,
% I) は、I = 1,...,N に対して、SIZE(U,I) と等しく、SIZE(X,N+1) は、T.nd-
% ims_out と等しくなります。
% 
% 例題
% -------
% (0,0), (6,3), (-2,5)を頂点とする三角形を(-1,-1), (0,-10), (-2,5)を頂点
% とする三角形に写像するアフィン変換を作成します。
%
%       u = [0 0; 6 3; -2 5];
%       x = [-1 -1; 0 -10; 4 4];
%       tform = maketform('affine',u,x);
%   
% TPORMFWD を u に適用することにより、マッピングを検証します。
%
%       tformfwd(u,tform)  % 結果は、x と等しいはずです。
%
% 参考： TFORMINV, MAKETFORM, FLIPTFORM, CP2TFORM.



%   Copyright 1993-2002 The MathWorks, Inc.
