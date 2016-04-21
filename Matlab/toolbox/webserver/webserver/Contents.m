% MATLAB Web Server
% Version 1.2.3 (R14) 05-May-2004 
% Copyright 1998-2004 The MathWorks, Inc.
%
% Release information.
%   Readme               - Display information about version 1.2.
%
% Support programs and resources.
%   matlabserver         - MATLAB Server (Solaris only).
%   matlabserver.exe     - MATLAB Server (NT only).
%   matweb               - MATLAB CGI client (works on Solaris only).
%   matweb.exe           - MATLAB CGI client (works on NT only).
%
% Configuration files and configuration templates.
%   matlabserver.conf    - Server configurations.
%   matweb.conf          - Application list template.
%
% Unix scripts for running matlabserver.
%   webboot               - Start matlabserver at system boot.
%   webconf               - Manages matlabserver.conf.
%   webdown               - Brings down matlabserver.
%   webstart              - Start matlabserver while system is up.
%   webstat               - Reports status of matlabserver.
%
% Core MATLAB functions supporting MATLAB Web Server.
%   htmlrep              - Substitute values for variable names in HTML.
%   matweb               - Main entry point for all applications.
%   wscleanup            - Purge directory of stale files.
%   wsprintjpeg          - Screen or non-screen capture jpeg file creation.
%   wssetfield           - Add new field or append to existing field.
%
% Templates for building applications.
%   input_template.html  - Template for creating an HTML input form.
%   mfile_template.m     - Guide for creating applications.
%   output_template.html - Template for creating an HTML output document.
%   tmfile_template.m    - Standalone test function template.
% 
% Magic squares matrix displayed in HTML table demonstration.
%   twebmagic.m          - Example standalone test of webmagic function.
%   webmagic1.html       - Magic squares input form.
%   webmagic2.html       - Magic squares output template.
%   webmagic.m           - Magic squares into HTML table.
%
% MATLAB surf peaks demonstration using HTML frames and graphics.
%   dummy.html           - Web surf peaks initial sub-document.
%   peaksplot.html       - Web surf peaks input form.
%   peaks-jr.jpg         - Web surf peaks graphic icon.
%   webpeaks1.html       - Web surf peaks frame document.
%   webpeaks2.html       - Web surf peaks output template.
%   webpeaks.m           - Web surf peaks application.
%
% Stock price simulation demonstration using frames and graphics.
%   twebstockrnd.m       - Stand-alone test driver for webstockrnd.
%   webstock.html        - HTML input form.
%   webstock1.html       - HTML main frame.
%   webstock2.html       - HTML output template.
%   webstockrnd.m        - Stock future price path simulation.
%   webstocktemp.html    - HTML output place holder.
%
% Softball players display of text file in an HTML table.
%   players.html         - HTML output form.
%   players.m            - Sample display of softball statistics file.
%   players.txt          - Text data file.
%   wstextread.m         - Puts a delimited file in a cell array of strings.
%   tplayers.m           - Standalone test driver for players.
%
% Samples of dynamically generated HTML tables and select lists.
%   thtmlrep.m           - Test of the HTMLREP function.
%   thtmlrep1.html       - HTML input form.
%
% Miscellaneous files used in demonstrations.
%   index.html           - HTML demonstrations home page. 
%   mathby.gif           - Math by The MathWorks.
%   MathWorks.Logo.gif   - The MathWorks logo.

% Generated from Contents.m_template revision 1.1.4.1   $Date: 2004/04/08 21:10:46 $

