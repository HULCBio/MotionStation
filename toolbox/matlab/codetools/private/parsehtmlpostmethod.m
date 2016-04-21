function strc = parsehtmlpostmethod(inStr)
%PARSEHTMLPOSTMETHOD  Returns HTML <form> post data in structure form
%   strc = PARSEHTMLPOSTMETHOD(inStr)

% Copyright 2003 The MathWorks, Inc.

inStr = char(java.net.URLDecoder.decode(inStr));

if nargin==0
    inStr = '?reporttype=standardrpt';
end

if inStr(1)=='?'
    inStr(1) = '&';
end

strc = [];
match1 = regexp(inStr,'&([^&]*)','tokens');
for n = 1:length(match1)
    match2 = regexp(match1{n}{1},'([^=]*)=([^=]*)','tokens');
    for m = 1:length(match2)
        prop = match2{m}{1};
        val  = match2{m}{2};
        strc.(prop) = val;
    end
end
