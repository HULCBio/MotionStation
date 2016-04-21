% FGETL   行の終端子なしで、ファイルのつぎの行を1つの文字として出力
% 
% TLINE = FGETL(FID) は、指示子 FID をもつファイルのつぎの行を、MATLAB
% 文字列として出力します。行の終端子は含まれません。行の終端子付きで
% つぎの行を得るためには、FGETS を使ってください。ファイルの終端(EOF)
% のみがある場合は、-1が出力されます。
%
% FGETL は、テキストファイルのみの使用を意図しています。つぎの行を示す
% キャラクタをもたないバイナリファイルの場合は、FGETL は実行に時間が
% かかります。
%
% 例題
%       fid=fopen('fgetl.m');
%       while 1
%           tline = fgetl(fid);
%           if ~isstr(tline), break, end
%           disp(tline)
%       end
%       fclose(fid);
%
% 参考：FGETS, FOPEN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:04 $
