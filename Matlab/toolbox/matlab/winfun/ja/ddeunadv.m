% DDEUNADV アドバイザリリンクの解除
% 
% DDEUNADVは、DDEADVによって確立されたMATLABとサーバアプリケーション
% 間のアドバイザリリンクを解除します。channel,item,formatは、リンクを
% 初期化するDDEADVで指定されたものと同じでなければなりません。timeout
% 引数を指定して、format引数はデフォルト値を用いる場合は、format引数を
% 空行列として指定しなければなりません。
%
% rc = DDEUNADV(channel,item,format,timeout)
%
% rc      返り値: 0は失敗、1は成功を意味します。
% channel DDEINITからの通信チャンネル。
% item    アドバイザリリンクに対するDDEアイテム名を指定する文字列。
% format  (オプション的に)アドバイザリリンクのためのデータ形式を指定する
%         2要素の配列。アドバイザリリンクを設定するための関数DDEADVで
%         format引数を指定した場合、DDEUNADVでも同じ値を指定しなければ
%         なりません。配列の形式は、DDEADVを参照のこと。
% timeout (オプション的に)オペレーションの制限時間を指定するスカラ値。制
%         限時間は、1000分の1秒単位で指定します。デフォルト値は、3秒です。
%
% たとえば、ddeadvの例題で確立したホットリンクを解除します。
% 
%    rc = ddeunadv(channel, 'r1c1:r5c5');
% 
% formatはデフォルト値、timeoutは値を指定して、ホットリンクを解除します。
% rc = ddeunadv(chan, 'r1c1:r5c5',[],6000);
%
% 参考 ： DDEINIT, DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:09:47 $
%   Built-in function.
