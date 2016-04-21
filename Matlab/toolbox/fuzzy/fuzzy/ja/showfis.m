% SHOWFIS 注釈付き FIS の表示
% 
% SHOWFIS(fismat) は、変数 fismat のテキストバージョンを1行ずつ表示しま
% す。これにより、構造体の各フィールドの意味と内容を確認することができま
% す。
%
% 例題
%    a = newfis('tipper');
%    a = addvar(a,'input','service',[0 10]);
%    a = addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%    a = addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%    showfis(a)
%
% 参考    GETFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
