function whatsnew(arg)
%WHATSNEW Access Release Notes via the Help browser.
%   WHATSNEW <toolboxpath> displays the Readme.m file for the toolbox
%   with the specified toolbox path in the Help browser.  For example,
%
%   whatsnew wavelet    - Display Wavelet Toolbox Readme.m file.
%
%   A Readme.m file, if it exists for a given product, contains the most
%   recent information regarding the product that might not be available
%   in the installable online documentation.
%
%   If a Readme.m file does not exist for a given product, or if
%   WHATSNEW is called without any arguments, then the Release Notes
%   are displayed in the Help browser.
%
%   See also VER, INFO, HELP, WHICH, PATH, LOOKFOR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:29:39 $

msg = nargchk(0,1,1);
if (nargin == 0)
    if (isempty(docroot))
        html_file = fullfile(matlabroot,'help','base','relnotes','relnotes.html');
    else
        html_file = fullfile(docroot,'base','relnotes','relnotes.html');
    end
    
    if usejava('mwt')
        web(html_file, '-helpbrowser');
    else
        % Load the correct HTML file into the browser.
        stat = web(html_file);
        if (stat==2)
            error(sprintf(['Could not launch Web browser. Please make sure that\n' ...
                    'you have enough free memory to launch the browser.']))
        elseif (stat)
            error(sprintf(['Could not load HTML file into Web browser. Please make sure that\n' ...
                    'you have a Web browser properly installed on your system.']));
        end
    end
    
else
    info(arg)
end    
