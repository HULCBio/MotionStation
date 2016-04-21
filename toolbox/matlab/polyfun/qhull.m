function varargout = qhull(varargin)
%QHULL  Copyright information for Qhull.
%
%%%%%% Qhull Copyright notice. %%%%%
%
%                     Qhull, Copyright (c) 1993-2003
% 
%        The National Science and Technology Research Center for
%         Computation and Visualization of Geometric Structures
%                         (The Geometry Center)
%                        University of Minnesota
%                             400 Lind Hall
%                         207 Church Street S.E.
%                       Minneapolis, MN 55455  USA
% 
%                        email: qhull@qhull.org
% 
% This software includes Qhull from The Geometry Center.  Qhull is 
% copyrighted as noted above.  Qhull is free software and may be obtained 
% via http from www.qhull.org.  It may be freely copied, modified, 
% and redistributed under the following conditions:
% 
% 1. All copyright notices must remain intact in all files.
% 
% 2. A copy of this text file must be distributed along with any copies 
%    of Qhull that you redistribute; this includes copies that you have 
%    modified, or copies of programs or other software products that 
%    include Qhull.
% 
% 3. If you modify Qhull, you must include a notice giving the
%    name of the person performing the modification, the date of
%    modification, and the reason for such modification.
% 
% 4. When distributing modified versions of Qhull, or other software 
%    products that include Qhull, you must provide notice that the original 
%    source code may be obtained as noted above.
% 
% 5. There is no warranty or other guarantee of fitness for Qhull, it is 
%    provided solely "as is".  Bug reports or fixes may be sent to 
%    qhull_bug@qhull.org; the authors may or may not act on them as 
%    they desire.
%
%%%%%% End of Qhull Copyright notice. %%%%%
%
%   See also CONVHULLN, DELAUNAYN, VORONOIN.

%%%%%% Qhull modification notice %%%%%
%
%   The MathWorks, Inc. changed Qhull 2003.1 as follows:
%
%   unix.c:     replaced by qhullmx.c (replacing main() by mexFunction())
%   global.c:   a line that frees the original data is changed since 
%               MATLAB doesn't change input data. Added qh_init_mwerrmsg 
%               to initialize mwerrmsg.
%   io.c,io.h:  changed qh_compare_facetvisit to non-static since this 
%               function is exported from libmwqhull and used in qhullmx.c
%   io.c:       modified printing functions to adjust output for MATLAB use
%   qhull_a.h:  defined fprintf as mwprintf to capture error and warning
%               messages back to MATLAB
%   qhull.h:    added "extern" lines for qhT to allow exporting data for
%               WIN32, added extra field mwerrmsg to qhT structure to allow
%               passing Qhull error messages to MATLAB.
%   qhull.c     added mwprintf function.
%
%%%%%% End of Qhull modification notice %%%%%
%

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $ $Date: 2004/01/16 20:04:59 $

