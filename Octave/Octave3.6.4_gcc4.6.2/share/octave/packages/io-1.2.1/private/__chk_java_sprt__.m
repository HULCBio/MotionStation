## Copyright (C) 2013 Philip Nienhuis <prnienhuis@users.sf.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## __chk_java_sprt__ Internal io package function

## Author: Philip <Philip@DESKPRN>
## Created: 2013-03-01

function [ tmp1, jcp ] = __chk_java_sprt__ ()

  try
    jcp = javaclasspath ("-all");          # For java pkg >= 1.2.8
    if (isempty (jcp)), jcp = javaclasspath; endif  # For java pkg <  1.2.8
    ## If we get here, at least Java works. Now check for proper version (>= 1.6)
    jver = ...
      char (java_invoke ('java.lang.System', 'getProperty', 'java.version'));
    cjver = strsplit (jver, ".");
    if (sscanf (cjver{2}, "%d") < 6)
      warning ...
        ("\nJava version too old - you need at least Java 6 (v. 1.6.x.x)\n");
      return
    endif
    ## Now check for proper entries in class path. Under *nix the classpath
    ## must first be split up. In java 1.2.8+ javaclasspath is already a cell array
    if (isunix && ~iscell (jcp));
      jcp = strsplit (char (jcp), pathsep ()); 
    endif
    tmp1 = 1;
  catch
    ## No Java support
    tmp1 = 0;
  end_try_catch

endfunction
