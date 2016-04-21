%WEB Webブラウザでサイトまたはファイルを開く
% WEB は、空の内部 web ブラウザを開きます。デフォルトの内部 web ブラウザには、
% 標準の web ブラウザアイコンをもつツールバーと、カレントのアドレスを示す
% アドレスボックスがあります。
%
% WEB URL は、指定したURL(Uniform Resourde Locator) を内部 Web ブラウザに
% 表示します。1つまたは複数の内部 web ブラウザがすでに実行している場合、
% 最近のアクティブブラウザ (最も最近にフォーカスされたことで決まります) が、
% 再使用されます。URL が docroot の下にある場合、自動的にヘルプブラウザ内 
% に表示されます。
%
% WEB URL -NEW は、新しい内部の web ブラウザウィンドウに指定した URL を
% 表示します。
%
% WEB URL -NOTOOLBAR は、内部 web ブラウザに、ツールバー (と address box) 
% がない状態で、指定した URL を表示します。
%
% WEB URL -NOADDRESSBOX は、内部 web ブラウザに、address box がない
%(標準 web ブラウザアイコンがあるツールバーはある)状態で、指定した
% URL を表示します。
%
% WEB URL -HELPBROWSER は、ヘルプブラウザに指定した URL を表示します。
%
% STAT = WEB(...) -BROWSER は、WEB コマンドのステータスを変数 STAT に
% 出力します。STAT= 0 は、正常終了したことを示します。STAT = 1 は、
% ブラウザが見つからなかったことを示します。STAT = 2 は、ブラウザが
% 見つかったが、起動できなかったことを示します。
%
% [STAT, BROWSER] = WEB は、最も最近アクティブになったブラウザの状態と
% ハンドルを出力します。
%
% [STAT, BROWSER, URL] = WEB は、最も最近アクティブになったブラウザの
% 状態とハンドル、および、カレント位置の URL を出力します。
%
% WEB URL -BROWSER は、System Web ブラウザをオープンして、URL (Uniform 
% Resource Locator) で指定した Web サイトやファイルをロードします。
% URLは、ユーザのブラウザがサポートできる任意の形式です。一般に、ローカル
% ファイルやインターネット上のWebサイトを指定することができます。 UNIX (Mac 
% は含まない) 上では、使用する Web ブラウザは、DOCOPT M-ファイルの中で設定
% されています。Windows と Macintosh 上では、Web ブラウザはオペレーティング
% システムで決定されます。
%
% 例題:
%      web file:///disk/dir1/dir2/foo.html
%         は、内部ブラウザにファイル foo.html を開きます。
%
%      web(['file:///' which('foo.html')]);
%         は、ファイルがMATLABパス上にあれば foo.html を開きます。
%
%      web('text://<html>Hello World</html>');
%         は、内部ブラウザ内に、html formatted text を開きます。
%
%      web('http://www.mathworks.com', '-new');
%         は、新しい内部ブラウザにThe MathWorks Webページを開きます。
%
%      web('http://www.mathworks.com', '-new', '-notoolbar');
%         は、新しい内部ブラウザに、ツールバー または address box がない状態で、

%　　　　 The MathWorks Web page をロードします。
%
%      web('file:///disk/helpfile.html', '-helpbrowser');
%         は、ヘルプブラウザにファイル helpfile.html を開きます。
%
%      web('file:///disk/dir1/dir2/foo.html', '-browser');
%         は、システムブラウザに ファイル foo.html を開きます。
%
%      web mailto:email_address
%         は、システムブラウザを使って電子メールを送信します。
%
% 参考 DOC, DOCOPT.

%   Copyright 1984-2004 The MathWorks, Inc.
