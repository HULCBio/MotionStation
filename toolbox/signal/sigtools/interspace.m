function strs = interspace(strs)
%INTERSPACE   Add spaces to the string when we find a capital letter.
%   INTERSPACE(STR) Add spaces to the string when we find a capital letter.
%   Intercapping is assumed:
%
%   ScaleValues   ->   Scale Values
%   SOSMatrix     ->   SOS Matrix

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:58 $

% xxx NARGCHK too slow.
% error(nargchk(1,1,nargin));

% If the caller passes in a string, make sure that we pass back a string.
if ischar(strs)
    revert = true;
    strs = cellstr(strs);
else
    revert = false;
end

% Loop over the cell and convert each element.
for indx = 1:length(strs)

    % Find all the elements that are capital letters
    jndx = regexp(strs{indx}, '[A-Z]');

    if ~isempty(jndx),

        % Remove multiple capital letters in a row, e.g. 'SOSMatrix'.
        jndx = jndx([find(diff(jndx) > 1) end]);

        % If we have something in the first space, just skip it.
        jndx(find(jndx == 1)) = [];

        % Loop over the capital letters and add spaces before them.
        for kndx = length(jndx):-1:1
            strs{indx} = [strs{indx}(1:jndx(kndx)-1) ' ' strs{indx}(jndx(kndx):end)];
        end
    end
end

if revert
    strs = strs{1};
end

% [EOF]
