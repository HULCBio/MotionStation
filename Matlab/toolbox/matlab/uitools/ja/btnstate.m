% BTNSTATE   ツールバーボタングループの状態の確認
% 
% STATE = BTNSTATE(FIGHANDLE, GROUPID, BUTTONID) は、FIGHANDLE で
% 識別されるfigure内で、文字列 GROUPID で指定されるボタングループ内の、
% 文字列 BUTTONID で指定されるボタンの状態を出力します。STATE = 1 は、
% ボタンダウンされていることを示します。STATE = 0 は、ボタンアップされて
% いることを示します。
%
% STATE = BTNSTATE(FIGHANDLE, GROUPID, BUTTONNUM) は、スカラ BUTTONNUM 
% で指定されたボタンの状態を出力します。ボタン番号は、ボタングループの
% 列に従って番号付けられます。
%
% STATE = BTNSTATE(FIGHANDLE, GROUPID) は、ボタングループ内の、すべて
% のボタンの状態を含む状態ベクトルを出力します。
%
% BTNSTATE('set', FIGHANDLE, GROUPID, STATE) は、ベクトル STATE 内の値に
% 従って、指定したボタングループの状態を設定します。
%
% 参考： BTNGROUP, BTNPRESS, BTNDOWN, BTNUP, BTNRESIZE.


%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:46 $
