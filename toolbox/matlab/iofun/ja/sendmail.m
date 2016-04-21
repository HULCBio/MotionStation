% SENDMAIL メールメッセージの送信
% SENDMAIL(TO,SUBJECT,MESSAGE,ATTACHMENTS) は、電子メールを送信します。TO は、
% 1つのアドレスを指定する文字列、または、アドレスのセル配列のいずれかです。
% SUBJECT は、文字列です。MESSAGE は、文字列、または、セル配列のいずれかです。
% 文字列である場合、テキストは、75 文字で自動的にラップします。セル配列で
% ある場合、ラップしませんが各セルは新しいラインを始めます。いずれの場合も、
% char(10) を使用して新しいラインを指定します。ATTACHMENTS は、メッセージ
% とともに送るファイルのリストの文字列のセル配列です。TO と SUBJECT のみ必要
% です。
%
% SENDMAIL は、2つのプリファレンス、メールサーバ "Internet:SMTP_Server", 
% および、電子メールアドレス "Internet:E_mail" に依存します。SENDMAIL を
% 使用する前に、SETPREF によりこれらを設定してください。送信するメール
% サーバを指定するには、 他の電子メールアプリケーションのプリファレンスを
% 調べるか、管理者に相談してください。サーバの名前を探すことができない
% 場合、'mail' と設定すると動作する可能性があります。これらのプリファレンス
% を設定しない場合、SENDMAIL が、環境変数と Windows レジストリを読むことで
% 自動的に決定しようとします。
%
% 例題:
%     setpref('Internet','SMTP_Server','mail.example.com');
%     setpref('Internet','E_mail','matt@example.com');
%     sendmail('user@example.com','Calculation complete.')
%     sendmail({'matt@example.com','peter@example.com'},'You''re cool!', ...
%       'See the attached files for more info.',{'attach1.m','d:\attach2.doc'});
%     sendmail('user@example.com','Adding additional breaks',['one' 10 'two']);
%     sendmail('user@example.com','Specifying exact lines',{'one','two'});

% SMTP プロトコルを直接使用してください。与えられえたメールサーバの SMTP に
% 接続して話します。multipart/mixed メッセージを送信するためには、MIME 
% エンコーディングを使用してください。
%
% RFC 821 は、SMTP 状態コードをリストします。そのドキュメントがインター
% ネットに多数あります。一例として、
% http://www.landfield.com/rfcs/rfc821.html を参照してください。

% Peter Webb, Aug. 2000
% Matthew J. Simoneau, Nov. 2001, Aug 2003
% Copyright 1984-2003 The MathWorks, Inc.
