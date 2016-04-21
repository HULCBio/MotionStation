% UNREGISTEREVENT  実行時に指定したコントロールのイベントの登録を解除
%
% UNREGISTEREVENT(H, USERINPUT) は、H がCOMコントロールのハンドルで、 
% USERINPUT がキャラクタ配列あるいは文字列からなるセル配列である場合
% にイベントの登録を解除します。
%
% USERINPUT がキャラクタ配列のとき、すべてのイベントは、指定したファイル
% から削除されます。
%    unregisterevent(h, 'sampev')
%      - hのすべてのイベントをファイルsampev.mから削除
%
% USERINPUT が文字列からなるセル配列のとき、USERINPUTは有効なイベント名
% と登録を解除されるイベントハンドラを含む必要があります。たとえば、つぎ
% のようになります。
%
%    unregisterevent(h, {'Click' 'sampev'; 'dblclick' 'sampev})
%      
% 参考 ： REGISTEREVENT, EVENTLISTENERS.



% $Revision: 1.1.6.3 $
% Copyright 1984-2002 The MathWorks, Inc.
