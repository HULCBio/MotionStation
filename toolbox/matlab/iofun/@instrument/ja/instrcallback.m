% INSTRCALLBACK   イベントに関する情報を表示
%
% INSTRCALLBACK(OBJ, EVENT) は、イベントのタイプ、時間、イベントを生じ
% させる原因となるオブジェクト名を含むメッセージを表示します。
%
% エラーイベントが生じた場合、エラーメッセージも表示されます。
% ピンイベントが発生した場合、ピンを変更した値とピンの値も表示されます。
%
% INSTRCALLBACK は、コールバック関数の例です。ユーザ自身のコールバック
% 関数を記述するためにテンプレートとしてこのコールバック関数を使用して
% ください。
%
% 例題:
%       s = serial('COM1');
%       set(s, 'OutputEmptyFcn', {'instrcallback'});
%       fopen(s);
%       fprintf(s, '*IDN?', 'async');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%


%    MP 2-24-00
%    Copyright 1999-2002 The MathWorks, Inc. 
