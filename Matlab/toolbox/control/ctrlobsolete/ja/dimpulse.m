% DIMPULSE   離散時間線形システムのインパルス応答
%
% DIMPULSE(A,B,C,D,IU) は、離散システム
%
%    x[n+1] = Ax[n] + Bu[n]
%    y[n]   = Cx[n] + Du[n]
%
% の入力 IU にインパルスを適用した場合の応答をプロットします。応答を計算
% する点数は、自動的に決められます。
%
% DIMPULSE(NUM,DEN) は、多項式伝達関数  G(z) = NUM(z)/DEN(z) のインパルス
% 応答をプロットします。ここで、NUM と DEN は、多項式の係数を降ベキ順に
% 並べたものです。
%
% DIMPULSE(A,B,C,D,IU,N) または、DIMPULSE(NUM,DEN,N) は、応答を計算する
% 点数 N を設定します。また、左辺に出力引数と設定した場合、
% 
%    [Y,X] = DIMPULSE(A,B,C,D,...)
%    [Y,X] = DIMPULSE(NUM,DEN,...)
% 
% 行列 Y と X に出力と状態の時系列データを出力します。そして、スクリーン上
% にはプロット表示されません。Y は、出力される数の列数をもち、X は状態数と
% 同じ数の列数をもっています。
%
% 参考 : IMPULSE, STEP, INITIAL, LSIM.


%   J.N. Little 4-21-85
%   Revised CMT 7-31-90, ACWG 5-30-91, AFP 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:44 $
