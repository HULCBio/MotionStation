function array = conn2array(conn)
%CONN2ARRAY Convert connectivity to array form.
%   ARRAY = CONN2ARRAY(CONN) converts CONN to its array form if CONN is
%   one of the shortcut specifiers (4, 8, 6, 18, or 26).  Otherwise ARRAY
%   is the same as CONN.
%
%   If CONN is not one of the shortcut specifiers, CONN2ARRAY does not
%   check to make sure that CONN is a valid connectivity array.
%
%   See also CONNDEF.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:10:18 $

error(nargchk(1,1,nargin,'struct'))

if isequal(conn,4)
    array = [0 1 0; 1 1 1; 0 1 0];
    
elseif isequal(conn,8)
    array = ones(3,3);
    
elseif isequal(conn,6)
    array = conndef(3,'minimal');
    
elseif isequal(conn,18)
    array = cat(3,[0 1 0; 1 1 1; 0 1 0], ...
               ones(3,3), [0 1 0; 1 1 1; 0 1 0]);
    
elseif isequal(conn,26)
    array = ones(3,3,3);
    
else
    array = conn;
end
