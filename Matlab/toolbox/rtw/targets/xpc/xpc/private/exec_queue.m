function usrdata=exec_queue(usrdata,dummy)

% EXEC_QUEUE - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:19:14 $

if nargin==2
     
   for i=1:length(usrdata.apiqueue);
      eval(usrdata.apiqueue{i});
   end;
   usrdata.apiqueue={};
   
else
   
   state=get(usrdata.figure.scope.pb_start,'String');
   if strcmp(state,'Start')
      for i=1:length(usrdata.apiqueue);
         eval(usrdata.apiqueue{i});
      end;
      usrdata.apiqueue={};
   end;
   
end;

      

   
   

