% GETCDATA   バックグランドが透明なボタンのCDATAを出力
% 
%   CDATA=GETCDATA(R,FILENAME,BGC)
% 
% Rは、RPTCOMPONENTオブジェクトです。
% FILENAMEは、CDATAイメージを含むMAT-ファイルの絶対パスです。
% FILENAMEが、空、または省略された場合は、
% MATLABROOT/toolbox/rptgen/private/images/rptcdata.matを利用します。
% BGC (オプション) - 利用するバックグランドカラー。1行3列のcolorspecです。
% デフォルトは、get(0,'defaultuicontrolbackgroundcolor')です。
%
%   CDATA=GETCDATA(R,FSTRUCT,BGC)
% 
% Rは、RPTCOMPONENTオブジェクトです。
% FSTRUCTは、CDATAを含む構造体です。





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:50 $
%   Copyright 1997-2002 The MathWorks, Inc.
