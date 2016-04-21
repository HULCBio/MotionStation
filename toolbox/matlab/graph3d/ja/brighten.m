% BRIGHTEN   カラーマップを明るく、または暗くします
% 
% BRIGHTEN(BETA) は、カレントのカラーマップを、基本的に同じ色を含む明るい
% カラーマップ、または暗いカラーマップで置き換えます。0 < BETA < =  1
% の場合はマップは明るくなり、-1 < =  BETA < 0 の場合は暗くなります。
%
% BRIGHTEN(BETA) のつぎに BRIGHTEN(-BETA) を実行すると、オリジナルのマップ
% をリストアします。
% 
% MAP = BRIGHTEN(BETA) は、表示を変えずに、現在使用されているカラーマップ
% の明るいバージョンまたは暗いバージョンを出力します。
%
% NEWMAP = BRIGHTEN(MAP,BETA) は、表示を変えずに、指定したカラーマップの
% 明るいバージョンまたは暗いバージョンを出力します。
%
% BRIGHTEN(FIG,BETA) は、figure FIG のすべてのオブジェクトを明るくします。


%   CBM, 9-13-91, 2-6-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:30 $
