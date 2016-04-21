% SUBSREF は、xPC オブジェクトの中を参照します。
% 
% つぎのシンタックスで使用できます。
% 
%    XPCOBJ.METHOD(ARGS)
% 
% これは、METHOD(XPCOBJ, ARGS) と等価です。また、XPCOBJ.PROPERTY は、妥当
% なプロパティ値を出力します。そして、GET(XPCOBJ, 'PROPERTY') と等価になり
% ます。他の使用は許されません。
% 
% フルネームでなく、名前の一部分の設定で構わないプロパティの場合と異なり、
% メソッド名は、フルネームで、しかも、小文字で入力する必要があり ます。
% 
% これは、直接、コールすることを目的としていない、プライベート関数です。
% 
% 参考： SUBSASGN.

%   Copyright 1994-2002 The MathWorks, Inc.
