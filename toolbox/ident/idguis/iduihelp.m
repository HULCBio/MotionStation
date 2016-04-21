function iduihelp(file,title)
%IDUIHELP Wrapper function to hthelp.

%   L. Ljung 4-4-95
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:38 $

nr = find(file=='.');
file = [file(1:nr) 'htm'];

stat = 1;
htfile=which(file);
if (strncmp(computer,'MAC',3))
   htfile=['file:/' strrep(htfile,filesep,'/')];
end
stat=web(htfile);
if stat==2
   disp(['Could not launch Web browser. Please make sure that' ...
         sprintf('\n') 'you have enough free memory to launch the browser.']);
elseif (stat)
   disp(['Could not load HTML file into Web browser. Please make sure that'...
  sprintf('\n') 'you have a Web browser properly installed on your system.']);
end
if stat hthelp(file);end