% DW1DSTEM　 離散1次元ウェーブレットの stem プロット
%
% 1番目の入力形式:
%--------------------
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE,VIEWAPP,COLORS)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE,VIEWAPP)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,ABSMODE)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS)
%
% 2番目の入力形式:
%--------------------
%   varargout = DW1DSTEM(AXE,COEFS,LONGS,'PropName1',ProVal1,...)
%   varargout = DW1DSTEM(AXE,COEFS,LONGS)
%   'PropNames' の有効な文字列: 'mode', 'viewapp' , 'colors'
%
% 各ケース
%---------
%   ABSMODE = 0 または 1
%   VIEWAPP = 0 または 1
%   COLORS は数値配列か、キーワード 'WTBX' です。
%
%   デフォルト:
%   ABSMODE = 1; VIEWAPP = 0; COLORS = flipud(get(axe,'colororder'));


%   Copyright 1995-2002 The MathWorks, Inc.
