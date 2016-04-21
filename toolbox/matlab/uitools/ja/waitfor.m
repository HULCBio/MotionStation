% WAITFOR   実行を停止し、イベントを待ちます
% 
% WAITFOR(H) は、ハンドル番号で識別されるグラフィックスオブジェクトが
% 消去されるときに出力します。ハンドル番号が存在しない場合、waitfor は、
% どのイベントも処理せずに、すぐに出力します。
%
% WAITFOR(H,'PropertyName') は、前のシンタックスでの条件に加えて、グラ
% フィックスオブジェクトの 'PropertyName' の値が変更されるときに出力します。
% 'PropertyName' が、オブジェクトの有効なプロパティでない場合は、waitfor
% は、どのイベントも処理せずに、すぐに出力します。
%
% WAITFOR(H,'PropertyName',PropertyValue) は、前のシンタックスでの条件に
% 加えて、グラフィックスオブジェクトの 'PropertyName' の値が PropertyValue
% に変更されるときに出力します。'PropertyName' が、PropertyValue に設定
% された場合、waitfor はどのイベントも処理せずに、すぐに出力します。
%
% waitfor は実行ストリームを中断する一方で、コールバックを実行しながら、
% drawnow のようにイベントを処理します。waitfor へのネスティングされた
% 呼び出しがサポートされています。以前に行った呼び出しが中断している条件が
% 満たされても、残りの呼び出しが出力するまで、以前に行った waitfor の
% 呼び出しは出力しません。
%
% 参考：DRAWNOW, UIWAIT, UIRESUME.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:12 $
%   Built-in function.
