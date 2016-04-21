function varargout = wintool(varargin)
%WINTOOL Window Design & Analysis Tool (WINTOOL)
%   WINTOOL is a Graphical User Interface (GUI) that allows 
%   you to design and analyze windows.  
%
%   WINTOOL(W1,W2, ..) where W1 and W2 are window objects which initialize
%   the GUI with the windows W1 and W2.
%
%   EXAMPLES :
%   % #1 Analysis of a window object
%   w = sigwin.chebwin(64,100);
%   wintool(w);
%
%   % #2 Analysis of multiple window objects
%   w1 = sigwin.bartlett(64);
%   w2 = sigwin.hamming(64);
%   wintool(w1,w2);
%
%   See also WVTOOL, FDATOOL, SPTOOL.

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/13 00:32:55 $

fprintf('Initializing Window Design & Analysis Tool ');
fprintf('.');

% Parse the inputs
[winobjs, msg] = parse_inputs(varargin{:});
if ~isempty(msg),
    error(generatemsgid('invalidInputs'), msg);
end

hWT = sigtools.wintool;
fprintf('.');

render(hWT);
fprintf('.');

setwindow(hWT, winobjs);
fprintf('.');

set(hWT, 'visible', 'on');

if nargout,
    varargout = {hWT};
end

fprintf('.');
fprintf(' done. \n');


% -----------------------------------------------------
function [winobjs, msg] = parse_inputs(varargin)
% Input arguments must be window objects

msg = '';
winobjs = [];

% Add windows
if nargin>0,
    for i = 1:length(varargin),
        if ~isa(varargin{i}, 'sigwin.window')
            msg = ['Invalid input arguments.\n' ...
                    'Input must be window objects.'];
            break;
        end
        winobjs = [winobjs varargin{i}];
    end
else
    winobjs = sigwin.hamming;
end

% [EOF]
