% LOAD   ディスクからワークスペース変数をロード
% 
% LOAD FILENAME は、フルパス名、または、MATLAB部分パス名を与えて、ファ
% イルからすべての変数を読み込みます(PARTIALPATH を参照)。FILENAME に
% 拡張子がない場合、LOAD は、FILENAME と FILENAME.mat を探し、それを
% バイナリの"MAT-ファイル"として取り扱います。FILENAME が、.mat 以外の拡
% 張子をもっている場合、それを ASCII として取り扱います。
%
% LOAD 自身では、'matlab.mat'と名付けたバイナリMAT-ファイルを利用します。
% 'matlab.mat' が見つからない場合は、エラーになります。
%
% LOAD FILENAME X は、X のみをロードします。
% LOAD FILENAME X Y Z ... は、指定した変数をロードします。あるパターンに
% 一致する変数をロードするために、ワイルドカード'*'を使用できます
% (MAT-ファイルのみ)。
%
% LOAD FILENAME -REGEXP PAT1 PAT2 は、正規表現を使用して指定したパターンに
% 一致するすべての変数をロードするために使用することができます。正規表現を
% 使用する詳細は、コマンドプロンプトで "doc regexp" と入力してください。
%
% LOAD -ASCII FILENAME または LOAD -MAT FILENAME は、ファイルの拡張
% 子に関わらず、ファイルをASCIIファイルまたはMATファイルとして取り扱い
% ます。-ASCII の場合、ファイルが数値テキストでない場合、エラーになります。
% -MAT の場合、SAVE -MAT で作成したMATファイルでない場合、エラーになり
% ます。
% 
% FILENAME が MATファイルの場合、FILENAME から要求された変数がワークス
% ペース内に作成されます。FILENAME がMATファイルでない場合、倍精度配列
% がFILENAME をベースにした名前で作成されます。FILENAME にアンダースコ
% アや数字がある場合は、X で置き換わります。FILENAME 内のアルファベット
% でないキャラクタは、アンダースコアと置き換わります。
% 
% S = LOAD(...) は、FILENAME の内容を変数 S に出力します。FILENAME が 
% MATファイルの場合、S は読み込まれた変数と一致するフィールドをもつ構造
% 体になります。FILENAME が、ASCIIファイルの場合、S は倍精度配列にな
% ります。
% 
% ファイル名が文字列として格納されている、あるいは出力引数が必要な場合、
% または、FILENAME がスペースを含んでいる場合は、たとえば、LOAD('filen-
% ame') のように LOAD の関数形式を使ってください。
%
% パターンマッチングの例:
% load fname a*                % "a" ではじまる変数を消去
% load fname -regexp ^b\d{3}$  % "b" ではじまり、 3 digits
%                              % が続く変数を消去
% load fname -regexp \d        % 任意 digits を含む変数を消去
%
% 参考： SAVE, WHOS, UILOAD, SPCONVERT, PARTIALPATH, IOFUN, FILEFORMATS.


% Copyright 1984-2002 The MathWorks, Inc.
