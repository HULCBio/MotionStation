% MOVEFILE   ファイルまたはディレクトリの移動
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE) は、
% ファイルまたはディレクトリ SOURCE を新規のファイルまたはディレクトリ 
% DESTINATION に移動します。SOURCE と DESTINATION は、カレントディレク
% トリの相対パス名、または絶対パス名のいずれかです。MODE を使用した
% 場合、MOVEFILE は、DESTINATION が読み込み専用であっても、SOURCE を
% DESTINATION に移動します。DESTINATION の書き込み属性は、保存されます。
% 注意 1 を参照してください。
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE) は、カレントディレク
% トリにソースを移動します。注意 2 を参照してください。
%
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION) は、SOURCE 
% を DESTINATION に移動します。SOURCE の最後にワイルドカード * がある
% 場合、すべてに一致するファイルオブジェクトが DESTINATION に移動され
% ます(注意 3 を参照)。DESTINATION がディレクトリの場合、MOVEFILE は、
% DESTINATION の下に SOURCE を移動します。SOURCE がディレクトリ、または
% 最後に * があって、かつ DESTINATION が存在しない場合、MOVEFILE は、
% ディレクトリとして DESTINATION を作成し、DESTINATION の下に SOURCE を
% 移動します。SOURCE がひとつのファイルで、DESTINATION がディレクトリで
% はない、または存在しない場合、SOURCE は、有効な名前 DESTINATION に
% 改名されます。
% 
% [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,'f') は、
% DESTINATION が読み取り専用であっても、上記のように、SOURCE を 
% DESTINATION に移動します。DESTINATION の書き込み属性の状態は保存され
% ます。
%
% 入力パラメータ:
%     SOURCE: ソースファイルまたはディレクトリとして定義される 1×n の
%             文字列です。注意 4 を参照してください。
%     DESTINATION: 移動先のファイルまたはディレクトリとして定義される
%                  1×n の文字列です。注意 5 を参照してください。
%     MODE: コピーモードを定義するキャラクタのスカラです。
%           'f' : SOURCE を DESTINATION に強制的に書き込みます。
%                 注意 5 を参照してください。
%                 省略された場合、MOVEFILE は、DESTINATION の現在の
%                 書き込み状態を優先します。
%
% 出力パラメータ:
%     SUCCESS: MOVEFILE の結果を定義する logical のスカラです。
%              1 : MOVEFILE の実行に成功。
%              0 : エラーが発生。
%     MESSAGE: エラーまたはワーニングメッセージを定義する文字列です。
%              空の文字列 : MOVEFILE の実行に成功。
%              メッセージ : 適切なエラーまたはワーニングメッセージ。
%     MESSAGEID: エラーまたはワーニング識別子を定義する文字列です。
%              空の文字列 : MOVEFILE の実行に成功。
%              メッセージ id: 適切なエラーまたはワーニング識別子。
%              (ERROR, LASTERR, WARNING, LASTWARN を参照)
%
% 注意 1: この場合をのぞいて、ファイル、ディレクトリを移動したときには、
%         OS の属性保存に関する規則が適用されます。
% 注意 2: MOVEFILE は、自身にファイルを移動することはできません。
% 注意 3: MOVEFILE は、1つのファイル内に複数のファイルを移動することは
%         できません
% 注意 4: UNC パスがサポートされています。名前の最後に接尾辞として、
%         あるいは、パスの文字列内の名前の最後の拡張子としてのワイルド
%         カード * がサポートされています。
% 注意 5: 'writable' は、削除されますが、下位互換性のためにまだサポート
%         されています。
%
% 参考 : CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, RMDIR.


%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
