function docsearch(varargin)
%DOCSEARCH Search HTML documentation in the Help browser.
%
%   DOCSEARCH, by itself, brings up the Help browser with the Search tab
%   selected.
%
%   DOCSEARCH TEXT brings up the Help browser with the Search tab selected,
%   and executes a full-text search of the documentation on the text.
%
%   Examples:
%      docsearch plot
%      docsearch('plot unix')
%
%   See also DOC, HELPBROWSER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:07 $

errormsg = javachk('mwt', 'The Help browser');
if ~isempty(errormsg)
	error('MATLAB:helpbrowser:UnsupportedPlatform', errormsg);
end

if nargin > 1
    error('Too many arguments to docsearch');
elseif nargin == 1
    text = varargin{1};
else
    text = '';
end

com.mathworks.mlservices.MLHelpServices.docSearch(text);
