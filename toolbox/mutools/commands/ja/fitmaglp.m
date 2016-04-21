% function [sys] = fitmaglp(magdata,wt,heading,osysl_g,...
%                              dmdi,upbd,blk,blknum)
%
% FITMAGLPは、与えられた周波数重み関数WTを使って、ゲインデータMAGDATAを
% 安定な最小位相伝達関数で近似します。これらの入力引数は、共に同じ独立変
% 数値をもつVARYING 行列です。
%
% HEADING(オプション)は、表示されるタイトルで、OSYSL_G(オプション)は、前
% の近似のFRSPです。これらが与えられれば、データと共に表示されます。
%
% (オプション)変数DMDIは、MAGDATA, WT, UPBDデータを作成した行列です。Dを
% 近似するときに、安定な最小位相システム行列SYSは、オリジナルの行列DMDI
% に組み込まれ、UPBDデータと共にプロットされます。BLKは、MUコマンドで使
% うブロック構造で、BLKNUMは、近似されるカレントのDスケーリングを定義し
% ます。
%
% これらの2つのプロットを比較することは、有理システム行列SYSがどの程度D
% データを近似しているかに関して洞察を与えます。新規にスケーリングされた
% 行列DMDIが出力されます。これは、SYSが組み込まれているCLPGです。DMDI, 
% UPBD, BLK, BLKNUMが与えられなければ、デフォルトではWT変数を代わりにプ
% ロットします。これらのオプションは、MUSYNFITで使われます。
%
% GENPHASEおよびFITSYSの代わりにMAGFITが使われること以外は、FITMAGと同じ
% です。
%
% 参考: FITSYS, INVFREQS, FITMAG, MUSYNFIT, MUFTBTCH, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
