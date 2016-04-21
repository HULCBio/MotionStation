% PDETRANS は、アプリケーション固有の PDE 係数を、ASSEMPDE、PARABOLIC、
% HYPERBOLIC シンタックスに合う基本的な PDE 係数に変換します。
%
%    PDEMTX = PDETRANS(STRMTX,TYPE)
%
% STRMTX にストアされるアプリケーション固有の係数(行に付き1つ)は、文字行
% 列 PDEMTX([c; a; f; d]) にストアされる標準の PDE Toolbox の係数(c, a, 
% f, d)に変換されます。アプリケーションタイプは、フラグ TYPE に渡されま
% す。
% 

%       Copyright 1994-2001 The MathWorks, Inc.
