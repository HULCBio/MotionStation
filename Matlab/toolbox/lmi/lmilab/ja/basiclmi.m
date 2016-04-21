% X = basiclmi(M,P,Q,option)
%
% つぎのLMIの解Xを計算します。
%
%         M + P' * X * Q + Q' * X' * P < 0
%
% このLMIは、PとQの零空間の基底wPとwQがつぎの条件を満足する場合、可解で
% す。
%
%       wP'*M*wP < 0     かつ    wQ'*M*wQ < 0
%
% これらの条件のいずれかが満足されないならば、X=[]を出力します。
%
% 最小ノルムの解を得るためには、OPTIONを'Xmin'に設定します。
%
% 参考：    FEASP, MINCX.



% Copyright 1995-2002 The MathWorks, Inc. 
