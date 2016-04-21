% ORIENT   印刷用紙の方向の設定
% 
% ORIENT は、印刷用にFigureまたはモデルウィンドウの方向を設定するのに
% 使います。
% 
% ORIENT LANDSCAPE は、カレントのfigureウィンドウからのつぎのPRINT操作
% で、用紙のフルページのlandscape方向に出力します。
% 
% ORIENT ROTATED は、カレントFigureウィンドウからのつぎのPrintで、用紙
% のフルページの rotate 方向に出力します。
% 
% ORIENT PORTRAIT は、カレントのFigureウィンドウからのつぎのPRINTの操作
% で、portrait 方向に出力します。
% 
% ORIENT TALL は、それに続く PRINT 操作のために、figureウィンドウを
% portrait方向にページ全体に写像します。
% 
% ORIENT自身では、カレントFigureの用紙の方向に関して、PORTRAIT、
% LANDSCAPE、TALLのいずれかを含む文字列を出力します。
%
% ORIENT(FIGHandle) または ORIENT(MODELName)は、figureまたはモデルの
% カレント方向を出力します。
% 
% ORIENT(FIG,ORIENTATION) は、上で与えたルールに従って、どのFigureを
% どの方向に設定するかを指定します。ORIENTATION は、'landscape'、
% 'portrait'、'rotated'、'tall' のいずれかです。
% 
% ORIENT(SYS,ORIENTATION) は、上で与えられたルールに従って、どのSimulink
% モデルやシステムをどの方向に設定するかを指定します。
% 
% この関数の詳細については、つぎのコマンドをMATLABコマンドウィンドウで
% 入力してください。
%
%      type orient.m
% 
% 参考：PRINT.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:03 $
