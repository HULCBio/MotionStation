%RESET Resets multirate filter.
%   RESET(Hm) resets all the properties of the multirate filter Hm
%   to their factory value that are modifed when the filter is run. In
%   particular, the NUMSAMPLESPROCESSED and STATES properties are reset to
%   zero and the NONPROCESSEDSAMPLES property is reset to empty (for
%   decimators only). Additionally, internal properties are also reset.

%   Author: P. Pacheco
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/30 19:21:25 $
