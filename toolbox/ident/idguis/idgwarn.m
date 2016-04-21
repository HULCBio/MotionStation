function idgwarn(mess,dum)
% IDGWARN distributes warning messages in the IDENT GUI

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/09/21 13:47:46 $

%warndlg(mess,'Warning','modal')
 
if ~isempty(mess)
    nrnl = find(double(mess)==10); %newline
    if ~isempty(nrnl)&nrnl>1
        mess = mess(1:nrnl-1);
    end
iduistat(['Warning: ',mess],0,16);
end