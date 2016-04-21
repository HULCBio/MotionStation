% README file for the MATLAB Web Server.
%
% This file contains important information about installing 
% and running MATLAB Web Server Version 1.2.1.  Please 
% read it thoroughly before attempting to work with this product.
%
%
% PLATFORM SUPPORT
%
%   MATLAB Web Server Version 1.2.1 runs with Release 12.1 of 
%   MATLAB/Simulink.  It runs only on Microsoft Windows NT 4.0,
%   Sun Solaris, and Linux.
%
%
% ADMINISTRATIVE PRIVILEGES REQUIRED FOR INSTALLATION
%
%   System Administration privileges are required for the
%   installation of the MATLAB Web Server.
%
%
% X WINDOWS RECOMMENDED FOR GRAPHICS ON UNIX
%
%   MATLAB makes use of X Windows on Unix to render jpeg
%   files efficiently.  While the matlabserver component
%   of this product can generate graphics without X Windows,
%   the best efficiency comes from the use of X Windows.
%   X Windows must be running before the matlabserver
%   is started.
%
%
% NOTE: The notation <matlab> represents the MATLAB
% root directory, the directory where MATLAB is installed
% on your system.
%
%
% CHANGES FROM PREVIOUS RELEASES
%
%   1. The server can now be configured to accept connections only
%      from specified nodes.  Create a file called hosts.conf in the
%      <matlab>/webserver directory.  List host names, one on each line,
%      from which you want connections to be accepted.  For example,
%
%      vogon.mathworks.com
%      test.mathworks.com
%      
%      Connection requests from any other host will be rejected.
%
%   2. The htmlrep function now supports a fourth optional argument.  If
%      you include 'noheader' in the string of this argument, the HTTP 
%      header, "Content-type: text/html\n\n" will not be included
%      in the output.  (Note that you must supply an empty string as 
%      the third argument if you do not want the output to also be 
%      written to a file.)
%
%   3. The distribution now includes all the CGI clients (matweb programs
%      on supported Unix platforms and matweb.exe on NT).  Now there is
%      more flexibility for running the client.  Note also that a MATLAB 
%      license is not required to run the matweb client.
%
% WEB SERVER SOFTWARE REQUIRED
%
%   You need to install Web server software (HTTP Daemon software
%   [HTTPD]) on the system where MATLAB is running or on a machine
%   that has network access to the machine where MATLAB is running.
%   There are numerous sources for obtaining this software, 
%   including:
%
%      Pre-installed Microsoft Peer Networking Services on your PC.
%
%      Netscape Enterprise Server, available by purchase from 
%      Netscape Communications, Inc.
%
%      Free distribution over the Internet (e.g., Apache: 
%      www.apache.org)
%
%      
% INSTALLATION OF VERSION 1.2.1
%
%   The installation of this release requires some additional
%   steps beyond the automated installation.
%
%      Run through the normal installation process, installing
%      MATLAB Web Server as part of MATLAB/Simulink installation
%      process.
%
%      Solaris only (test server interactively and start on
%      system boot):
%
%         1. Create the file matlabserver.conf by running the
%            script <matlab>/webserver/webconf.  Use this
%            script configurator to specify the number of 
%            simultaneous MATLABs to run, non-default TCP/IP
%            port, etc.  Use the "-h" option with this script
%            to see the various options.
%
%         2. Run startup script <matlab>/webserver/webstart
%            to start the server interactively to test.
%
%         3. <matlab>/webserver/webstat will display the
%            status of the matlabserver.
%
%         4. <matlab>/webserver/webdown will take down the
%            matlabserver.
%
%         5. <matlab>/webserver/webboot is run during the
%            system startup process to bring up the server
%            at system boot time.
%
%         6. Create the following symbolic links and file while
%            logged in as root (superuser):
%
%               ln -s <matlab>/webserver/webboot /etc/webboot_TMW5
%               ln -s <matlab>/webserver/webdown /etc/webdown_TMW5
%
%               Note: Add the -c configuration file option to webboot
%               and webdown if the matlabserver.conf file is not in
%               <matlab>/webserver or in the directory where the
%               script is located.
%
%               cp -p <matlab>/webserver/rc.web.sol2 /etc/init.d/webserver
%
%               (Edit the file /etc/init.d/webserver to remove the
%               comment characters from the code that starts X Windows
%               if you want to start X Windows automatically at this
%               point during the system boot.)
%
%         7. Add the startup to the system startup by creating a
%            symbolic link:
%
%               cd /etc/rc3.d
%               ln -s ../init.d/webserver S17webserver
%
%         8. [optional] In <matlab>/webserver/rc.web.ARCH there
%            is a section that will attempt to start the X Windows
%            system.  You can remove the comment character from this
%            code to start X Windows unless you or the system 
%            administrator start it somewhere else prior to the 
%            MATLAB Web Server startup script 
%            <matlab>/webserver/webboot.
%
%         9. Reboot the system.
%
%      All Platforms:
%
%         A. Modify the file matweb.conf in the demo directory,
%            /matlab/toolbox/webserver/wsdemos.  Replace
%            <matlabserver_host_name> with the name of the machine
%            where MATLAB is installed (and the matlabserver program
%            is running).  Replace <matlab> with the name
%            of the directory where MATLAB is installed.
%         
%            [webmagic]
%            mlserver=<matlabserver_host_name>
%         
%            [webpeaks]
%            mlserver=<matlabserver_host_name>
%            mldir=<matlab>/toolbox/webserver/wsdemos
%         
%            [webstockrnd]
%            mlserver=<matlabserver_host_name>
%            mldir=<matlab>/toolbox/webserver/wsdemos
%         
%            [players]
%            mlserver=<matlabserver_host_name>
%            mldir=<matlab>/toolbox/webserver/wsdemos
%
%         B. Create the following three aliases for your HTTPD (Web
%            server) and point them all to the demos directory,
%            <matlab>/toolbox/webserver/wsdemos:
%
%            1. the home or default directory
%
%            2. /cgi-bin
%
%            3. /icons
%               If your application produces graphic (jpeg) 
%               files, you will need to allow MATLAB to write into 
%               into an aliased location in the file system that 
%               the HTTPD can access.  For example, you can 
%               use the /icons alias to accomplish this.  
%               The mldir entry associated with the application
%               in matweb.conf provides a way for MATLAB to             
%               create files in the right place.
%
%
%            NOTE: If you do not have the ability to set up or
%            change these aliases, it will be necessary to put 
%            copies of some files in locations where the HTTPD 
%            can find them:
%
%            4. matweb (matweb.exe on NT), which can be found
%               in <matlab>/webserver/bin/sol2 on Solaris, 
%               in <matlab>/webserver/bin/glnx86 on Linux, 
%               or in <matlab>/webserver/bin/win32 on NT, must be
%               copied to the directory that is aliased by
%               /cgi-bin or equivalent.
%
%            5. matweb.conf in 
%               <matlab>/toolbox/webserver/wsdemos
%               must also be copied to the directory that is
%               aliased by /cgi-bin or equivalent.  See the 
%               documentation for more specifics on this 
%               point, especially if programmers do not have
%               write access to this directory.
%
%            6. All demo HTML files in 
%               <matlab>/toolbox/webserver/wsdemos
%               must be copied to the directory where
%               the HTTPD keeps all HTML files (often
%               referred to as the home or default alias).
%
%               Note that when aliases are different from
%               those provided in the demo HTML files, you 
%               will have to make the corresponding changes
%               in those HTML files.
%
%         C. To run the demonstration programs when the
%            default or home alias points to 
%            <matlab>/toolbox/webserver/wsdemos directory,
%            start your web browser and enter the URL:
%            http://<YOUR_DOMAIN>/index.html for the
%            current list of demonstration applications.
%         
%
% REMOVING MATLABSERVER FROM THE WINDOWS NT REGISTRY
%
%   To remove the matlabserver (MATLAB Server) entry from the NT
%   Registry, open a command window, set the default directory (cd)
%   to <matlab>/webserver/bin/win32, and type "matlabserver -remove".
%

%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.19 $  $Date: 2001/04/25 18:49:35 $

help webserver/Readme
