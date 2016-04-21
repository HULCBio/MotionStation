% WAITBAR   ウエイトバーの表示
% 
% H = WAITBAR(X,'title', property, value, property, value, ...) は、
% 長さが全体の X の割合であるウエイトバーを作成して、表示します。ウエイト
% バーの figure のハンドル番号は、H に出力されます。
% 
% X は、0と1の間の数値です。オプションの引数プロパティと値は、対応する
% ウエイトバーfigureプロパティを設定します。プロパティは、キャンセル
% ボタンが figure に加わった場合、挙動を示すキーワード' CreateCancelBtn' 
% になります。そして、渡された値の文字列は、キャンセルボタンか、または、
% フィギュアクローズボタンをクリックすることで、実行します。
% 
% WAITBAR(X) は、最も新しく作成されたウエイトバーウィンドウにバーの長さ
% を全体の X の割合で設定します。
%
% WAITBAR(X,H) は、ウエイトバー H の中に、その長さの割合が X のバーの長
% さをもつものを設定します。
%
% WAITBAR(X,H,'updated title') は、長さの割合が全体の x になるウエイトバー
% を設定し、その figure ウィンドウのタイトルテキストを更新します。
%
% WAITBAR は、長い計算を行う FOR ループ内で使用されます。使用法の例を
% 以下に示します。
%
%       h = waitbar(0,'Please wait...');
%       for i=1:100,
%           % 計算を実行中 %
%           waitbar(i/100,h)
%       end
%       close(h)


%   Clay M. Thompson 11-9-92
%   Vlad Kolesnikov  06-7-99
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:09:11 $
