% RCOSIIR   コサインロールオフ IIR フィルタを設計します。
%
% [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL) は、設定したロールオフ
% ファクタ R をもつ FIR コサインロールオフフィルタに近似した IIR コサイン
% ロールオフフィルタを設計します。T_DELAY は、T の整数倍の遅れを設定します。
% RATE は、各区間 T の中での標本数であるか、または、フィルタの標本化
% レートが T/RATE を満足するかのどちらかで定義されます。デフォルト値は
% RATE が5、T はシンボル間隔です。IIR フィルタの次数は、TOL が1より大きい
% 整数の場合、TOL で決定されます。TOL が1より小さい場合、これは、次数の
% 選択での SVD 計算の相対許容誤差と考えられます。TOL のデフォルト値は、
% 0.01 です。コサインロールオフフィルタの時間応答は、つぎの型をして
% います。
%
%       h(t) = sinc(t/T) cos(pi R t/T)/(1 - 4 R^2 t^2 /T^2)
%
% 周波数領域では、つぎのスペクトルをしています。
%
%         / T                                 0 < |f| < (1-r)/2/T のとき
%         |         pi T         1-R    T     1-R         1+R
% H(f) = < (1 + cos(----) (|f| - ----) ---    --- < |f| < --- のとき
%         |           r           2T    2     2 T         2 T
%         \ 0                                 |f| > (1+r)/2/T のとき
%     
% [NUM, DEN] = RCOSIIR(R, T_DELAY, RATE, T, TOL, FILTER_TYPE) は、
% FILTER_TYPE == 'sqrt' の場合、等価な FIR ルートコサインロールオフ
% フィルタの IIR 近似を設計します。
%     
% RCOSIIR(...) は、コサインロールオフフィルタの時間応答と周波数応答を
% プロットします。
%     
% RCOSIIR(..., COLOR) は、文字変数 COLOR で設定したカラーを使って、時間
% 応答と周波数応答をプロットします。COLOR の中の文字列は、PLOT で設定
% できるタイプのものです。
%     
% [NUM, DEN, SAMPLE_TIME] = RCOSIIR(...) は、IIR フィルタとフィルタの
% 標本時間を出力します。
% 
% 参考： RCOSFIR, RCOSFLT, RCOSINE, RCOSDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
