## Author: Paul Kienzle <pkienzle@users.sf.net>
## This program is granted to the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {[@dots{}] =} strsort (@dots{})
## Overloads the sort function to operate on strings.
##
## @seealso {sort}
## @end deftypefn

# PKG_ADD dispatch ("sort", "strsort", "string")
function [sorted,idx] = strsort(string,varargin)
  if nargout == 2
    [s,idx] = sort(toascii(string),varargin{:});
  else
    s = sort(toascii(string),varargin{:});
  endif
  sorted = char(s);
endfunction
