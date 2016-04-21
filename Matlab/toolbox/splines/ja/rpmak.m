% RPMAK   rp型の有理スプラインの組立て
%
% RPMAK(BREAKS,COEFS), RPMAK(BREAKS,COEFS,D), RPMAK(BREAKS,COEFS,SIZEC) 
% はすべて、3番目の入力引数が存在するかどうかで解釈された COEFS を伴った
% 入力によって指定された有理スプラインのrp-型を出力します。
%
% 有理スプラインのrp-型として標識されること、すなわち、分母がスプライン
% の最終要素によって与えられ、分子が残る要素で記述されるような有理スプ
% ラインであることを除いて、これは、厳密に RPMAK(BREAKS,COEFS), 
% RPMAK(BREAKS,COEFS,D+1), RPMAK(BREAKS,COEFS,SIZEC) の出力です。
%
% 特に、入力の係数は、いくらかの d>0 に対して(d+1)要素のベクトル値で
% なければならず、N次元の値をもったものにはなりません。
%
% 例えば、ppmak([-5 5],[1 -10 26]) は、区間 [-5 .. 5] で多項式 t |-> t^2+1 
% のpp-型を与える一方、ppmak([-5 5], [0 0 1]) は、2次の多項式 t |-> 1 の
% pp-型を与えます。そこで、コマンド
%
%      runge = rpmak([-5 5],[0 0 1; 1 -10 26],1);
%
% は、等間隔のサイトでの多項式の補間に関するRungeの例題で有名な有理関数 
% t |-> 1/(t^2+1) に対する区間 [-5 .. 5] でのrp-型を与えます。
%
% 参考 : RPBRK, RSMAK, PPMAK, SPMAK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
