% MODREAL 状態空間モード打ち切り/実現
%
% [A1,B1,C1,D1,A2,B2,C2,D2] = MODREAL(A,B,C,D,CUT)、または、
% [SYS2,SYS3] = MODREAL(SYS1,CUT) は、数字"cut"での指定に基づいて、
% slow/fastモード実現を実行します。
%
% "CUT"がsize(A)より小さい場合、 D1 = D + C2*inv(-A2)*B2; D2 = 0;
%
% "CUT"が指定されなかった場合、完全なモード実現が出力されます。

% Copyright 1988-2002 The MathWorks, Inc. 
