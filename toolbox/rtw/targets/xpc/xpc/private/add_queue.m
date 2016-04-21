function usrdata=add_queue(usrdata,message)

% ADD_QUEUE - xPC Target private function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:19:02 $

num=length(usrdata.apiqueue);
usrdata.apiqueue{num+1}=message;
