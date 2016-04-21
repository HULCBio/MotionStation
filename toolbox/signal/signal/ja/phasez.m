% PHASEZ デジタルフィルタ位相応答
% [PHI,W] = PHASEZ(B,A,N) は、N-点unwrapped位相応答のベクトルPHIと、
% フィルタのradians/sampleでのN-点周波数ベクトルW を出力します。
% フィルタは、ベクトルBとA で与えられた分子と分母の係数で与えられます。 
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
% 位相応答は、単位円の上半周に等間隔に並ぶ N 点で評価されます。
% N を指定しない場合、デフォルトは、512です。
%
% [PHI,W] = PHASEZ(B,A,N,'whole') は、単位円の全周のN点を使用します。
%
% PHI = PHASEZ(B,A,W) は、ベクトルWで示されるradians/sample 
% (通常、0 とπの間)の、周波数での位相応答を出力します。
%
% [PHI,F] = PHASEZ(B,A,N,Fs) と [PHI,F] = PHASEZ(B,A,N,'whole',Fs) は、 
% (Hzで表す)位相ベクトルF を出力します。ここで、Fs は、(Hzで表す)
% サンプリング周波数です。
%   
% PHI = PHASEZ(B,A,F,Fs) は、(Hzで表す)ベクトルFで、指定する周波数
% での位相応答を出力します。 ここで、Fs は、(Hzで表す)サンプリング周波数です。
%
% [PHI,W,S] = PHASEZ(...) あるいは [PHI,F,S] = PHASEZ(...) は、プロット
% の情報を出力します。 S は、構造体であり、そのフィールドは、異なる周波数
% 応答のプロットを得るように変更することができます。 
%
% PHASEZ(B,A,...)が、出力引数を持たない場合、フィルタのunwrapped phase
% をプロットします。
%
% 例題 #1:
%     b=fircls1(54,.3,.02,.008);
%     phasez(b)
%
% 例題 #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasez(b,a,512,'whole');
%
% 参考 FREQZ, PHASEDELAY, GRPDELAY, FVTOOL.

%   Copyright 1988-2002 The MathWorks, Inc.
