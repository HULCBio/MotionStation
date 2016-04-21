% UNIX   UNIXコマンドの実行と結果の出力
% 
% [status,result] = UNIX('command') は、UNIXシステムにおいて、与えられた
% command を実行するためにオペレーティングシステムを呼び出します。結果
% のステータスと標準出力が出力されます。
%
% 例題:
%
%     [s,w] = unix('who')
%
% は、s = 0 と、現在ログインしているユーザのリストを含むMATLAB文字列を w に
% 出力します。
%
%     [s,w] = unix('why')
%
% は、'why' はUNIXコマンドではないため、実行の失敗を表わす非ゼロの値を s
% に、そして w を空行列に設定します。
%
%     [s,m] = unix('matlab')
%
% は、MATLABの2つ目のコピーの実施が、許可されていない対話的なユーザ
% 入力を必要とするので、何も出力しません。
% 
% 参考： SYSTEM, PUNCT の下での ! (感嘆符) 


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:41 $
%   Built-in function.
