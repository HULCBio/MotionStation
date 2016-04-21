%PRINTOPT プリンタのデフォルト
% PRINTOPT は、ユーザやシステム管理者が修正できるM-ファイルで、デフォルトの
% プリンタのタイプと出力先を示します。
%
% [PCMD,DEV] = PRINTOPT は、2つの文字列PCMDとDEVを出力します。
% PCMD は、ファイルをプリンタにスプールするためにPRINTが使用するプリント
% コマンドを含む文字列です。デフォルトは、つぎの通りです。
%
%	   Unix:      lpr -r
%	   Windows:   COPY /B LPT1:
%	   Macintosh: lpr -r (Mac OS X 10.2 and higher)
%                     Print -Mps (Mac OS X 10.1)
%
% 注意:
% lpr のような BSD のプリントコマンドを使用しない SGI と Solaris 2 のユーザは、
% このファイルを修正して、'lp -c'をコメントアウトする必要があります。
%
% DEVは、PRINTコマンドのデフォルトのデバイスオプションを含む文字列です。
% デフォルトは、つぎの通りです。
%
%	   Unix:      -dps2
%	   Windows:   -dwin
%	   Macintosh: -dps2
%
% 参考 PRINT.


%   Copyright 1984-2002 The MathWorks, Inc.
