function varargout=report(varargin)
%REPORT Generate a report from a setup file
%   REPORT <filename> generates a report from the given setup
%   file.  Multiple files are allowed.  If the setup file
%   has an .rpt extension, the extension must not be included
%   in <filename>.
%
%   REPORT <systemname> generates a report from the given
%   Simulink system.  If the system's ReportName property
%   is empty, the parent's ReportName property is used.
%
%   REPORT with no arguments opens the Report Generator editor.
%
%   See also SETEDIT, RPTLIST, RPTCONVERT, COMPWIZ

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:50 $

%   Note: can also call REPORT(RPTSP) where RPTSP is a
%   RPTSP (Setup File Pointer) object.

%   Note: can also call with flags
%     -noview (prevents launching file viewer)
%     -graphical (launches rptlist on generating)
%     -debug (turns debug mode on)
%     -quiet (sets error echo level to 0)
%     -fRTF, -fRTF97, -fHTML (sets output format)
%     -sSHEETNAME (sets stylesheet name - not required when choosing format)

varargout = rptgen.report(varargin{:});
