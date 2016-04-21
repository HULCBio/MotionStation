% UICLEARMODE   カレントの会話型モードのクリア
% 
% UISTATE = UICLEARMODE(FIG) は、figureウィンドウの対話的なプロパティを
% 停止し、構造体 UISTATE に前の状態を出力します。この構造体は、figureの
% WindowButton* 関数とカーソルに関する情報を含みます。また、figureの
% すべての子オブジェクトの ButtonDownFcn に関する情報も含みます。
%
% UISTATE = UICLEARMODE(FIG、FUNCTION [, ARGS]) は、2種類の方法で
% figure FIG の会話的なプロパティを停止します。まず、最初の方法は、アク
% ティブなものが存在する場合に識別し、Figure WindowButtonDown コール
% バックのように、そのイベントハンドルを外すものです。もう1つの方法は、
% UICLEARMODE は、新しいモードに対するdeinstaller として関数 FUNCTION 
% をインストールします。最終的に、UICLEARMODE は、UISUSPEND のように 
% WindowButton* 関数をリセットし、保存されて UIRESTORE に渡される構造体
% に情報を出力します。
%
% UISTATE=UICLEARMODE(FIG,'docontext',...) は、uicontext メニューも
% 停止します。
%
% 例題:
% 
% つぎの関数は、plotedit や rotate3dのような他のモードと共に使う新しい対話
% 型モードを定義します。
%
% これは、myinteractivemode がアクティブになる前に、プロット編集機能や
% rotate3d 機能を止めます。myinteractivemode がアクティブの場合は、
% myinteractive(fig,'off') でプロット編集機能を呼びだすことが出来ます。
% myinteractivemode を呼び出すシンタックスは、つぎのようにします。
% 
%       myinteractivemode(gcf,'on')   % マウスクリックでカレントポイント
%                                     % を表示します。
%   
%   function myinteractivemode(fig,newstate)
%   %MYINTERACTIVEMODE.M
%   persistent uistate;
%      switch newstate
%      case 'on'
%         disp('myinteractivemode: on');
%         uistate = uiclearmode(fig,'myinteractivemode',fig,'off');
%         set(fig,'UserData',uistate,...
%                 'WindowButtonDownFcn',...
%                 'get(gcbf,''CurrentPoint'')',...
%                 'Pointer','crosshair');
%      case 'off'
%         disp('myinteractivemode: off');
%         if ~isempty(uistate)
%            uirestore(uistate);
%            uistate = [];
%         end
%      end
%
%  参考： UISUSPEND, UIRESTORE, SCRIBECLEARMODE.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/28 02:08:54 $
