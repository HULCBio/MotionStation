function status = home

  warning('Compiler:NoHome', ....
           'The HOME function will do nothing in compiled applications.' );

   % Always fail
   status = 1;