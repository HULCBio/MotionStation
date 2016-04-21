% DECIMATE データ列にローパスフィルタを適用し、その後、サンプリングレー
% トの低減(間引き)を行います。
%
% Y = DECIMATE(X,R)は、ベクトルXの長さを1/R(LENGTH(Y) = LENGTH(X)/R)に短
% 縮するように、オリジナルのサンプリングレートを変更します。
%
% DECIMATEは、リサンプルの前に、カットオフ周波数 .8*(Fs/2)/R の8次ローパ
% スChebyshev I型フィルタを適用します。
%
% Y = DECIMATE(X,R,N)は、N次のChebyshevフィルタを使用します。 
%
% Y = DECIMATE(X,R,'FIR')は、Chebyshev フィルタの代わりに、30点のFIRフィ
% ルタ(FIR1(30,1/R))を使用します。
%
% Y = DECIMATE(X,R,N,'FIR')は、長さNのFIRフィルタを使用します。 
%
% 注意: 
% Rが大きくなると、数値精度の限界により、Chebyshevフィルタが設計できなく
% なる可能性があります。このような場合、DECIMATE はフィルタ次数を低く設
% 定します。より良いアンチエイリアシングの方法は、Rを各要素に分割して、
% DECIMATEを何回か実行する方法です。
%
% 参考：   INTERP, RESAMPLE.



%   Copyright 1988-2002 The MathWorks, Inc.
