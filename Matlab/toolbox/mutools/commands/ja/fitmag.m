%function [sys,dmdi] = fitmag(magdata,wt,heading,osysl_g,dmdi,upbd,blk,blknum)
%
% FITMAGは、与えられた周波数領域重み関数WTを使って、ゲインデータMAGDATA
% を安定な最小位相伝達関数で近似します。これらの入力引数は、共に同じ独立
% 変数値をもつVARYING行列です。FITMAGは、位相データを作成するのにGENPH-
% ASEを使い、近似するのにFITSYSを使います。
%
% HEADING(オプション)は、表示されるタイトルで、OSYSL_G(オプション)は、前
% の近似のFRSPです。これらが与えられた場合、データと共に表示されます。
%
% (オプション)変数DMDIは、MAGDATA, WT, UPBDデータを作成した行列です。Dを
% 近似するときに、安定な最小位相システム行列SYSは、オリジナルの行列DMDI
% に組み込まれ、UPBDデータと共にプロットされます。BLKは、MUコマンドで使
% うブロック構造で、BLKNUMは、近似されるカレントのDスケーリングを定義し
% ます。
%
% これらの2つのプロットを比較することは、有理システム行列SYSがどの程度、
% Dデータを近似しているかに関して洞察を与えます。新規にスケーリングされ
% た行列DMDIが出力されます。これは、SYSが組み込まれているCLPGです。DMDI,
% UPBD, BLK, BLKNUMが与えられなければ、デフォルトではWT変数を代わりにプ
% ロットします。これらのオプションは、MUSINFITで使われます。
%
% 参考: FITSYS, GENPHASE, INVFREQS, MAGFIT, MUSYNFIT, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
