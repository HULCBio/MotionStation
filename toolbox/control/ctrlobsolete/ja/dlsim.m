% DLSIM   離散時間線形システムのシミュレーション
%
% DLSIM(A,B,C,D,U) は、離散システム 
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% に入力列 U を適用した場合の時間応答をプロットします。行列 U は、入力 u 
% の数と同じ列数をもっています。U の各行は、計算する新しい時間点に対応
% します。DLSIM(A,B,C,D,U,X0) は、初期条件 X0 が設定されている場合に
% 使用します。
%
% DLSIM(NUM,DEN,U) は、伝達関数記述 G(z) = NUM(z)/DEN(z) の時間応答を
% プロットします。ここで、NUM と DEN は、多項式の係数で、z の降ベキの
% 順に並べたものです。LENGTH(NUM) = LENGTH(DEN) の場合、DLSIM(NUM,DEN,U) 
% は、FILTER(NUM,DEN,U) と同じです。左辺に引数を設定していない場合、
% 
%    [Y,X] = DLSIM(A,B,C,D,U)
%    [Y,X] = DLSIM(NUM,DEN,U)
% 
% 行列 Y と X に出力と状態の時系列を出力し、スクリーン上にプロットを
% 行いません。Y は、出力数と同じ列数で、LENGTH(U)の行数をもっています。
% X は、状態数と同じ列数で、LENGTH(U) と同じ行数をもっています。
%
% 参考 : LSIM, STEP, IMPULSE, INITIAL.


%   J.N. Little 4-21-85
%   Revised 7-18-88 JNL
%   Revised 7-31-90  Clay M. Thompson
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:49 $
