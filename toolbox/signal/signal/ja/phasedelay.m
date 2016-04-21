% PHASEDELAY デジタルフィルタの位相遅延
% [PHI,W] = PHASEDELAY(B,A,N)は、N-点位相遅延応答のベクトルPHIと、
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
% [PHI,W] = PHASEDELAY(B,A,N,'whole') は、単位円全体の周のN 点
% を使用します。
%
% PHI = PHASEDELAY(B,A,W) は、ベクトルWで示されるradians/sample 
% (通常、0 と πの間)の、周波数での位相遅延の応答を出力します。
%
% [PHI,F] = PHASEDELAY(B,A,N,Fs) と [PHI,F] = PHASEDELAY(B,A,N,'whole',Fs)は、
% (Hzで表す)位相遅延のベクトルF を出力します。ここで、Fsは、(Hzで表す)
% サンプリング周波数です。
%   
% PHI = PHASEDELAY(B,A,F,Fs) は、(Hzで表す)ベクトルFで指定される
% 周波数での位相遅延の応答を出力します。 ここで、Fs は、(Hzで表す)
% サンプリング周波数です。
%
% [PHI,W,S] = PHASEDELAY(...)、あるいは、[PHI,F,S] = PHASEDELAY(...) は、
% プロットの情報を出力します。
% S は、構造体であり、そのフィールドは、異なる周波数応答のプロット
% を得るように変更することができます。 
%
% PHASEDELAY(B,A,...)が、出力引数を持たない場合、カレントフィギュア
% ウィンドウにフィルタの位相遅延の応答をプロットします。
%
% 例題 #1:
%     b=fircls1(54,.3,.02,.008);
%     phasedelay(b)
%
% 例題 #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasedelay(b,a,512,'whole')
%

%   Copyright 1988-2002 The MathWorks, Inc.
