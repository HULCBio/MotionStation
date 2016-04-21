% REMAPFIG   figureオブジェクトの位置の変換
% 
% REMAPFIG(POS) は、正規化された位置ベクトル POS により、カレントのfigure
% の内容を、希望するfigureのサブセクションに配置します。
%
% REMAPFIG(OLDPOS,NEWPOS) は、figureのすべての子オブジェクトを、以前の
% 位置が OLDPOS であり、現在の位置が NEWPOS であるように、新たな NEWPOS
% に再配置します。
%
% REMAPFIG(OLDPOS,NEWPOS,FIG) は、(必要ならば)これをgcfでなくFIGで行います。
%
% REMAPFIG(OLDPOS,NEWPOS,FIG,H) は、ハンドル番号のベクトル H 内のオブ
% ジェクトのみの位置を変更します。


%  Author(s): T. Krauss, 9/29/94
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:45 $
