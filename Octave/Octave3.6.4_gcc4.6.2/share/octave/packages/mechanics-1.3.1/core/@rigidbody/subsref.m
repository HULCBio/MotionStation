## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

function out = subsref (obj, idx)

  if ( !strcmp (class (obj), 'rigidbody') )
    error ("object must be of the rigidbody class but '%s' was used", class (obj) );
  elseif ( idx(1).type != '.' )
    error ("invalid index for class %s", class (obj) );
  endif

# Error strings
  method4field = "Class %s has no field %s. Use %s() for the method.";
  typeNotImplemented = "%s no implemented for Class %s.";
  
  method = idx(1).subs;

  switch method
    case 'plot'
    
     if numel (idx) == 1 % obj.plot doesn't exists
       error (method4field, class (obj), method, method);
     elseif strcmp (idx(2).type, '()')
        if !isempty (idx(2).subs)
          out = plot (obj, idx(2).subs{:});
        else
          out = plot (obj);
        end
     else 
       error (typeNotImplemented,[method idx(2).type], class (obj));
     end
      
    otherwise
      error ("invalid index for reference of class %s", class (obj) );
  endswitch

endfunction
