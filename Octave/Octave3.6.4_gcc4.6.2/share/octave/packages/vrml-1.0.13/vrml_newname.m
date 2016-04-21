## Copyright (C) 2005-2012 Etienne Grossmann <etienne@egdn.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## n = vrml_newname (root)      - A name for a vrml node, starting by root
## 
## vrml_newname ("-clear")
function n = vrml_newname (root)

persistent vrml_namespace = struct();

if nargin < 1, root = ""; end

if strcmp (root, "-clear"),
  vrml_namespace = struct ();
  return
end
if isempty (root), root = "N"; end

n = sprintf ([root,"%0d"],100000*rand());
while isfield (vrml_namespace, n)
  n = sprintf ([root,"%0d"],100000*rand());
end
endfunction

