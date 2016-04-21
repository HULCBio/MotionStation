function info(arg)
%INFO   Information about MATLAB and The MathWorks.
%   INFO <toolboxpath> displays the Readme.m file for the toolbox
%   with the specified toolbox path in the Help Browser.  If a
%   Readme.m file does not exist for the specified toolbox, then
%   the Release Notes are displayed in the Help browser.
%
%   INFO when called with no arguments displays information about
%   MATLAB and The MathWorks in the Command Window.
%
%   See also WHATSNEW.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/10 23:29:36 $

if nargin == 0
clc
disp(' ')
disp('   MATLAB is available for Windows, Solaris, HP-UX, LINUX,')
disp('   and MacIntosh.')
disp(' ')
disp('   For an up-to-date list of MathWorks Products, visit our Web site')
disp('   at www.mathworks.com.')
disp(' ')
disp('   24 hour access to our Technical Support problem/solution database')
disp('   as well as our FAQ, Technical Notes, and example files is also')
disp('   available at www.mathworks.com.')
disp(' ')
disp('   For MATLAB assistance or information, contact your local ')
disp('   representative or:')
disp(' ')
disp('   The MathWorks, Inc. ')
disp('   3 Apple Hill Drive')
disp('   Natick, MA 01760-2098 USA ')
disp(' ')
disp('   Contact Information:')
disp('                      Phone:  +508-647-7000')
disp('                        Fax:  +508-647-7001')
disp('                        Web:  www.mathworks.com')
disp('                  Newsgroup:  comp.soft-sys.matlab')
disp('                        FTP:  ftp.mathworks.com')
disp(' ')
disp('   E-mail:  ')
disp('          info@mathworks.com  Sales, pricing, and general information')
disp('       support@mathworks.com  Technical support for all products')
disp('           doc@mathworks.com  Documentation error reports')
disp('          bugs@mathworks.com  Bug reports')
disp('       service@mathworks.com  Order status, invoice, and license issues')
disp('      renewals@mathworks.com  Renewal/subscription pricing')
disp('       pricing@mathworks.com  Product and pricing information')
disp('        access@mathworks.com  MATLAB Access Program')
disp('       suggest@mathworks.com  Product enhancement suggestions')
disp('    news-notes@mathworks.com  MATLAB News & Notes Editor ')
disp('   connections@mathworks.com  MATLAB Connections Program')
disp(' ')
disp('Press any key for more. . .')
pause,clc

disp(' ')
disp('   If you are a MATLAB user, become a MATLAB Access member and receive')
disp('   free of charge the following benefits: ')
disp('   ')
disp('     - Technical support and customer service ')
disp('     - Early notification of product releases (via e-mail)')
disp('     - A password to the MATLAB Access Web site to check:')
disp('        Order status ')
disp('        Personal License Password')
disp('        Site and license information ')
disp('        Contact information ')
disp('     - Free Subscriptions to: ')
disp('        MATLAB News & Notes - The MathWorks newsletter ')
disp('        MATLAB Digest - The MathWorks electronic news bulletin')
disp(' ')
disp(' ')
disp('   To find out more about the MATLAB Access program or simply to')
disp('   join the program please visit The MathWorks Web site at ')
disp('   www.mathworks.com. ')
disp(' ')
disp('   To join, send us your name, organization, address, e-mail,')
disp('   telephone number and license number--obtained by typing "ver"')
disp('   at the MATLAB prompt.  Send it by e-mail, mail, or fax to:')
disp(' ')
disp('      The MathWorks, Inc.')
disp('      3 Apple Hill Drive')
disp('      Natick, MA 01760-2098  USA')
disp('      Fax: +508-647-7001')
disp('      E-mail: access@mathworks.com')
disp('      Web: www.mathworks.com')
disp(' ')
disp(' ')
disp('   The MATLAB Connections Program covers third-party products and')
disp('   services that complement MATLAB and SIMULINK.  For more ')
disp('   information, visit The MathWorks Web site at www.mathworks.com')
disp('   or send e-mail to connections@mathworks.com.')
disp(' ')
disp('Press any key for more. . .')
pause, clc
disp(' ')
disp('Notice to U.S. GOVERNMENT users: If Licensee is acquiring the software')
disp('on behalf of any unit or agency of the U.S. Government, the following')
disp('shall apply:')
disp('(a) For units of the Department of Defense:')
disp('    RESTRICTED RIGHTS LEGEND: Use, duplication, or disclosure by the')
disp('    Government is subject to restrictions as set forth in subparagraph')
disp('    {c}{1}(ii) of the Rights in Technical Data Clause at DFARS 252.227-7013.')
disp('(b) For any other unit or agency:')
disp('    NOTICE - Notwithstanding any other lease or license agreement that')
disp('    may pertain to, or accompany the delivery of, the computer software and')
disp('    accompanying documentation, the rights of the Government regarding its')
disp('    use, reproduction and disclosure are as set forth in Clause')
disp('    52.227-19{c}(2) of the FAR.')
disp('Manufacturer is The MathWorks, Inc., 3 Apple Hill Drive, Natick, MA 01760.')
disp(' ')
return
end   % end nargin == 0

% nargin == 1 - want info for a particular item
p = [pathsep path pathsep];
if strcmp(arg,'matlab')
    arg = 'general';
end
k = findstr([filesep arg pathsep],p);
if isempty(k), % Try again with extra filesep
    k = findstr([filesep arg filesep pathsep],p);
end
if isempty(k), return, else k = k(1); end
fp = find(p==pathsep);
lp = fp(max(find(fp < k)));
pp = p(lp+1:k+length(arg));
if exist(fullfile(pp,'Readme.m'),'file')
    if (usejava('mwt') == 1)
        helpwin(fullfile(pp, 'Readme.m'));
    else 
        html_file = fullfile(pp, 'Readme.m');
        
        % Load the correct HTML file into the browser.
        stat = web(html_file);
        if (stat==2)
            error(sprintf(['Could not launch Web browser. Please make sure that\n' ...
                    'you have enough free memory to launch the browser.']));
        elseif (stat)
            error(sprintf(['Could not load HTML file into Web browser. Please make sure that\n' ...
                    'you have a Web browser properly installed on your system.']));
        end
    end
else
  
    if (isempty(docroot))      
              html_file = fullfile(matlabroot,'help','base','relnotes','relnotes.html');
    else
        html_file = fullfile(docroot,'base','relnotes','relnotes.html');
        if ~exist(html_file)
              actual_docroot = strrep(docroot, 'jhelp','help');
              html_file = fullfile(actual_docroot,'base','relnotes','relnotes.html');
        end
    end
  
    if usejava('mwt') == 1
        web(html_file, '-helpbrowser');
    else
        % Load the correct HTML file into the browser.
        stat = web(html_file);
        if (stat==2)
            error(['Could not launch Web browser. Please make sure that'  sprintf('\n') ...
                    'you have enough free memory to launch the browser.']);
        elseif (stat)
            error(['Could not load HTML file into Web browser. Please make sure that'  sprintf('\n') ...
                    'you have a Web browser properly installed on your system.']);
        end
    end
end

