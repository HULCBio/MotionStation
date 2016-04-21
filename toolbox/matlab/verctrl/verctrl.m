function varargout = verctrl(varargin)                                          
%VERCTRL Version control operations on PC platforms
%   List = VERCTRL('all_systems') returns a list of all of the version control 
%   systems installed in the current machine.
%  
%   fileChange = VERCTRL(COMMAND,FILENAMES,HANDLE) performs the version control
%   operation specified by COMMAND on FILENAMES, which is a cell array of files.
%   HANDLE is a window handle. These commands return a logical 1 to the workspace 
%   if the file has changed on disk or a logical 0 to the workspace if the file 
%   has not changed on disk.   
%   Available values for COMMAND that can be used with the FILENAMES argument:
% 
%       'get'           Retrieves a file or files for viewing and compiling, but 
%                       not editing. The file or files will be tagged read-only. 
%                       The list of files should contain either files or directories 
%                       but not both.
%   
%       'checkout'      Retrieves a file or files for editing.
%                                             
%       'checkin'       Checks a file or files into the version control system,
%                       storing the changes and creating a new version.                        
%
%       'uncheckout'    Cancels a previous check-out operation and restores the 
%                       contents of the selected file or files to the precheckout version.
%                       All changes made to the file since the checkout are lost.
%                       
%       'add' 		    Adds a file or files into the version control system.                  
%
%       'history'       Displays the history of a file or files. 
%
%   VERCTRL(COMMAND,FILENAMES,HANDLE) performs the version control
%   operation specified by COMMAND on FILENAMES, which is a cell array of files.
%   HANDLE is a window handle. 
%   Available values for COMMAND that can be used with the FILENAMES argument:
%
%       'remove'        Removes a file or files from the version control system. 
%                       It does not delete the file from the local hard drive, 
%                       only from the version control system.
% 
%   fileChange = VERCTRL(COMMAND,FILE,HANDLE) performs the version control operation
%   specified by COMMAND on FILE, which is a single file. HANDLE is a window handle. 
%   These commands return a logical 1 to the workspace if the file has changed on 
%   disk or a logical 0 to the workspace if the file has not changed on disk.   
%   Available values for COMMAND that can be used with the FILENAMES argument:
% 
%       'properties'    Displays the properties of a file. 
%                      
%       'isdiff'        Compares a file with the latest checked in version 
%                       of the file in the version control system. Returns 
%                       1 if the files are different and it returns 0 if the 
%                       files are identical.    
%
%   VERCTRL(COMMAND,FILE,HANDLE) performs the version control operation
%   specified by COMMAND on FILE, which is a single file. HANDLE is a window handle.  
%   Available values for COMMAND that can be used with the FILENAMES argument:
%                      
%       'showdiff'      Displays the differences between a file and the latest checked in 
%                       version of the file in the version control system. 
%
%   This function supports different version control commands on PC platforms. It is 
%   necessary to make a window and get its handle prior to calling version control 
%   commands which have the HANDLE argument. A basic example for making 
%   a window and getting its handle is shown below. 
% 
%   Examples:
%   Make a Java window and get its handle.
%           import java.awt.*;
%	        frame = Frame('Test frame');
%	        frame.setVisible(1);
%	        winhandle = com.mathworks.util.NativeJava.hWndFromComponent(frame)
%
%           winhandle =
%
%	        919892 
%  
%   Return a list in the command window of all version control systems 
%   installed in the machine.
%   List = verctrl('all_systems')
%   List =     
%               'Microsoft Visual SourceSafe'
%               'Jalindi Igloo'
%               'PVCS Source Control'
%               'ComponentSoftware RCS'   
%      
%   Check out D:\file1.ext from the version control system. This command
%   opens 'checkout' window and returns a logical 1 to the workspace if the 
%   file has changed on disk or a logical 0 to the workspace if 
%   the file has not changed on disk.
%   fileChange = verctrl('checkout',{'D:\file1.ext'},winhandle)
%     
%   Add D:\file1.ext and D:\file2.ext to the version control system.
%   This command opens 'add' window and returns a logical 1 to the workspace if the 
%   file has changed on disk or a logical 0 to the workspace if 
%   the file has not changed on disk.
%   fileChange = verctrl('add',{'D:\file1.ext','D:\file2.ext'},winhandle)
%     
%   Display the properties of D:\file1.ext. This command opens 'properties'
%   window and returns a logical 1 to the workspace if the 
%   file has changed on disk or a logical 0 to the workspace if 
%   the file has not changed on disk.
%   fileChange = verctrl('properties','D:\file1.ext',winhandle)
%   
%   See also CHECKIN,CHECKOUT,UNDOCHECKOUT,CMOPTS 
%   
%   Copyright 1998-2002 The MathWorks, Inc.
%
%   $Revision: 1.3 $  $Date: 2002/03/27 13:44:24 $

