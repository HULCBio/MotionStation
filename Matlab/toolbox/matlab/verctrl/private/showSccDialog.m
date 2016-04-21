function [approved, options] = showSccDialog(fileNames, command, capability, javaFrame)
% Show a dialog to accept user options and comments.

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/23 02:53:42 $

options             = struct('Comment', '', 'KeepCheckout', logical(0));
if (usejava('swing'))             
	dlgBuilder      = com.mathworks.verctrl.SccDialogBuilder;
    if (exist('javaFrame') == 1)
	  approved      = dlgBuilder.showDialog(command, fileNames, capability, javaFrame);
    else
      approved      = dlgBuilder.showDialog(command, fileNames, capability);  
    end
	if (approved == 1)      
      options.Comment = char(dlgBuilder.getCommentText);
      options.KeepCheckout = logical(dlgBuilder.getKeepCheckoutOption);
  end  
end
