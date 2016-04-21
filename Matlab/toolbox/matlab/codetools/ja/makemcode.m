%MAKEMCODE 入力オブジェクト(複数可)に基づき、可読性の m-コード関数を作成します
%
% MAKEMCODE(H) 入力ハンドルとその子を再生成するために m-コードを作成します。
% デフォルトでは、m-コードは、MATLAB command window に表示されます。
%
% MAKEMCODE  デフォルト入力ハンドルとして、カレントオブジェクト GCO を
% 使用します。
%
% MAKEMCODE(...,'-editor'); デスクトップエディタに m-コードを表示します。
%
% MCODE = MAKEMCODE(...) m-コードテキストを含むセル配列を出力します。
%
% 完全にオブジェクトを並べるには、PRINTDMFILE, SAVE, および/または HGSAVE 
% を使用してください。
%
% 制限
% 多数 (たとえば、20 個のプロットラインより多く) のグラフィックスオブジェクト
% を含むグラフに対するコードを作成するために MAKEMCODE を使用することは、実用的
% ではありません。
%
% 例題:
%
% surf(peaks);
% makemcode(gcf);

% Copyright 1984-2004 The MathWorks, Inc.
