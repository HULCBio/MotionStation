function C = sptrmcharsfromcell(C,chars2rm)
%SPTRMCHARFROMFILE Utility to parse and remove characters from a cell array

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 21:29:27 $ 

n = 1;
while n <= length(C),
    % If the first character of the cell is CHARS2RM, consider it a comment and
    % remove the cell array element.
    idx = findstr(C{n},chars2rm);
    if isempty(idx),
        n = n+1;
    else
        if idx == 1,
            C(n) = [];
        else
            % Uncomment the code below to enable removing of cell array
            % elements which contain the CHARS2RM within the element. The
            % COEREAD function uses the CHARS2RM character to delimit the end of 
            % the data of interest
            %C{n}(idx:end) = [];
            n = n+1;
        end
    end
end

% EOF
