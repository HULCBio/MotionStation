% HIDECRIT   マスクダイアログ内の'臨界周波数'パラメータを隠す
%
% ブロックを選択した後にこのコールバックの処理を設定します。
% 臨界周波数のエディットフィールドとタイプを隠したい場合、
% 以下のようにします。
%
%  set_param(gcb,'MaskCallbacks',{'', '', '', 'hidecrit', ''});
%
% 離散化の手法が、zoh, foh, tustin, prewarp, matched から選択されたとき、
% 呼び出されます。prewarpの選択のみ臨界周波数パラメータが表示されます。
%
%  Lihai Qin


% Copyright 1990-2002 The MathWorks, Inc.
