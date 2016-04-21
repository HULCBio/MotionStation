% XPCWWWENABLE は、xPC Target  WWW インタフェースの使用を可能にします。
% 
% XPCWWWENABLE は、xPC Target  WWW インタフェース経由のターゲットシステム
% へのアクセスを可能にするために BootFloopy モードと DOSLoader(組み込みオ
% プション)モードで使われなければなりません。ユーザがアクセス可能か否かは
% っきりしない場合、この関数を実行してみてください。
% 
% これが必要とされる理由は、ターゲットシステムは、MATLAB 経由か、または、
% WWW インタフェースのいずれかでのみ TCP/IP 接続を維持するからです。結果と
% して、接続が MATLAB で稼動状態にあるとき、インターネットブラウザは、前の
% 接続がタイムアウトするまで、接続することはできません。XPCWWWENABLE を実
% 行は、接続をリセットし、新しい通信の接続を許可します。
% 
% WWW インタフェースで、ターゲットシステムにアクセスするには、Microsoft 
% Internet Explorer(バージョン 4.0以上)、または、Netscape Navigator(バージ
% ョン 4.5 以上)のいずれかを使ってください。Javascript は 、WWW インタフェ
% ースの適切な関数に対して使用可能になります。接続するための URL はつぎの
% ものです。
% 
%      http://<target IP address>:<target port>/
% 
% たとえば、IP アドレス 192.168.0.1 をターゲットシステムに割り当て、ポート
% 番号 2222(デフォルト)を使う場合、WWW ブラウザを、つぎのURL に設定しなけ
% ればなりません。
% 
%      http://192.168.0.1:22222/
% 
% IP アドレスとポート値は、xPC Environment プロパティ TcpIpTargetAddressと
% TcpIpTargetPort(MATLAB コマンド GETXPCNEW を通して、アクセス可能)にスト
% アされます。
% 
% 参考： GETXPCENV.

%   Copyright 1994-2002 The MathWorks, Inc.
