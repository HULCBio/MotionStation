% DEPDIR  M-ファイルまたはP-ファイルの従属ディレクトリの位置
%
% LIST = DEPDIR('FUN') は、FUN が従属する受けるディレクトリ名のセル配列
% を出力します。
%
% [LIST,PROB_FILES,PROB_SYMBOLS,PROB_STRINGS] = DEPDIR('FUN') は、
% PROB_FILES の中で文法解釈できない、PROB_SYMBOLS の中で検索できない、
% PROB_STRINGS の中で文法解釈できないM-ファイルまたはP-ファイルのリスト
% も出力します。
%
% [...] = DEPDIR('FILE1','FILE2',...) は、順番に、個々のファイルを処理
% します。
%
% 参考： DEPFUN.


%    Copyright 1984-2004 The MathWorks, Inc. 
