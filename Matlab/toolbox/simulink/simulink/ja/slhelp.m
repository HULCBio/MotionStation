% SLHELP   Simulinkユーザーズガイドまたはブロックのヘルプの表示
%
% SLHELPは、Simulinkオンラインユーザーズガイドをヘルプブラウザに表示します。
%
% SLHELP(BLOCK_HANDLE) は、利用可能ならばHTML Help viewerに、そうでない場合に
% は、デフォルトのwebブラウザにSimulinkブロックリファレンスページを表示します。
% 表示されるページは、BLOCK_HANDLEによってポイントされるブロックのリファレン
% スページです。BLOCK_HANDLEは、数値のハンドル、または、ブロックの絶対
% Simulink パスのいずれかで構いません。
%
% マスクされたブロックに対しては、mask editorダイアログボックスのMaskHelp
% フィールドに入力されたテキストが表示されます。この機能は、マスクのヘルプテキ
% スト内でHTMLコードの利用を可能にします。
%
% 例題:
% slhelp(gcb)              %--  選択されたブロックのヘルプテキスト
%                            %     を表示
% slhelp('mysys/myblock')  %--  'mysys'というブロック線図内の
%          %    'myblock'というブロックのヘル
%        %    プを表示
%
% mask editorのMask Helpフィールドで特殊なテキストを用いることによって、
% ブロックダイアログのHelpボタンと関連するドキュメントをリンクすることが
% できます。
% Mask HelpフィールドでURLを直接指定できます。
% URLの指定子, 'file','ftp', 'mailto', 'news'がサポートされています。 '
% http', 'file', 'ftp','mailto' and 'news'.
% MATLABの 'web(...)','eval(...)'、および、'helpview(...)'コマンドも利用でき
%
% 特殊なタグがMask Helpテキストの先頭にある場合には、ブラウザ内にテキストこ
% れらのを表示する代わりに、適切なアクションが行われます。
%
% 他のドキュメントへのMask Helpのリンクのテキストの例:
% http://www.mathworks.com
% file:///C:\Document.htm
% web(['file:///' which(func.m)]);
% eval('!edit file.txt');
%
% 参考 : DOC, DOCOPT, HELPVIEW, HELPWIN, WEB


% Copyright 1990-2002 The MathWorks, Inc.
