% function normtest = compnorm(T,invT,S,s,h);
%
%
% サンプル化されたデータの圧縮されたノルムが1よりも大きいかどうかをチェ
% ックするために SDHFSYNおよびSDHFNORMから呼び出されます。
%
% 圧縮されたノルムが1よりも小さい場合、NORMTEST は1です。圧縮されたノル
% ムが1 以上の場合、NORMTESTは0です。
%
% 入力データは、HAM2SCHRからの出力です。
%
%% 189 %%%%%%%%%%%%%%%

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:39 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
