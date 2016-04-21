% COLSTYLE  文字列から、カラーとスタイルを判別
% 
% [L,C,M,MSG] = COLSTYLE('linespec') は、ライン仕様 'linespec' を文法
% 解釈し、ラインタイプを L、カラー部を M、マーク部を Hに出力します。
% L, C, M は、指定されていない場合、または文法上のエラーが存在する場合は
% 空です。MSG は、エラーの場合はエラーメッセージ文字列を含みます。

% [L,C,M,MSG] = COLSTYLE(LINESPEC, 'plot')は、LINESPECを文法解釈し、
% ンスタイルまたはマーカが1つだけ指定されている場合は、空の変わりに 'none' 
% 力します。これは、たとえば、 '-' をマーカ'none' およびラインスタイル'-'
% として解釈するPLOTの挙動との互換性のためのものです。

%   Copyright 1984-2002 The MathWorks, Inc. 
