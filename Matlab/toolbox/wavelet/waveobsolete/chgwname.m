function chgwname(filename,wname,newfilename)
%CHGWNAME Change the name of wavelet in a WP data structure.
%   CHGWNAME(FILENAME,WNAME,NEWFILENAME)
%   If the file FILENAME contains a variable data_struct
%   the name of wavelet is replaced by WNAME.
%   A new file which name is NEWFILENAME is saved.
%
%   CHGWNAME(FILENAME,WNAME) uses FILENAME for saving.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 01-Jun-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10 $

try
  err = 0;
  load(filename,'-mat');
  err = ~exist('data_struct','var');
  if ~err
      try
        wavemngr('type',wname);
      catch
        err = 1;
        msg = [wname ' is not a valid name of wavelet!'];
      end
  else
      msg = ['Variable "data_struct" not found!'];
  end
catch
  err = 1;
  msg = ['File ' filename ' not found!'];
end
if err
    errargt(mfilename,msg,'msg');
    return; 
end
data_struct = wdatamgr('write_wave',data_struct,wname);
[fileStruct,err] = wfileinf(filename);

if nargin<3 , newfilename = filename; end
saveStr = newfilename;
for k = 1:length(fileStruct)
    saveStr = [saveStr ' ' fileStruct(k).name];
end
saveStr = ['save ' saveStr ' -mat'];
eval(saveStr,'err = 1;');
if err , errargt(mfilename,'Save FAILED !','msg'); end

