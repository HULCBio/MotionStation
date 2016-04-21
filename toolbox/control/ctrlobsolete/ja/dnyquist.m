% DNYQUIST   離散時間線形システムに対する Nyquist周波数応答
%
% DNYQUIST(A,B,C,D,Ts,IU) は、入力 IU からシステム
%                                                    -1
%      x[n+1] = Ax[n] + Bu[n]    G(w) = C(exp(jwT)I-A) B + D  
%      y[n]   = Cx[n] + Du[n]    RE(w) = real(G(w)), IM(w) = imag(G(w))
%
% のすべての出力までの Nyquist線図を作成します。周波数の範囲と点数は、
% 自動的に求まります。
%
% DNYQUIST(NUM,DEN,Ts) は、多項式伝達関数 G(z) = NUM(z)/DEN(z) に対する 
% Nyquist線図を作成します。ここで、NUM と DEN は、多項式の係数を z の
% 降ベキの順に並べたものです。
%
% DNYQUIST(A,B,C,D,Ts,IU,W) または、DNYQUIST(NUM,DEN,Ts,W) は、Nyqusit
% 応答を計算する周波数点を示すベクトル W を設定します。単位は、rad/sec 
% です。エリアジングは、Nyquist 周波数(pi/Ts)より高い周波数で生じます。
% 左辺に出力引数を設定しない場合、
% 
%    [RE,IM,W] = DNYQUIST(A,B,C,D,Ts,...)
%    [RE,IM,W] = DNYQUIST(NUM,DEN,Ts,...) 
% 
% 計算した周波数ベクトル W と行列 RE と IM を出力します。これらは、
% 出力数と同じ列数をもち、length(W) に等しい行数をもっています。スクリーン
% 上にプロット表示を行いません。
%
% 参考 : LOGSPACE,MARGIN,DBODE, DNICHOLS.


%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 8-15-89, 2-12-91, 6-21-92
%   Revised Clay M. Thompson 7-9-90, AFP 10-1-94, PG 6-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:53 $
