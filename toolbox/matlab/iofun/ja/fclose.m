% FCLOSE   ファイルのクローズ
% 
% ST = FCLOSE(FID) は、ファイル識別子 FID をもつファイルを閉じます。
% ここで、FID は、以前に行った FOPEN で得られた整数です。FCLOSE は、
% 正常終了すれば0を、そうでなければ-1を出力します。
%
% ST = FCLOSE('all') は、0、1、2以外のすべての開いているファイルを
% 閉じます。
%
% 参考：FOPEN, FREWIND, FREAD, FWRITE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:01 $
%   Built-in function.
