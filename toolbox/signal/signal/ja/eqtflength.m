% EQTFLENGTH は、離散時間伝達関数の長さを等しくします。
% [B,A] = EQTFLENGTH(NUM,DEN) は、伝達関数 NUM と DEN に対して、必要
% ならば、どちらかにゼロを付加して同じ長さにします。NUM と DEN が、
% 共通するゼロを各係数の後半にもっている場合、それらをお互いから
% 取り去ります。
%
% EQTFLENGTH は、離散時間伝達関数のみで使用する目的で作られています。
%
%   [B,A,N,M] = EQTFLENGTH(NUM,DEN) は、ゼロを後ろに付加せず、
%   分子次数Nと分母次数Mを返します。



%   Copyright 1988-2002 The MathWorks, Inc.
