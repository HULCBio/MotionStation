% function resp = genphase(d,discflg)
%
% 複素セプストラム(Oppenheim & Schafer, Digital Signal Processing, pg 
% 501)を使って、複素周波数応答RESPを生成します。このゲインは、実数の正の
% 応答Dと等しく、その位相は安定な最小位相関数に対応します。DとRESPの両方
% ともVARYING行列です。
%
% DISCFLG==1(デフォルト=0)の場合、すべての周波数データは、単位円データと
% して解釈され、RESPは離散時間として解釈されます。DISCFLG==0の場合、周波
% 数データは、虚数軸として解釈され、RESPは連続時間として解釈されます。
%
% 参考: FITMAG, FITSYS, MAGFIT, MSF.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
