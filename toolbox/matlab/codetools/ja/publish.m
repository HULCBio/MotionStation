%PUBLISH    スクリプトの実行と結果の保存
% PUBLISH(CELLSCRIPT,FORMAT) は、指定した形式でスクリプトを出力します。
% FORMAT は、つぎのいずれかになります。
%
%      'html' - HTML.
%      'doc'  - Microsoft Word ( Microsoft Word が必要です )。
%      'ppt'  - Microsoft PowerPoint ( Microsoft PowerPoint が必要です)。
%      'xml'  - XSLT または 他のツールで変換可能な XML ファイル
%      'rpt'  - Report Generator Template セットアップファイル
%               ( Report Generator が必要です)。
%      'latex'  - TeX.  また、デフォルトの imageFormat を 'epsc2' に変更します。%
% PUBLISH(SCRIPT,OPTIONS) は、つぎのフィールドのいずれかを含む構造体を
% 提供します。 (リストの最初の選択がデフォルトです):
%
%       format: 'html' | 'doc' | 'ppt' | 'xml' | 'rpt' | 'latex'
%       stylesheet: '' | XSL ファイル名 (format = html または xml 
%                   でない限り無視されます)
%       outputDir: '' (そのファイルより下位の html サブフォルダ) | フルパス
%       imageFormat: 'png' | figureSnapMethod に依存して、PRINT または 
%                    IMWRITE によりサポートされるもの
%       figureSnapMethod: 'print' | 'getframe'
%       useNewFigure: true | false
%       maxHeight: [] | 正の整数 (ピクセル)
%       maxWidth: [] | 正の整数 (ピクセル)
%       showCode: true | false
%       evalCode: true | false
%       stopOnError: true | false
%       createThumbnail: true | false
%
% HTML に出力すると、 デフォルトのスタイルシートは、"showcode = false" 
% の場合でも、 HTML コメントとしてオリジナルのコードを保存します
% 抽出するために GRABCODE を使用してください。
%
% 参考 GRABCODE.

% Matthew J. Simoneau, June 2002

% Copyright 1984-2004 The MathWorks, Inc.
