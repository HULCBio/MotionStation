function status = savepath

% Copyright 2004 The MathWorks, Inc.

   warning('Compiler:NoSavePath', ....
           'The SAVEPATH function cannot be used in compiled applications.' );

   % Always fail
   status = 1;