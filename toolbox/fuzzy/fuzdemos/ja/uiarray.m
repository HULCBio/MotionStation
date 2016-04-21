% UIARRAY UI ボタンの配列(または行列)を作成
% UIARRAY(POS、M、N、BORDER、SPACING、STYLE、CALLBACK、STRING) は、POS 
% 内に M 行N 列の配列として配置される UI コントロールを作成します。BOR-
% DER は、UI コントロールと周囲の大きなフレームと間のスペースを指定しま
% す。SPACING は、UI コントロール間のスペースを指定します。STYLE、CALL-
% BACK、STRING は、UI コントロールのスタイル、コールバック、文字列をそれ
% ぞれ指定する文字行列( M*N 行)です。これらの引数の行の数が M*N 以下の場
% 合、最後の行が必要なだけ繰り返し使われます。
%
% この関数は、主に Toolbox デモの UI コントロールを作成するために用いら
% れます。
%
% 例題:
%
%   figure('name','uiarray','numbertitle','off');
%   figPos = get(gcf、'pos');
%   bigFramePos = [0 0 figPos(3) figPos(4)];
%   m = 4; n = 3;
%   border = 20; spacing = 10;
%   style = str2mat('push','slider','radio','popup','check');
%   callback = 'disp([''This is a '' get(gco、''style'')])';
%   string = str2mat('one','two','three','four-1|four-2|four-3','five');
%   uiarray(bigFramePos,m,n,border,spacing,style,callback,string);



%   Copyright 1994-2002 The MathWorks, Inc. 
