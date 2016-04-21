% DRAWTREE　 ウェーブレットパケット分解ツリーの表示
% DRAWTREE(T,D) は、ウェーブレットパケットツリー T を表示します。D は、T に関連
% するデータ構造です。F = DRAWTREE(T,D) は、figure のハンドル番号を出力します。
%
% 適当な Figure オブジェクトのハンドル番号 F に対して、DRAWTREE(T,D,F) を実行す
% ると、Figure ハンドル番号 F のツリー T を描画します。
%
% 例題
%   x = sin(8*pi*[0:0.005:1]);
%   [t,d] = wpdec(x,3,'db2');
%   fig   = drawtree(t,d);
%   %-------------------------------------------------
%   % コマンドライン関数を使って、t または、d を変更
%   %-------------------------------------------------
%   [t,d] = wpjoin(t,d,2);
%   drawtree(t,d,fig);
%
% 参考： READTREE.



%   Copyright 1995-2002 The MathWorks, Inc.
