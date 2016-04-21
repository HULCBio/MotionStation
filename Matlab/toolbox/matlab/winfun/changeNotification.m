%changeNotification   Windows 9x/NT Directory Change Notification
%
%   MATLAB makes use of a feature of the Windows operating system called a
%   Change Notification Handle that enables MATLAB to be notified any time
%   a file in an associated directory is modified.  Under certain
%   circumstances, Windows may fail to provide MATLAB with a valid and
%   responsive handle.  The three most common causes for this are:
%
%    * Windows has exhausted its supply of notification handles
%
%    * The specified directory resides on a file system that does not support
%      change notification.  The Syntax TAS fileserver software, the freely
%      distributed SAMBA fileserver, and many NFS fileservers are known to
%      have this limitation.
%
%    * Network or fileserver latency delays the arrival of the change
%      notification so that changes are not detected on a timely basis.
%
%   When MATLAB is unable to obtain a responsive Change Notification Handle,
%   it cannot automatically detect changes to directories and files.
%   For example, new functions added to an affected directory might not be
%   visible, and changed functions in memory might not be reloaded.
%
%   If the file system is one which supports UNIX-style directory timestamp
%   updates (that is, the directory timestamp is updated when a file is
%   added to the directory), you can place one or both of the following
%   commands in your matlabrc.m file to tell MATLAB to detect changes by
%   testing the timestamps of the directories:
%
%       SYSTEM_DEPENDENT('RemotePathPolicy', 'TimecheckDirFile');
%       SYSTEM_DEPENDENT('RemoteCWDPolicy', 'TimecheckDirFile');
%
%   While changes will now be detected, you may notice a performance
%   degradation due to the time required to check the timestamps.
%
%   If the file system is one (such as an NT file system) which does not
%   support UNIX-style directory timestamp updates, you can place one or both
%   of the following commands in your matlabrc.m file to force MATLAB to detect
%   changes by rereading the affected directories at frequent intervals:
%
%       SYSTEM_DEPENDENT('RemotePathPolicy', 'Reload');
%       SYSTEM_DEPENDENT('RemoteCWDPolicy', 'Reload');
%
%   While changes will now be detected, you may notice a significant
%   performance degradation due to the time required to reread the
%   directories.
%
%   There may be periods when problems related to remote file system caching
%   or network latency can keep any of the above measures from being effective.
%   If MATLAB is still unable to detect changes you have made to an M-file, 
%   you will need to clear the old copy of the function from memory using
%   CLEAR function_name.  Invoke the function again, and MATLAB will read
%   the updated function from the M-file.
%
%   If you prefer never to see warning messages about change notification,
%   you can place the following command in your matlabrc.m file to suppress 
%   all of these warnings:
%
%       SYSTEM_DEPENDENT('DirChangeHandleWarn', 'Never');
%
%   See also changeNotificationAdvanced, ADDPATH.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:34:53 $

