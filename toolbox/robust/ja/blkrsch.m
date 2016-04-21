% BLKRSCH   ブロックが順序付けられた実Schur分解
%
% [V,T,M] = BLKRSCH(A,ODTYPE,CUT)は、実数正方行列Aの実ブロック順の分解を
% 行います。
%
%               V'AV = T = |B1  B12|
%                          | 0   B2|
%
%               B1 = T(1:CUT,1:CUT)
%               B2 = T(CUT+1:END,CUT+1:END)
%                M = 安定な固有値数 (s またはz平面)
%
% 6種類の順番が選択できます。
%         odtype = 2 または 3 --- Re(eig(B1)) > Re(eig(B2))
%         odtype = 1 または 4 --- Re(eig(B1)) < Re(eig(B2))
%         odtype = 5 --- abs(eig(B1)) > abs(eig(B2))
%         odtype = 6 --- abs(eig(B1)) < abs(eig(B2))
%
%  ODTYPE <3 & NARGIN<3の場合、CUTのデフォルトは、つぎのようになります。
%         odtype = 1 --->   CUT = M
%         odtype = 2 --->   CUT = size(A,1)-M



% Copyright 1988-2002 The MathWorks, Inc. 
