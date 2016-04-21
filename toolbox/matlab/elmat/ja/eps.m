%EPS  浮動小数点数間距離
% D = EPS(X) は、ABS(X) から X と同じ精度で大きさがつぎに大きな浮動小数点数
% までの正の距離です。X は、倍精度、または、単精度のいずれかになります。
% すべての X に対して、EPS(X) = EPS(-X) = EPS(ABS(X)) です。
%
% EPS は、引数がない場合、1.0 からつぎに大きな倍精度の数までの距離、
% すなわち、EPS = 2^(-52) です。
%
% EPS('double') は、EPS, または、EPS(1.0) と同じです。
% EPS('single') は、EPS(single(1.0)), または single(2^-23) と同じです。
%
% 非正規化数(denormals)を除いて、2^E <= ABS(X) < 2^(E+1) の場合、つぎが成り立ちます。
%      EPS(X) = 2^(E-23) if ISA(X,'single')
%      EPS(X) = 2^(E-52) if ISA(X,'double')
%
%      if Y < EPS * ABS(X)
% という形式の表現を、つぎに置き換えてください。
%      if Y < EPS(X)
%
% 例題:
%      倍精度
%         eps(1/2) = 2^(-53)
%         eps(1) = 2^(-52)
%         eps(2) = 2^(-51)
%         eps(realmax) = 2^971
%         eps(0) = 2^(-1074)
%         if(abs(x)) <= realmin, eps(x) = 2^(-1074)
%         eps(Inf) = NaN
%         eps(NaN) = NaN
%      単精度
%         eps(single(1/2)) = 2^(-24)
%         eps(single(1)) = 2^(-23)
%         eps(single(2)) = 2^(-22)
%         eps(realmax('single')) = 2^104
%         eps(single(0)) = 2^(-149)
%         if(abs(x)) <= realmin('single'), eps(x) = 2^(-149)
%         eps(single(Inf)) = single(NaN)
%         eps(single(NaN)) = single(NaN)
%
% 参考 REALMAX, REALMIN.
%
%   Copyright 1984-2002 The MathWorks, Inc.
