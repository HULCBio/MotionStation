%LOADLIBRARY MATLAB に共有ライブラリをロードします 
% LOADLIBRARY(SHRLIB,HFILE) は、ヘッダファイル HFILE に定義され、
% ライブラリ SHRLIBに見つかる関数を MATLAB にロードします。
%
% LOADLIBRARY(SHRLIB,@MFILE) は、MFILE に定義され、ライブラリ SHRLIB
% に見つかる関数を MATLAB にロードします。MFILE は、MFILENAME 
% オプションを使用して、LOADLIBRARY により前に生成されたMATLAB 
% M-ファイルです。@MFILE は、その M-ファイルに対する関数ハンドルです。
%
% LOADLIBRARY(SHRLIB,...,OPTIONS) は、つぎのOPTIONSの1つまたは複数を
% もつライブラリ SHRLIB をロードします。(プロトタイプファイルを使用
% してロードする場合、ALIAS オプションのみ使用できます。)
%
% OPTIONS:
%  'alias','newlibname'     ライブラリを別のライブラリ名でロード
%          することができます
%
%  'addheader','header'     追加のヘッダファイル'header'に定義         
%　　　　　された 関数をロードします
%　　　　　ファイル拡張子のないファイル名としてヘッダパラメータを
%          指定してください。MATLAB は、ヘッダファイルがあることを
%          確かめず、必要でないファイルを無視します。
%
%          つぎのシンタックスを使用して、必要な付加ヘッダファイル
%          を指定することができます。
%             LOADLIBRARY shrlib hfile ...
%                addheader addfile1 ...
%                addheader addfile2 ...          % 以下同様
%
%  'includepath','path'    使用されるパスに追加のインクルードパスを
%　　　　　追加します。
%
%  'mfilename','filename'   カレントディレクトリにプロトタイプ M-
%         ファイル filename.m を生成し、ライブラリをロードするために
%         そのファイルを使用します。Successive LOADLIBRARY コマンドは、
%    　　 ライブラリのロードでヘッダとしてこのプロトタイプファイルを
%         使用するために関数ハンドル@filename を指定することができます。
%    　   これを使用して、ロード過程の高速化および簡単化ができます。
%
% 参考 UNLOADLIBRARY, LIBISLOADED.

%   Copyright 2002 The MathWorks, Inc. 
