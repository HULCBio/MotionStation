% changeNotification   Windows 9x/NT ディレクトリ変更の通知
%
% MATLABは、関連するディレクトリ内のファイルが変更されたことをMATLABに通
% 知するWindowsのChange Notification Handleの機能を使用します。ある種の
% 状況下では、Windowsは有効な反応のハンドルをMATLABに与えないことがあ
% ります。主な原因は、つぎの3つです。
%
%  * Windowsは、notification handleを使い果たしました。
%
%  * 指定したディレクトリが、change notificationをサポートしないファイル
%    システムに存在します。SAMBA ファイルサーバがフリーで配布している
%    Syntax TAS ファイルサーバと多くのNFSファイルサーバは、この制限をも
%    つことが知られています。
%
%  * ネットワークまたはファイルサーバが潜在的にchange notificationの到着
%    を遅らせるために、変更がタイムリーに検出されません。
%
% MATLABが対応するChange Notification Handleを得ることができないときは、
% ディレクトリとファイルに対する変更を自動的に検出することができません。
% たとえば、ディレクトリに追加された新規のファイルは可視ではなく、メモリ
% 内で変更された関数はリロードされません。
%
% ファイルシステムが、UNIXスタイルのディレクトリのタイムスタンプの更新を
% サポートしている(つまり、ディレクトリのタイムスタンプは、ファイルがデ
% ィレクトリに追加されるときに更新される)の場合、つぎのコマンドのいずれ
% かまたは両方をmatlabrc.mファイルに追加して、ディレクトリのタイムスタン
% プをテストすることによって変更を検出します。
%
%      system_dependent RemotePathPolicy TimecheckDirFile;
%      system_dependent RemoteCWDPolicy  TimecheckDirFile;
%
% 変更が検出される一方で、タイムスタンプのチェックのために時間が必要なの
% で、性能が低下する場合があります。
%
% ファイルシステムが、(NTのファイルシステムのように)UNIXスタイルのディレ
% クトリのタイムスタンプの更新をサポートしないの場合、つぎのコマンドのい
% ずれかまたは両方をmatlabrc.mファイルに追加して、頻繁に生じる間隔で影響
% を受けたディレクトリを再読み込みすることによって、強制的に変更を検出し
% ます。
%
%      system_dependent RemotePathPolicy Reload;
%      system_dependent RemoteCWDPolicy  Reload;
%
% 変更が検出される一方で、ディレクトリの再読み込みのために時間が必要なの
% で、性能が大きく低下する場合があります。
%
% 警告メッセージを表示させたくない場合は、つぎのコマンドをmatlabrc.mに記
% 述することですべての警告を抑制することが出来ます。
%
%    system_dependent DirChangeHandleWarn Never;
% 
% 参考：changeNotificationAdvanced, ADDPATH.



% $Revision: 1.9 $
%   Copyright 1984-2002 The MathWorks, Inc. 
