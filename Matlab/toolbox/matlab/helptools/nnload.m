function stat = nnload(html_file)
%NNLOAD Netscape Navigator Load
%   This function loads an URL into Netscape Navigator.
%   If  Navigator is not running, we start it up.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:29:38 $

ch = ddeinit('netscape','WWW_OpenURL');
if ch
   ddereq(ch,[html_file ',,0xFFFFFFFF']);
   ddeterm(ch);
    
   % Make sure netscape is active
   ch = ddeinit('netscape', 'WWW_Activate');
   if ch
       ddereq(ch, '0xFFFFFFFF, 0x0');
       ddeterm(ch);
   end;
   stat = 0;
else
   doccmd = find_netscape;
   clear find_netscape
   if ~isempty(doccmd)
      comm = ['"' doccmd '" ' ' "' html_file '"&' ];
      dos (comm);
      stat = 0;
   else
      stat = 1;         
   end
end
