function bool = isreserved(str, lang)
%ISRESERVED Returns true if input is a reserved word.
%   ISRESERVED(STR) Returns true if STR is a reserved word in C or C++.
%
%   ISRESERVED(STR, LANG) Returns true if STR is a reserved word in the
%   language specified by LANG.  'm' and 'c' are currently supported.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:36:14 $

% Default to c
if nargin < 2,
    lang = 'c';
end

if strcmpi(lang, 'm'),
    bool = iskeyword(str);
else
    
    rwords = {'auto', 'double', 'int', 'struct', 'break', 'else', ...
            'long', 'switch', 'case', 'enum', 'register', 'typedef', ...
            'char', 'extern', 'return', 'union', 'const', 'float', ...
            'short', 'unsigned', 'continue', 'for', 'signed', 'void', ...
            'default', 'goto', 'sizeof', 'volatile', 'do', 'if', 'static', ...
            'while', 'fortran', 'asm', 'class', 'public', 'private'};
    
    % Determine if the specified word is a part of the language
    bool = any(strcmpi(str,rwords));
end

% [EOF]
