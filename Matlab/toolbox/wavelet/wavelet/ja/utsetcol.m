% UTSETCOL カラー設定ユーティリティ
%   [OUT1,OUT2] = UTSETCOL(OPT,IN2,IN3,IN4)
% OPT = 'define' : 構成
% IN2  = fig は、オプションです。
% IN3  = [XLeft YDown] は、オプションです。
% IN4  = str_title は、オプションです。
% OUT1 = ハンドル番号、out2 = 位置
%
% OPT = 'get'   : カラーの取得
% IN2  = ハンドル番号
% OUT1 = [R G B]
%
% OPT = 'set'   : カラーの設定
% IN2 = ハンドル番号
% IN3 = [R G B]
%
% OPT = 'pos'   : 位置の変更
% IN2  = [dx dy]
% OUT1 = newpos
%
% OPT = 'change' & 'change_txt' : 内部オプション



%   Copyright 1995-2002 The MathWorks, Inc.
