% KEY2INFO　 テーブルから Key を読み込みます。
% [OUT1,OUT2,OUT3] = KEY2INFO(HDL_NORM,HDL_ZERO,KEY,TYP) は、要素 TAB1(index), 
% TAB2(index), TAB3(index) を出力します。ここで、index は、TABX(index) = KEY に
% 対する近似解で、TABX は、入力された typ により指定されたタイプに依存する per-
% fos axes の列から構成されます。
% typ = N は、キーが12ノルムの回収値(recovery Value)であることを意味します。
% typ = Z は、キーが多くのゼロ値であることを意味します。
% typ = T は、キーがスレッシュホールド値であることを意味します。
% TAB1、TAB2、TAB3 は、lin_norm や lin_zero というハンドルをもつ列の Xdata また
% は Ydata から、キーの値に従って構成されます。TAB1, TAB2 および TAB3 は、同じ長
% さをもつものとして仮定されます。
%
% 参考： WCMPSCR, WPCMPSCR.



%   Copyright 1995-2002 The MathWorks, Inc.
