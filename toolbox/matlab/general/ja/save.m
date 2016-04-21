% SAVE   ワークスペース変数をディスク上に保存
% 
% SAVE FILENAME は、すべてのワークスペース変数を、FILENAME .mat という
% バイナリ"MAT-ファイル"に保存します。データは、LOAD で読み込むことが
% できます。SAVE FILENAME に拡張子がない場合は、.mat を仮定します。
%
% SAVE 自身では、'matlab.mat' と名付けたバイナリ'MAT ファイル'を作成しま
% す。'matlab.mat' が書き込みできない場合は、エラーになります。
%
% SAVE FILENAME X は、X のみを保存します。
% SAVE FILENAME X Y Z は、X、Y、Z を保存します。ワイルドカード'*'は、パ
% ターンに一致する変数のみを保存します。
%
% SAVE FILENAME -REGEXP PAT1 PAT2  は、正規表現を使用する指定パターン
% に一致するすべての変数を保存するために使用できます。
% 正規表現の使用についての詳細は、コマンドプロンプトで、"doc regexp" 
% と入力してください。
%
% SAVE FILENAME -STRUCT S は、スカラー構造体 S のフィールドを、
% ファイル FILENAME 内の個々の変数として保存します。
% SAVE FILENAME -STRUCT S X Y Z  は、フィールド S.X, S.Y および S.Z を
% FILENAME に、個々の変数 X, Y および Z として保存します。
%
% ASCII オプション：
%  SAVE ...  -ASCII  は、ファイル拡張子に関わらず、バイナリの代わりに
%		     8桁のASCII書式を使います。
%  SAVE ...  -ASCII -DOUBLE は、16桁のASCII書式を使います。
%  SAVE ...  -ASCII -TABS は、タブで区切ります。
%  SAVE ...  -ASCII -DOUBLE -TABS は16桁で、タブで区切られます。
%
% MAT オプション：
%  SAVE ...  -MAT は、拡張子に関わらず、MAT形式で保存します。
%  SAVE ...  -V4 は、MATLAB 4がロードできる形式でMAT-ファイルを保存し
%             ます。
%  SAVE ...  -APPEND は、既存のファイル(MAT-ファイルのみ)に変数を追加
% 		     します。
%
%  SAVE ... -COMPRESS  は、変数を圧縮し、より小さいMAT-ファイルにします。
%                       -COMPRESS オプションは、-V4 または -ASCII
%                       とともに使用することができません。
%
%  SAVE ... -NOUNICODE は、MAT-ファイルが以前のバージョンのMATLABにより
%　　　　　　　　　　　読めるように、システムデフォルト文字エンコーディング
%                      スキームですべての文字データを保存します。 
%                      -NOUNICODEオプションは、 -V4 オプションととともに
%                      使用することができません。
%
% -V4 オプションを使用するときは、MATLAB 4 と互換性のない変数は、MAT-
% ファイルに保存されません。たとえば、N次元配列、構造体、セルなどは、
% MATLAB 4 のMAT-ファイルに保存されません。また、19 文字よりも長い名前
% をもつ変数も、MATLAB 4 の MAT-ファイルに保存されません。
%
% ファイル名または変数名が文字列として格納されているときは、たとえば、
% SAVE('filename','var1','var2') のように SAVE の関数形式のシンタックス
% を使ってください。
%
% パターンマッチングの例:
%     save fname a*                % "a" ではじまる変数を保存
%     save fname -regexp ^b\d{3}$  % "b" ではじまり、 3 digits
%                                  %  が続く変数を保存
%     save fname -regexp \d        % 任意 digits を含む変数を保存
%
% 参考 LOAD, WHOS, DIARY, FWRITE, FPRINTF, UISAVE, FILEFORMATS.

%   Copyright 1984-2003 The MathWorks, Inc.
