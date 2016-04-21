function checkoutWin(fileName, reload)
% Opens a checkout dialog for collecting the version number
% and whether to lock it 
% See also CHECKIN, CHECKOUT, CHECKINWIN
 

% Author(s): Vaithilingam Senthil
% Copyright 1998-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/06/17 13:17:00 $

com.mathworks.verctrl.CheckOutDlg(fileName, reload); 
