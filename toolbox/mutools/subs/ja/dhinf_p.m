%  function F=dhinf_p(sys,nmeas,ncon,epm1)
%
% 離散時間SYSTEM行列に対して、z=-1に近い極が存在するかを計算し、存在する
% 場合出力フィードバックゲインFを求めるので、極は-1からわずかに移動しま
% す。EPMR1は、MIN(SVD(a+eye))<EPMR1の中で、-1に対する距離のトレランスを
% 与えます。これは、DHFSYNで使われます。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:48 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
