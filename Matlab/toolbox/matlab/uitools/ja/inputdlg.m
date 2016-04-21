% INPUTDLG   入力ダイアログボックス
% 
% ANSWER = INPUTDLG(PROMPT) は、ダイアログボックスを作成し、セル配列
% ANSWERに複数のプロンプトに対するユーザ入力を出力します。プロンプトは、
% 文字列 PROMPT を含むセル配列です。
%
% INPUTDLG は、ユーザが応答するまで、WAITFOR を使って実行を停止します。
% 
% ANSWER = INPUTDLG(PROMPT,TITLE) は、ダイアログのタイトルを指定します。
%
% ANSWER = INPUTDLG(PROMPT,TITLE,NUMLINE) は、各々の答えに対する行数を
% NUMLINE に指定します。NUMLINE は、定数値または1つのPROMPTに対して、入力
% に対して何行のラインが設定されているのかを示す1要素をもつベクトルです。
% NUMLINE は、最初の列が入力フィールドに対して指定する行数、2番目の列が
% 入力フィールドの列数を指定する列数です。
%
% ANSWER = INPUTDLG(PROMPT,NAME,NUMLINE,DEFAULTANSWER) は、各々の PROMPT 
% に対して表示するデフォルトの答えを指定します。DEFAULTANSWERは、PROMPT
% と同じ要素数のセル配列でなければなりません。
%
% ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER,OPTIONS) は、
% その他のオプションを指定します。OPTIONSが'on'にである場合は、ダイアログは
% リサイズ可能です。OPTIONSが構造体の場合が、フィールドResize, WindowStyle, 
% Interpreter が認識されます。Resize は、'on' または 'off'です。WindowStyle 
% は、'normal' または' modal'です。Interpreter は、'none' または 'tex'
% です。Interpreter が'tex'の場合は、プロンプト文字列は、LaTeXを用いて
% 描画されます。
%
% 例題:
%
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  name='Input for Peaks function';
%  numlines=1;
%  defaultanswer={'20','hsv'};
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer);
%
%  options.Resize='on';
%  options.WindowStyle='normal';
%  options.Interpreter='tex';
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer,options);
%
% 参考： TEXTWRAP, QUESTDLG, UIWAIT.


%  Loren Dean   May 24, 1995.
%  Copyright 1998-2002 The MathWorks, Inc.
