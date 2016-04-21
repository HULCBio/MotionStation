% REGISTEREVENT  実行時に指定したコントロールに対するイベントを登録
%
% REGISTEREVENT(H, USERINPUT) は、H がCOMコントロールのハンドルで、
% USERINPUT が 1xn のキャラクタ配列あるいは文字列からなる mx2 のセル配列である
% 場合にイベントを登録します。 
%
% USERINPUT がキャラクタ配列のときは、コントロールにより登録可能なすべてのイベント
% のイベントハンドラを指定します。たとえば、つぎのようにします。
%
%      registerevent(h, 'allevents')
%
% USERINPUT が文字列からなるセル配列のときは、イベント名とイベントハンドラの組が
% 登録されるイベントを指定します。たとえば、つぎのようにします。 
%
%      registerevent(h, {'Click' 'sampev'; 'Mousedown' 'sampev'})
%   
% 参考 ： UNREGISTEREVENT, EVENTLISTNERS, ACTXCONTROL.



% $Revision: 1.1.6.3 $
% Copyright 1984-2002 The MathWorks, Inc.
