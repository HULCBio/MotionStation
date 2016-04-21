% GCBF   カレントのコールバックfigureのハンドル番号を取得
% 
% FIG = GCBF は、コールバックがカレントで実行されているオブジェクトを
% 含む figureのハンドル番号を出力します。カレントのコールバックオブジェ
% クトが figureの場合、figureが出力されます。
%
% コールバックを実行していないときは、GCBF は空行列([])を出力します。 
% カレントのfigureがコールバックの実行中に削除された場合は、GCBF は
% 空行列([])を出力します。
%
% GCBF の出力は、GCBO の出力引数である FIGURE と同じです。
%
% 参考：GCBO, GCO, GCF, GCA.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:44 $
