%changeNotificationAdvanced   Windows 9x/NT Directory Change Notification
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
%   MATLAB makes available a number of SYSTEM_DEPENDENT features that
%   support selection and tuning of the policies to be used when
%   Windows cannot provide MATLAB with a valid Change Notification Handle
%   for a remote directory.
%
%       POLICY = SYSTEM_DEPENDENT('RemoteCWDPolicy',  POLICY)
%       POLICY = SYSTEM_DEPENDENT('RemotePathPolicy', POLICY)
%
%   These functions affect the change detection policies for a remote
%   current working directory and for remote directories on the path,
%   respectively.  These functions always return the policy in effect
%   before the function is called.
%
%   Policy is one of the strings:
%
%       'Reload'            re-read directories at frequent intervals
%       'TimecheckDir'      detect new files via directory timestamp changes
%       'TimecheckFile'     detect changed files via file timestamp changes
%       'TimecheckDirFile'  'TimecheckDir' and 'TimecheckFile'
%       'None'              do not check for directory or file changes
%       'Status'            return the policy currently in effect
%
%   The 'Reload' policy is designed to make new files visible in directories
%   (such as those on NT file systems) that do not have their directory
%   timestamps updated by the addition of new files.  This policy should
%   be used only when necessary, as its use can significantly degrade
%   performance.
%
%   The 'TimecheckDir' policy is designed to make new files visible in
%   directories (such as those on many NFS fileservers) that have their
%   directory timestamp updated when a new file is added to the directory.
%
%   The 'TimecheckFile' policy is designed to make changes to existing
%   files visible in directories on all types of file systems.
%
%   The 'TimecheckDirFile' policy provides both 'TimecheckDir' and
%   'TimecheckFile'.
%
%   The 'None' policy is designed to provide maximum performance when it
%   is not necessary to detect new files or changes files in affected
%   directories.
%
%   The 'Status' policy can be used to get the policy currently in effect.
%
%   There may be periods when problems related to remote file system cacheing
%   or network latency can keep any of the above measures from being effective.
%   If MATLAB is still unable to detect changes you have made to an M-file, 
%   you will need to clear the old copy of the function from memory using
%   CLEAR function_name.  Invoke the function again, and MATLAB will read
%   the updated function from the M-file.
%
%   There are additional SYSTEM_DEPENDENT features that you can utilize to
%   understand the impact of lack of Change Notification Handles on your
%   application and the affect of various policies on your performance.
% 
%   SYSTEM_DEPENDENT('DirChangeHandleWarn', OPTION) controls the warnings
%   issued when a directory fails to get a valid Change Notification
%   Handle.  These warnings can help you analyze which directories are
%   affected by lack of Windows Change Notification Handles.
%
%   Option is one of the strings:
%
%       'Always'    warn of all invalid Change Notification Handles
%       'Once'      warn of only the first invalid Handle on each file system
%       'Never'     never warn of invalid Change Notification Handles
%       'Status'    return the option currently in effect
%
%   SYSTEM_DEPENDENT('DirReloadMsg','on') enables a message each time
%   MATLAB reloads a directory from the file system.  This can be
%   used to understand and characterize the performance impact of a
%   policy selection, especially the 'Reload' policy.
%
%   SYSTEM_DEPENDENT('DirReloadMsg','off') disables this message.
%
%   SYSTEM_DEPENDENT('DirReloadMsg','status') returns the current setting.
%
%   See also ADDPATH, changeNotification.



% $Revision: 1.1.6.1 $
%   Copyright 1984-2002 The MathWorks, Inc. 
