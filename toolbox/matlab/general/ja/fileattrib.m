% FILEATTRIB   ファイルとディレクトリの属性の取得または設定
%
% [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB(FILE,MODE,USERS,MODIFIER) 
% は、DOS に対する ATTRIB、UNIX と LINUX に対する CHMOD と同様に FILE 
% の属性を設定します。空白によって定義される様々な属性は、一度に指定
% することができます。FILE は、ファイル、またはディレクトリを指し、
% 絶対パス名、またはカレントディレクトリの相対パス名を含みます。
%
% [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB は、MESSAGE のフィールド
% 定義に従って、カレントディレクトリ自身の属性に関するフィールドを
% 取得します。パラメータの出力と、注意 1 を参照してください。
%
% 入力パラメータ:
%     FILE: ファイルまたはディレクトリとして定義される 1×n の文字列
%           です。注意 2 を参照してください。
%     MODE: ファイルまたはディレクトリのモードとして定義されるスペース
%           で区切られた文字列です。注意 3 を参照してください。
%           'a' : アーカイブ (Windows/DOS のみ)
%           'h' : 隠しファイル (Windows/DOS のみ)
%           's' : システムファイル (Windows/DOS のみ)
%           'w' : 書き込み可
%           'x' : 実行可 (UNIX のみ)
%           '+' または '-' のいずれかを、属性の消去、または設定のために
%           各ファイルのモードの前に加えなければなりません。
%     USERS: どのユーザが属性の設定の影響を受けるかを定義するスペースで
%            区切られた文字列です。(UNIX のみ)
%           'a' : すべてのユーザ
%           'g' : ユーザグループ
%           'o' : 他のユーザ
%           'u' : カレントのユーザ
%           デフォルトの属性は、UNIX の umask に依存します。
%     MODIFIER: FILEATTRIB の挙動を修正するキャラクタのスカラです。
%           's' : ディレクトリサブツリー内のディレクトリとファイルを
%                 再帰的に操作します。注意 4 を参照してください。
%                 デフォルト - MODIFIER がないか、空の文字列です。
% 出力パラメータ:
%     SUCCESS:  FILEATTRIB の結果として定義される logical のスカラです。
%                 1 ... FILEATTRIB の実行に成功
%                 0 ... エラーが発生
%     MESSAGE: 構造体配列; 属性を要求する場合、以下のフィールドの項の
%              ファイル属性が定義されます。(注意 5 を参照してください)
%
%                           Name: ファイルまたはディレクトリの名前を
%                                 含む文字列ベクトル
%                        archive: 0 または 1 または NaN 
%                         system: 0 または 1 または NaN 
%                         hidden: 0 または 1 または NaN 
%                      directory: 0 または 1 または NaN 
%                      OwnerRead: 0 または 1 または NaN 
%                     OwnerWrite: 0 または 1 または NaN 
%                   OwnerExecute: 0 または 1 または NaN 
%                      GroupRead: 0 または 1 または NaN 
%                     GroupWrite: 0 または 1 または NaN 
%                   GroupExecute: 0 または 1 または NaN 
%                      OtherRead: 0 または 1 または NaN 
%                     OtherWrite: 0 または 1 または NaN 
%                   OtherExecute: 0 または 1 または NaN 
%
%     MESSAGE: エラー、またはワーニングメッセージを定義する文字列です。
%              空の文字列 : FILEATTRIB の実行に成功。
%              メッセージ : 適切なエラーまたはワーニングメッセージ。
%     MESSAGEID: エラー、またはワーニングの識別子を定義する文字列です。
%              空の文字列 : FILEATTRIB の実行に成功。
%              メッセージ id: エラーまたはワーニングメッセージの識別子。
%              (ERROR, LASTERR, WARNING, LASTWARN を参照してください)
%
% 例題:
%
% fileattrib mydir\*  は、'mydir' の属性と内容を再帰的に表示します。
%
% fileattrib myfile -w -s  は、'読み取り専用'属性を設定し、'myfile' の
% 'システムファイル'の属性を無効にします。
%
% fileattrib 'mydir' -x  は、'mydir' の'実行可能'の属性を無効にします。
%
% fileattrib mydir '-w -h'  は、'mydir' の隠し属性を無効にし、'読み取り
% 専用'に設定します。
%
% fileattrib mydir -w a s  は、すべてのユーザに対して、サブディレクトリ
% ツリーと同様に'書き込み可能'な属性を無効にします。
%
% fileattrib mydir +w '' s  は、サブディレクトリツリーと同様に、'mydir'
% を書き込み可能に設定します。
%
% fileattrib myfile '+w +x' 'o g'  は、グループと同様に、他のユーザに
% 対して、'myfile' の'書き込み可能'と'実行可能'な属性を設定します。
%
% [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('mydir\*'); は、成功した場合、
% SUCCESS 内に成功状態1と、'mydir' の属性と、構造体配列 MESSAGE 内の
% サブディレクトリツリーを返します。ワーニングが出た場合、MESSAGE は、
% ワーニングを含み、MESSAGEID は、ワーニングメッセージ識別子を含みます。
% 失敗した場合、SUCCESS は、成功状態0が含まれ、MESSAGE はエラーメッ
% セージが含まれ、MESSAGEID はエラーメッセージ識別子が含まれます。
%
% [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('myfile','+w +x','o g') は、
% グループと同様に他のユーザに対して、'myfile' の属性に、'書き込み可能'
% と'実行可能'を設定します。
%
%
% 注意 1: FILEATTRIB が出力引数なしでコールされ、FILEATTRIB 実行中に
%         エラーが発生した場合、エラーメッセージが表示されます。
% 注意 2: UNC パスがサポートされます。パスの文字列内の名前の最後の
%         拡張子として、または名前の最後に接尾辞としてのワイルドカード *
%         がサポートされます。
% 注意 3: オペレーションシステムの特別な属性の修正を適用します。;
%         それゆえ、指定された無効な修正は、エラーメッセージとして
%         返されます。
% 注意 4: Windows 2000 以降では ATTRIB のスイッチ /s /d は等価です。
%         MODIFIER の 's' は、Windows 2000 以前のプラットフォームでは
%         サポートされていません。Windows 2000 以前のプラットフォーム
%         上で  MODIFIER に 's' を指定すると、ワーニングの原因になり
%         ます。
% 注意 5: 属性のフィールド値は、logical のタイプです。属性が NaN で
%         示されたものは、特有のオペレーティングシステムに対して定義
%         されません。
%
%
% 参考 : CD, COPYFILE, DELETE, DIR, MKDIR, MOVEFILE, RMDIR.



%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
