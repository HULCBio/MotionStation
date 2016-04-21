function [cspec, msg] = cspecchk(varargin) 
%
%   CSPECCHK(VARARGIN) returns an RGB triple if VARARGIN is part of the
%   ColorSpec or a valid RGB triple
%
%   CSPECCHK is a helper function for LABEL2RGB and any other function that
%   is creating a color image.
%
%   [CSPEC, MSG] = CSPECCHK(varargin) returns an empty string in MSG if
%   VARARGIN is part of the ColorSpec.  Otherwise, CSPECCHK returns an error
%   message string in MSG.
%
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $ $Date: 2003/08/23 05:53:39 $
%

% error checking for nargin and setting defaults 

error(nargchk(1, 1, nargin,'struct'));
cspec = varargin{1};
msg = '';

% assigning colors to RGB triples.
yellow = [1 1 0];
magenta = [1 0 1];
cyan = [0 1 1];
red = [1 0 0];
green = [0 1 0];
blue = [0 0 1];
white = [1 1 1];
black = [0 0 0];

% making a table of cspec elements
cspec_el = {'yellow', yellow; 'magenta', magenta; 'cyan', cyan; 'red', ...
            red; 'green', green; 'blue', blue; 'white', white; 'k', black; ...
            'black', black};

if ~ischar(cspec)
    % check if cspec is a RGB triple
    if ~isreal(cspec) || ~isequal(size(cspec),[1 3]) || any(cspec > 1) || ...
            any(cspec < 0)
        msg = 'Invalid RGB triple entry for the ColorSpec.';
    end
else
    % check if cspec is part of cspec_el that defines the ColorSpec
    idx = strmatch(lower(cspec),cspec_el(:, 1));
    if isempty(idx)
        msg = sprintf('Entry is not part of the ColorSpec: %s.',cspec);
    elseif length(idx) > 1
        % check if cspec equals 'b'. If yes then the cspec is blue.
        % Otherwise, cspec is ambiguous.
        if isequal(cspec, 'b')
            cspec = blue;
        else
            msg = sprintf('Ambiguous entry for the ColorSpec: %s.', cspec);
        end    
    else
        cspec = cspec_el{idx, 2};
    end
end    
