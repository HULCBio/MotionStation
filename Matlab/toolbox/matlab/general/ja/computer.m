% COMPUTER 使用中のコンピュータイプを出力
%
% C = COMPUTER は、MATLAB が実行しているコンピュータのタイプを文字列 C 
% に出力します。取り得る値は、つぎのものです。
%
%                                             ISPC       ISUNIX
% PCWIN       - MS-Windows                      1           0
% SOL2        - Sun Sparc  (Solaris 2)          0           1
% HPUX        - HP PA-RISC (HP-UX 11.00)        0           1
% GLNX86      - Linux on PC compatible          0           1
% GLNXI64     - Linux on Intel Itanium2         0           1
% MAC         - Macintosh OS X                  0           1
% 
% [C,MAXSIZE] = COMPUTER は、現在使用している MATLAB のバージョンで、
% 行列で取り得る最大要素数を MAXSIZE に整数で出力します。
%
% [C,MAXSIZE,ENDIAN] = COMPUTER は、バイトの並びが、小さい順の場合は、
% 'L' を、大きい順では、'B'を出力します。
%
% R12よりも前のバージョンをお使いのSGI64ユーザの方は、R12をインストール
% してください。
% R12よりも前のバージョンをお使いのLNX86ユーザの方は、R12をインストール
% してください。
%
% HP700, ALPHA, IBM_RS および SGI は、R14 でサポートされていません。
%
% 参考 ISPC, ISUNIX.



% Copyright 1984-2002 The MathWorks, Inc.
