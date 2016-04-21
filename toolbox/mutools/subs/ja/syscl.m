% function sysout = syscl(sys)
%
% SYSCLは、台形相似変換を使って、ゼロである(Aの対角から離れている)行およ
% び列を削除して、その後の計算で誤差を減らすために状態空間実現をスケーリ
% ングします。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:56 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
