% VERCTRL   PCプラットフォーム上でのバージョン管理操作
%
% List = VERCTRL('all_systems') は、カレントのマシンにインストールされている
% すべてのバージョン管理システムの一覧を出力します。
% 
% fileChange = VERCTRL(COMMAND,FILENAMES,HANDLE) は、FILENAMES の COMMAND 
% で指定されるバージョン管理操作を行います。これは、ファイルからなるセル配
% 列です。HANDLE は、ウィンドウのハンドルです。これらのコマンドは、ディスク
% 上のファイルが変更された場合、ワークスペースに論理値1を、変更されていない
% 場合、0を返します。
% FILENAMES 引数で利用可能なCOMMANDの値は以下の通りです。
% 
%     'get'           表示およびコンパイルのためにファイル(単数または
%                     複数)を取得しますが、編集は行いません。(単数または
%                     複数の)ファイルは、参照のみです。ファイルの一覧は、
%                     ファイルまたはディレクトリのいずれかを含みますが、
%                     両方は含みません。 
% 
%     'checkout'      (単数または複数の)ファイルを編集用に取得します。 
%
%     'checkin'       (単数または複数の)ファイルをバージョン管理システム
%                     でチェックします。変更を保存して新バージョンを作成
%                     します。                        
%
%     'uncheckout'    前のチェックアウト操作をキャンセルし、選択された
%                     単数または複数のファイルの内容をprecheckoutバージョン
%                     にリストアします。チェックアウト後に行われたすべて
%                     のファイルに対する変更は失われます。
%
%     'add' 	      バージョン管理システムにファイルを追加します。 
%                       
%
%     'history'       ファイルの履歴を表示します。
%
% VERCTRL(COMMAND,FILENAMES,HANDLE) は、ファイルのセル配列である FILENAMES
% の COMMAND で指定されたバージョン管理システムを実行します。
% HANDLE は、ウィンドウのハンドルです。
% FILENAMES 引数で利用可能な COMMAND の値は、以下の通りです。
% 
%     'remove'         バージョン管理システムからファイルを削除します。
%                      ユーザのローカルハードドライブからはファイルを
%                      削除しません。バージョン管理システムからのみです。
%
% fileChange = VERCTRL(COMMAND,FILE,HANDLE) は、一つのファイルである FILE の
% COMMAND で指定されたバージョン管理システムを実行します。HANDLE は、ウィン
% ドウのハンドルです。これらのコマンドは、ディスク上のファイルが変更された
% 場合、ワークスペースに論理値1を、変更されていない場合、論理値0を返します。
% FILENAMES 引数で利用可能な COMMAND の値は、以下の通りです
%
%     'properties'     ファイルのプロパティを表示します。
%                      
%     'isdiff'         ファイルをバージョン管理システム内のファイルの
%                      最新チェックバージョンと比較します。ファイルが
%                      異なる場合は1を出力し、ファイルが同一である
%                      場合は0を出力します。
%
% VERCTRL(COMMAND,FILE,HANDLE) は、一つのファイルである FILE の COMMAND で
% 指定されたバージョン管理システムを実行します。HANDLE は、ウィンドウの
% ハンドルです。
% FILENAMES 引数で利用可能な COMMAND の値は、以下の通りです
%                      
%     'showdiff'       ファイルとバージョン管理システム内の最新チェック
%                      バージョンのファイルの差分を表示します。 
% 
% この関数は、PCプラットフォーム上の異なるバージョン管理コマンドをサポート
% します。HANDLE引数をもつバージョン管理コマンドを呼び出す前にウィンドウを
% 作成し、ハンドルを取得する必要があります。ウィンドウ作成の基本的な例題を
% 以下に示します。 
% 
% 例題:
% Javaウィンドウを作成し、ハンドルを取得します。
%    import java.awt.*;
%	 frame = Frame('Test frame');
%	 frame.setVisible(1);
%	 winhandle = com.mathworks.util.NativeJava.hWndFromComponent(frame)
%  
%     winhandle =
%
%         919892 
%
% マシンにインストールされているすべてのバージョン管理システムの一覧をコマ
% ンドウィンドウに出力します。.
%   List = verctrl('all_systems')
%   List =     
%               'Microsoft Visual SourceSafe'
%               'Jalindi Igloo'
%               'PVCS Source Control'
%               'ComponentSoftware RCS'   
% 
% バージョン管理システムから D:\file1.ext をチェックアウトします。
% このコマンドは、'checkout' ウィンドウをオープンし、ディスク上のファイルが
% 変更されていればワークスペースに論理値1を、変更されていなければ0を返します。
%   fileChange = verctrl('checkout',{'D:\file1.ext'},winhandle)
%     
% バージョン管理システムに D:\file1.ext と D:\file2.ext を追加します。
% このコマンドは、'add' ウィンドウをオープンし、ディスク上のファイルが
% 変更されていればワークスペースに論理値1を、変更されていなければ0を
% 返します。
%   fileChange = verctrl('add',{'D:\file1.ext','D:\file2.ext'},winhandle)
%     
% D:\file1.ext のプロパティを表示します。このコマンドは、'properties' 
% ウィンドウをオープンし、ファイルが変更されていてリロードする必要がある
% 場合は、コマンドウィンドウに1を出力します。
%   fileChange = verctrl('properties','D:\file1.ext',winhandle)
%   
% 参考 ： CHECKIN,CHECKOUT,UNDOCHECKOUT,CMOPTS 


  
%   Copyright 1998-2002 The MathWorks, Inc.
