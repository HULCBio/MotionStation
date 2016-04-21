% WAVEMNGR　 ウェーブレットの管理コマンド
% WAVEMNGR は、ツールボックスのウェーブレットを作成したり、加えたり、削
% 除したり、保存したり、読み込んだりするものです。
%
% WAVEMNGR('add',FN,FSN,WT,NUMS,FILE)、または、WAVEMNGR('add',FN,FSN,WT,%   NUMS,FILE,B)、または WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE)、% または、WAVEMNGR('add',FN,FSN,WT,{NUMS,TYPNUMS},FILE,B) は、新しいウェ% ーブレットファミリを追加します。
%   FN    = ファミリネーム (文字列)
%   FSN   = ファミリの略称 (文字列)
%
%   WT は、ウェーブレットのタイプを定義します。
%   WT    = 1 、直交ウェーブレット
%   WT    = 2 、双直交ウェーブレット
%   WT    = 3 、スケーリング関数付きウェーブレット
%   WT    = 4 、スケーリング関数なしウェーブレット
%   WT    = 5 、スケーリング関数なし複素ウェーブレット
%
% ウェーブレットが単一の場合、NUMS  = '' です。
%    例: mexh, morl
% ウェーブレットがウェーブレットファミリで有限の次数である場合、NUMS は
% ウェーブレットパラメータを表わす項目にブランクで区切られたリストに、文% 字列として含まれます。 
%    例: bior, NUMS = '1.1 1.3 ... 4.4 5.5 6.8'
% ウェーブレットがウェーブレットファミリで無限の次数である場合、NUMS は
% 特別なシーケンスである ** が終わりにくるようなウェーブレットパラメータ% を表わす項目いブランクで区切られたリストに文字列として含まれます。
%    例: db,    NUMS = '1 2 3 4 5 6 7 8 9 10 **'
%        shan,  NUMS = '1-1.5 1-1 1-0.5 1-0.1 2-3 **'
% これらの2つのケースの最後で、TYPNUMS はウェーブレットパラメータの入力
% 形式である、'integer' または 'real' または 'string' (デフォルトは 'int%   eger') を指定します。
%    例: db,    TYPNUMS = 'integer'
%        bior,  TYPNUMS = 'real'
%        shan,  TYPNUMS = 'string'
%
%   FILE  = MAT ファイル、または、M ファイル名 (文字列) です。
%
%   B = [lb ub] タイプ3、4 または、5のウェーブレットに対して、効率的なサ%   ポートの下限と上限です。
%
% WAVEMNGR('del',N) は、ウェーブレットファミリの削除を行います。N は、フ% ァミリの略称、または、ファミリの中のウェーブレット名です。
%
% WAVEMNGR('restore')、または、WAVEMNGR('restore',IN2) は、nargin = 1 の% 場合、一つ前の wavelets.asc ファイルが保存され、他の場合、初期の wavel%   ets.asc ファイルが保存されます。
%
% OUT1 = WAVEMNGR('read') は、すべてのウェーブレットファミリの出力です。%
% OUT1 = WAVEMNGR('read',IN2) は、すべてのウェーブレットの出力です。
%
% OUT1 = WAVEMNGR('read_asc')は、wavelets.asc ASCIIファイルを読み込み、
% すべてのウェーブレット情報を出力します。



%   Copyright 1995-2002 The MathWorks, Inc.
