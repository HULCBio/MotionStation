% IMFORMATS   ファイルの書式の登録を管理
%
% FORMATS = IMFORMATS は、ファイルフォーマット書式の登録内の値のすべて
% を含む構造体を出力します。この構造体のフィールドは以下のとおりです。:
%
%    ext         - この書式に対するファイルの拡張子のセル配列
%    isa         - ファイルが "IS A" のタイプの場合に定義するための関数
%    info        - ファイルについての情報を読み込むための関数
%    read        - イメージデータファイルを読み込むための関数
%    write       - MATLABデータをファイルに書き込むための関数
%    alpha       - 書式がalphaチャンネルをもつ場合に1、それ以外は0
%    description - ファイル書式のテキストの詳細
% 
% isa、info、 read、および write フィールドに対する値は、MATLABのサーチ
% パス上にある関数か、または、function handle でなければなりません。
%
% FORMATS = IMFORMATS(FMT) は、文字列 "FMT." 内で与えられる拡張子をもつ
% 書式に対する既知の書式を探索します。見つかった場合、構造体は、キャラ
% クタと関数名を含んで返されます。それ以外は、空の構造体が返されます。
% 
% FORMATS = IMFORMATS(FORMAT_STRUCT) は、"FORMAT_STRUCT" 構造体内の値を
% 含む書式登録を設定します。出力の構造体 FORMATS は、新しい登録設定を
% 含みます。以下の "Warning" ステートメントを参照してください。
% 
% FORMATS = IMFORMATS('factory') は、ファイルの書式登録をデフォルトの
% 書式登録の値に再設定します。これは、すべてのユーザ定義の設定を削除
% します。
% 
% IMFORMATS は、サポートされた書式に対するファイル書式の情報の 
% テーブルに任意の入力または出力引数 prettyprints をもちません。
%
% ワーニング:
%
%   書式登録の拡張機能を変更するには、IMFORMATS を使用してください。
%   正しくない使用法は、イメージファイルの読み込みを妨げます。
%   使用可能な状態に書式登録を戻すために、'factory' 設定にして、
%   IMFORMATS を使用してください。
%   
% 注意:
%
%   書式登録の変更は、MATLABセッション間で保持しません。
%   MATLABを開始するときに、書式を常に利用可能にしておくために、
%   $MATLAB/toolbox/local の startup.m に、適切な IMFORMATS コマンド
%   を加えてください。
%
%  参考:  IMREAD, IMWRITE, IMFINFO, FILEFORMATS, PATH.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:06 $

