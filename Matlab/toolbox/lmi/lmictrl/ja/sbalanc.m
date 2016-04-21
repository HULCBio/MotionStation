% [a,b,c] = sbalanc(a,b,c,cond)
%     sys = sbalanc(sys,cond)
%
% 対角要素の相似を使って、状態空間実現(A,B,C)を平衡化しスケーリングしま
% す。この実現は、システム行列として設定できます(LTISYSを参照)。
%
% オプション引数CONDは、この相似要素の条件数の上界です。
% (デフォルト = 1.0e8)
%
% 参考：    LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
