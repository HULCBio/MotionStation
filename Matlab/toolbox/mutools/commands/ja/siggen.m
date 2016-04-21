% function y = siggen('function(t)',t)
%
% SIGGENは、時間の関数としてVARYING行列を作成します。'function()'が引数
% の項にあれば、その引数は't'でなければなりません。
%
% 例題:
%
%     y = siggen('sin(t)',[0:pi/100:2*pi]);
%     y = siggen('rand(2,2)',[0:20]);
%
% 参考: COS_TR, SIN_TR, STEP_TR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
