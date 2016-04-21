function isok = usejava(feature)
%USEJAVA  True if the specified Java feature is supported in MATLAB.
%   USEJAVA(LEVEL) returns 1 if the feature is supported and 
%   0 otherwise.
%
%   The following levels of support exist:
%
%   LEVEL      MEANING
%   -----------------------------------------------------
%   'jvm'      The Java Virtual Machine is running.
%   'awt'      AWT components are available.
%   'swing'    Swing components are available.
%   'desktop'  The MATLAB interactive desktop is running.
%
%   "AWT components" refers to Java's GUI components in the Abstract 
%   Window Toolkit.  "Swing components" refers to Java's lightweight 
%   GUI components in the Java Foundation Classes.
%
%   EXAMPLES:
%
%   If you want to write an m-file that displays a Java Frame and want
%   to be robust to the case when there is no display set or no JVM
%   available, you can do the following:
%   
%   if usejava('awt')
%      myFrame = java.awt.Frame;
%   else
%      disp('Unable to open a Java Frame.');
%   end
%
%   If you want to write an m-file that uses Java code and want it to
%   fail gracefully when run in a MATLAB session that does not have access
%   to a JVM, you can add the following check:
%
%   if ~usejava('jvm')
%      error([mfilename ' requires Java to run.']);
%   end
%
%   See also JAVACHK

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 17:03:35 $

isok = system_dependent('useJava',feature);
