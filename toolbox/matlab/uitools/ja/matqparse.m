% MATQPARSE   MATQDLGに対するダイアログエントリパーサ
% 
% [M,ERROR_STR] = MATQPARSE(STR,FLAG) は、MATQDLG に対するminiparser
% です。
% たとえば、'abc de  f ghij' は、
% 
%                        [abc ]
%                        [de  ]
%                        [f   ]
%                        [ghij]
% 
% になります。スペース、カンマ、セミコロン、鍵括弧のいずれかを、セパレータ
% として使用します。したがって、'a 10*[b c] d' はクラッシュします。ユーザは、
% 上記の代わりに、'a [10*[b c]] d' を使わなければなりません。
%
% この関数は廃止されており、将来のバージョンでは削除される場合があります。
% 
% 参考： MATQDLG, MATQUEUE.


%  Author(s): A. Potvin, 12-1-92
%  Revised: S. Eddins for use in uitools.
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.7.2.2 $  $Date: 2004/04/28 02:08:27 $

