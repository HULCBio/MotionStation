% INMEM   メモリ内の関数のリスト
% 
% M = INMEMは、P-コードバッファにあるM-ファイル名を含む文字列からなる
% セル配列を出力します。
%
% [M,MEX] = INMEMは、ロードされているMEXファイル名を含むセル配列も出力
% します。
%
% [M,MEX,J] = INMEMは、ロードされているJavaクラスの名前を含むセル配列を
% 出力します。
% 
% 例題
%    clear all % ワークスペースを白紙の状態にして開始
%    erf(.5)
%    m = inmem
% は、erfを実行するために必要なM-ファイルをリストします。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:08 $
%   Built-in function.

