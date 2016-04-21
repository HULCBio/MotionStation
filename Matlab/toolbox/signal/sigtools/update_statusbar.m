function update_statusbar(hFig, str, varargin)
%UPDATE_STATUSBAR Update the status of the status bar
%   UPDATE_STATUSBAR(hFIG, STR) Update the status to the string STR.
%
%   See also RENDER_STATUSBAR.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/13 00:32:53 $ 

error(nargchk(2,inf,nargin));

if rem(length(varargin), 2),
    error('Too many input arguments.');
end

msg = [];
if ~ishandle(hFig) | ~strcmpi(get(hFig, 'Type'), 'figure'),
    msg = 'The first input must be a figure handle';
end
if ~ischar(str), 
    msg = 'The second input argument must be a string';
end
error(msg);

% Make sure the string is only one line of text.
str(find(str == char(10))) = ' ';
str = str';
str = str(:)';

h = siggetappdata(hFig, 'siggui', 'StatusBar');
if ~isempty(h),
%     if feature('JavaFigures'),
%         h.setText(str);
%         for indx = 1:2:length(varargin)
%             h.(sprintf('set%s', varargin{indx}))(varargin{indx+1});
%         end
%     else
        set(h, varargin{:}, 'String', str);
        drawnow;
%     end
end

% [EOF]
