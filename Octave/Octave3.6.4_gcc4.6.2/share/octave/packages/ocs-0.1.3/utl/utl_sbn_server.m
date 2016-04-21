## Copyright (C) 2006,2007,2008  Carlo de Falco            
##
## This file is part of:
## OCS - A Circuit Simulator for Octave
##
## OCS is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program (see the file LICENSE); if not,
## see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net> 

## -*- texinfo -*-
## @deftypefn{Function File} {} utl_sbn_server(@var{port})
## Listen for socket connections on port @var{port}, read a command @
## and return the corresponding output to the socket. 
## @end deftypefn

function utl_sbn_server (portnum)
  
  QUITMESSAGE    = "quit UTLsbnserver";
  CONFIRMMESSAGE = "confirmed";

  ## CREATE THE SOCKET AND WAIT FOR CONNECTIONS
  s = socket(AF_INET, SOCK_STREAM, 0);
  if s < 0
    error("cannot create socket\n");
  end
  
  if bind(s, portnum) < 0
    error("bind failed\n");
  end

  if listen(s, 1) < 0
    error("listen failed\n");
  end

  ##MAIN LOOP
  while 1

    ##ACCEPT CONNECTIONS
    c = accept(s);
    if c < 0
      error("connection error")
    end
    
    ## READ COMMANDS FROM THE SOCKET  
    msg = readstring (c)
    
    ##IF CLIENT SENT SHUTDOWN MESSAGE EXIT
    if strcmp (msg,QUITMESSAGE)
      printf("client requested server shutdown, goodbye!\n");
      disconnect(c); disconnect(s);
      break
    end
    
    ##EXECUTE COMMANDS FROM THE CLIENT
    [A,B,C] = eval(msg);
    
    ##SEND OUTPUT TO THE CLIENT
    str = [ sprintf("%17g ",A) "\n" sprintf("%17g ",B)...
	   "\n" sprintf("%17g ",C) "\n"]
    
    send(c,str);

    ##END CONNECTION
    disconnect(c);
    
  end

  disconnect(s);
endfunction


function msg = readstring (c)
  
  BUFFER_SIZE = 255;

  msg  = '';
  read = BUFFER_SIZE;

  while read >= BUFFER_SIZE
    newmsg = char(recv(c, BUFFER_SIZE));
    read = length(newmsg)
    msg = [ msg newmsg];
  end

endfunction
