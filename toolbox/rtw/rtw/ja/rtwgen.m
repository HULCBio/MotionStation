% RTWGEN   ブロック線図からRTWファイル(model.rtw)を作成
%       
% RTWGENは、RTWの構築プロシジャから利用するように設計されています。構文
% は、リリース毎に異なります。直接利用するようには設計されていません。
%
% 表示： 
%   [sfcns,buildInfo] = rtwgen('model','OptionName','OptionValue',...)
%
% 以下のオプションの名前と値の組は有効です。    
%
% 'CaseSensitivity'      : 'on'または'off'を指定します。識別子については、
%                          大文字と小文字の区別を行います。デフォルトは
%                          onです。
%
% 'ReservedIdentifiers'  : 文字列のセル配列として指定します。これらは、
%                          無効な識別子です。
%
% 'StringMappings'       : これは、model.rtwファイル内のNameの値に対する
%                          文字列マッピングテーブルを与える文字列のセル
%                          配列です。たとえば、{sprintf('\n'),' '} は、
%                          ニューラインを空白キャラクタに変換します。
%
% 'WriteBlockConnections': 'true'、または、'false'を指定します。'true'を
%                          指定すると、connectionsレコードをs-functionブ
%                          ロックのみでなく全てのブロックに対して、書き
%                          出します。また、DirectFeedThroughの設定は、ブ
%                          ロック入力に対して書き出されます。
%
% 'SrcWorkspace'         : 'base', 'current'または'parent'を指定します。
%                          これは、rtwgenに対するワークスペースです。
%	
% 'OutputDirectory'      : model.rtwファイルを置く位置。
%
% 'Language'             : 'C', 'Ada', 'none'が指定されます。デフォルト
%                           は'C'です。言語を指定して、予約されている識
%                           別子と文字列の割り当てのデフォルトのリストを
%                           その言語に対して行います。
%     ReservedIdentsForC:
%   ['auto',      'break',       'case',    'char',      'const',
%    'continue',  'default',     'do',      'double',    'else',
%    'enum',      'extern',      'float',   'for',       'goto',
%    'if',        'int',         'long',    'register',  'return',
%    'short',     'signed',      'sizeof',  'static',    'struct',
%    'switch',    'typedef',     'union',   'unsigned',  'void',
%    'volatile',  'while',       'fortran', 'asm',       'Vector',
%    'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%    'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%    'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani'
%    'TRUE',      'FALSE']
%     ReservedIdentsForAda:
%   ['abort',     'abs',         'abstract','accept',    'access',
%    'aliased',   'all',         'and',     'array',     'at',
%    'begin',     'body',        'case',    'constant',  'declare',
%    'delay',     'delta',       'digits',  'do',        'else',
%    'elsif',     'end',         'entry',   'exception', 'exit',
%    'for',       'function',    'generic', 'goto',      'if',
%    'in',        'is',          'limited', 'loop',      'mod',
%    'new',       'not',         'null',    'of',        'or',
%    'others',    'out',         'package', 'pragma',    'private',
%    'procedure', 'protected',   'raise',   'range',     'record',
%    'rem',       'renames',     'requeue', 'return',    'reverse',
%    'select',    'separate',    'subtype', 'tagged',    'task',
%    'terminate', 'then',        'type',    'until',     'use',
%    'when',      'while',       'with',    'xor',       'Vector',
%    'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%    'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%    'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani',
%    'integer',   'boolean',     'float'}
%    StringMappings:
%    ['\n',' ', '/*','/+', '*/','+/']
%
% 出力引数
% ----------------
% 最初の出力引数sfcnsは、モデル内の全てのS-functionのリストを含むセル配
% 列です。各要素は、長さ2または3のセルで、1番目の要素はS-functionブロッ
% クのハンドルで、2番目の要素はS-function名で、オプションの3番目の要素は
% S-function が、インライン化されている場合、(1.0)を設定し、オプションの
% 4番目の要素は、リンクする必要があるS-functionモジュールです。
%
% 第2出力引数buildInfoは、モデルに対するbuildの情報を含むセルです。
% 
%       {modulesAndNoninlinedSFcns, tlcIncDirs, numStateflowSFcns}
% 
% 1番目の要素は、非インラインのS-function名とその他のモジュールの(一意的
% な)リストです。PCでは、1番目の要素は小文字の名前のみとなります。2番目
% の要素は、(S-functionに対する.tlcファイルがある)TLCのインクルードパス
% に対して用いられるディレクトリの(一意的な)リストです。3番目の要素は、
% Stateflow S-functionの数です。
%

%       Copyright 1994-2001 The MathWorks, Inc.

