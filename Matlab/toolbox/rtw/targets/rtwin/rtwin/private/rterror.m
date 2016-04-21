function rterror(msg)
%RTERROR Real-Time Windows Target error message.
%
%   RTERROR displays Real-Time Windows Target error message in a dialog box.
%
%   Private function.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 18:51:05 $  $Author: batserve $

errordlg(msg,'Real-Time Windows Target','modal');
