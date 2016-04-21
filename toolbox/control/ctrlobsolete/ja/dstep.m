% DSTEP   離散時間線形システムのステップ応答
%
% DSTEP(A,B,C,D,IU) は、離散システム
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% の単入力 IU にステップを適用した場合の応答をプロットします。入力数は、
% 自動的に決まります。
%
% DSTEP(NUM,DEN) は、多項式伝達関数 G(z) = NUM(z)/DEN(z) のステップ応答を
% プロットします。ここで、NUM と DEN は、多項式の係数で、z の降ベキの順に
% 並べたものです。
%
% DSTEP(A,B,C,D,IU,N) または、DSTEP(NUM,DEN,N) は、計算する周波数点数 
% N をユーザが設定します。左辺に出力引数を設定しない場合、
% 
%    [Y,X] = DSTEP(A,B,C,D,...)
%    [Y,X] = DSTEP(NUM,DEN,...)
% 
% 行列 Y と X に出力と状態の時系列を出力し、スクリーン上にプロット表示
% されません。Y は、出力数と同じ列数で、X は、状態数と同じ列数をもって
% います。
%
% 参考 : STEP, IMPULSE, INITIAL, LSIM.


%   J.N. Little 4-21-85
%   Revised JNL 7-18-88, CMT 7-31-90, ACWG 6-21-92
%   Revised A. Potvin 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:57 $
