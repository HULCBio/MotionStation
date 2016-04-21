% CLIPBOARD   システムのクリップボードに文字列をコピーしたり、クリップ
% ボードからペーストしたりします。
%
% CLIPBOARD('copy', STUFF) は、クリップボードの内容を STUFF に設定します。
% STUFF がchar 配列として設定されていない場合は、MAT2STR を使って文字列
% に変換します。
%
% STR = CLIPBOARD('paste') は、カレントのクリップボードが文字列に変換でき
% ない場合は、クリップボードのカレントの内容を文字、または '' として出力
% します。 
%
% DATA = CLIPBOARD('pastespecial') は、UNLOAD を使って、配列としてクリップ
% ボードのカレントの内容を出力します。
%
% UnixやJava上での表示には、active Xが必要です。
% 
% 参考： LOAD, FILEFORMATS, UIIMPORT


% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.4.4.1 $  $Date: 2004/04/28 02:07:49 $
