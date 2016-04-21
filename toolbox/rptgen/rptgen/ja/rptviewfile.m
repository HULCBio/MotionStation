% RPTVIEWFILE   入力ファイルに対するビューワを起動
% RPTVIEWFILE <FILENAME.EXT>は、ファイルに対してビューワを起動します。複
% 数のファイル名を渡すことができます。名前に空白が含まれる場合は、コマン
% ド RPTVIEWFILE('FILENAME')の関数形式を利用してください。
%
% OK = RPTVIEWFILE('FILENAME1.EXT','FILENAME2.EXT')は、ファイルが適切に
% 起動されたかどうかを示す論理ベクトルを出力します。
%
% [OK,MSG] = RPTVIEWFILE('FILENAME1.EXT','FILENAME2.EXT')は、論理配列ま
% たはエラーメッセージを含むセル配列を出力します。エラーはスクリーンに表
% 示されず、関数の実行を停止しません。





%   Copyright (c) 1997-2001 by The MathWorks, Inc. All Rights Reserved.
