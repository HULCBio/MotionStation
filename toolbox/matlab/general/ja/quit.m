% QUIT   MATLABセッションの終了
% 
% QUITは、スクリプト FINISH.M が存在する場合は実行させた後で、MATLAB
% を終了します。ワークスペースの情報は、FINISH.M が SAVE を呼び出さない
% 限り、保存されません。FINISH.M を実行中にエラーが生じた場合は、終了作
% 業はキャンセルされます。
% 
% QUIT FORCE は、ユーザに終了させないような誤った FINISH.M を回避する
% ために利用し ます。
% 
% QUIT CANCEL は、終了をキャンセルするために FINISH.M 内で使われます。
% これは、どの位置に設定しても影響はありません。
% 
% 例題：
% 終了をキャンセルさせるか否かを示すダイアログボックスを表示するために
% ユーザの FINISH.M に、つぎのコードを設定してください。
% 
% button = questdlg('Ready to quit?', ...
%                           'Exit Dialog','Yes','No','No');
%         switch button
%           case 'Yes',
%             disp('Exiting MATLAB');
%             %Save variables to matlab.mat
%             save 
%           case 'No',
%             quit cancel;
%         end
% 
% 注意：
% FINISH.M 内でHandle Graphicsを使用する場合、figureを可視化するためには、
% UIWAIT、WAITFOR、DRAWNOW のいずれかを使用してください。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:32 $
%   Built-in function.
