% GET_TMF_FOR_TARGET は、与えられたターゲットに対して、デフォルトのテン
% プレート makefile を出力します。
%
% Unix システムでは、デフォルトのテンプレート makefile は、<target>_
%       unix.tmf です。
% PC システムでは、デフォルトのテンプレート makefile は、mexopts.bat 
%       (help mex を参照)を調べることによって決定されます。WATCOM が、
%       mexopts.bat 内に存在すれば、<target>_watc.tmf で、BORLAND が、
%       mexopts.bat 内に存在すれば、<target>_bc.tmf で、その他の場合、
%       <target>_vc.tmf です。

%       Copyright 1994-2001 The MathWorks, Inc.
