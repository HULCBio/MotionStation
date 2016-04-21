% COPYFILE   ファイルまたはディレクトリのコピー
% 
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE) は、
% ファイルまたはディレクトリ SOURCE を新しいファイルまたはディレクトリ 
% DESTINATION にコピーします。SOURCE と DESTINATION の両方は、カレント
% ディレクトリに関する絶対パス名またはパス名のいずれかです。MODE が設定
% されている場合、DESTINATION が読み取り専用であっても、COPYFILE は、
% SOURCE を DESTINATION にコピーします。DESTINATION が書き込みの属性の
% 状態は、保存されます。注意 1 を参照してください。
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE) は、カレントのディレ
% クトリに SOURCE をコピーします。
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION) は、
% SOURCE を DESTINATION にコピーします。SOURCE がディレクトリ、または
% 複数のファイルを含み、DESTINATION が存在する場合、COPYFILE は、
% ディレクトリとして DESTINATION を作成し、SOURCE を DESTINATION に
% コピーします。SOURCE がディレクトリ、または複数のファイルを含み、
% 上記の DESTINATION への適用がない場合、COPYFILE は失敗します。
%
% [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,'f') は、
% DESTINATION が読み取り専用であっても、上記のように、SOURCE を 
% DESTINATION にコピーします。DESTINATION の書き込み属性の状態は、保存
% されます。
%
% 入力パラメータ:
%     SOURCE: ソースファイルまたはディレクトリとして定義される1×n の
%             文字列です。注意2 および 3 を参照してください。
%     DESTINATION: コピー先のファイルまたはディレクトリとして定義される
%                  1×n の文字列です。デフォルトはカレントディレクトリ
%                  です。注意 3 を参照してください。
%     MODE: コピーモードとして定義されるキャラクタのスカラです。
%           'f' : SOURCE は DESTINATION に強制的に書き込まれます。省略
%                 された場合、COPYFILE は DESTINATION の現在の書き込み
%                 状態を示します。注意 4 を参照してください。
%
% 出力パラメータ:
%     SUCCESS: COPYFILE の結果を定義する logical のスカラです。
%              1 : COPYFILE は、実行に成功
%              0 : エラーが発生
%     MESSAGE: エラー、またはワーニングメッセージを定義する文字列です。
%              空の文字列 : COPYFILE は実行に成功
%              メッセージ : 適切なエラーまたはワーニングメッセージ
%     MESSAGEID: エラーまたはワーニングの識別子を定義する文字列
%           空の文字列 : COPYFILE は実行に成功
%           message id: MATLABエラーまたはワーニングメッセージの識別子
%	    (ERROR、LASTERR、WARNING、LASTWARN を参照)
%
% 注意 1: 現在、SOURCE の属性は、Windows プラットフォーム上でコピーする
%         するときには保存されません。他の状態をのぞいて、属性の保存に
%         関する根本的なシステムのルールは、ファイルとディレクトリが
%         コピーされる場合、以下のとおりです。
% 注意 2: パスの文字列内の名前の最後の拡張子として、または名前の最後の
%         接尾辞として、ワイルドカード * がサポートされています。
%         ワイルドカード * を使用、またはディレクトリをコピーする場合、 
%         COPYFILE の現在の挙動は、UNIX と Windows 間で異なります。詳細
%         は、DOC COPYFILE を参照してください。
% 注意 3: UNC パスがサポートされています。
% 注意 4: 'writable' は、削除されますが、下位互換性のためにまだサポート
%         されています。

%
% 参考：CD, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE, RMDIR.


%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
