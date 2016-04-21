--
-- wsh.lua
--
-- $Id: wsh.lua,v 1.1 2012/04/06 22:49:36 keithmarshall Exp $
--
-- Lua 5.2 module providing a simple API for invoking system services
-- via the Microsoft Windows Scripting Host.
--
--
-- This file is a component of mingw-get.
--
-- Written by Keith Marshall <keithmarshall@users.sourceforge.net>
-- Copyright (C) 2012, MinGW Project
--
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
--
   local M = {}
   local cscript = "cscript -nologo"
--
   function M.execute( ... )
     local function wsh_prepare( interpreter, ... )
       for argind, argval in ipairs {...}
       do
	 interpreter = interpreter .. " " .. argval
       end
       return interpreter
     end
     os.execute( wsh_prepare( cscript, ... ) )
   end
--
   function M.libexec_path( script, subsystem )
     local script_path = os.getenv( "APPROOT" )
     if script_path
     then
       script_path = script_path .. "libexec\\"
     else
       script_path = ".\\libexec\\"
     end
     if subsystem
     then
       script_path = script_path .. subsystem .. "\\"
     end
     return script_path .. script
   end
--
   return M
--
-- $RCSfile: wsh.lua,v $: end of file */
