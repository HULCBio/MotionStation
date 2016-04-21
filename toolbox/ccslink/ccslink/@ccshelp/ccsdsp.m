function cc = ccsdsp(varargin)
%CCSDSP create a link to the Texas Instruments Code Composer(R) IDE.
%   CC = CCSDSP('PropertyName',PropertyValue,...) returns an object which
%   is used to communicate with a DSP target processor.  This handle can be
%   used to access memory and control the execution of  the target DSP
%   processor. CCSDSP can also be used to create an array of objects for a
%   multiprocessor board. If CC is an array, any method called by CC is
%   sequentially broadcasted to all processors connected to the CCSDSP
%   object. All communication is handled by the Code Composer Studio(R) IDE
%   application.   
%   
%   All passed parameters are interpreted as object property definitions.
%   Each property definition consists of a property name followed by the
%   desired property value.  Although any CC object property can be defined
%   during this initialization, there are several important properties that
%   MUST be provided during the initial call.  Therefore, these must be
%   properly delineated when the object is created.  After the object is
%   built, these values can be retrieved with GET, but never modified. 
%
%   'boardnum' - The index of the desired DSP board.  The resulting object
%   CC refers to a DSP processor on this board.  Use the CCSBOARDINFO
%   utility to determine the number for the desired DSP board.  If the
%   user's Code Composer is defined to support only a single board, this
%   property definition can be skipped.  If the property is not passed by
%   the user, the object will default to boardnum 0 (zero-based).  
%
%   'procnum' - The index of the desired DSP processor on the DSP board 
%   selected with the 'boardnum' property. The property can also be an
%   array of processor indices in a multiprocessor board.  This will result
%   to CC being an array of objects that correspond to the specified
%   processors. Use the CCSBOARDINFO utility to determine the number for
%   the desired DSP processor(s).  If the user's Code Composer is defined
%   to support only a single processor on the board, this property
%   definition can be skipped.  In a single-processor board, if the
%   property is not passed by the user, the object will default to procnum
%   0 (zero-based). In a multiprocessor board, if the property is not
%   passed by the user, 'procnum' will default to [0,...,N-1], where N is
%   the number of processors in the board. 
%
%   Example: 
%   target = ccsdsp('boardnum',1,'procnum',0); 
%   - will return a handle to the first DSP processor on the second DSP board.
%
%   target = ccsdsp('boardnum',0,'procnum',[0 1]); 
%   - will return a 1x2 array of handles to the first and second DSP processor
%   on the first DSP board.
%   target(1) <-- handle for first processor (0)   
%   target(2) <-- handle for second processor (1)   
%
%   CCSDSP without any passed arguments will construct the object with the 
%   default property values.
%
%   Example: Single-processor board (one processor in board 0)
%   target = ccsdsp('boardnum',0); 
%   - will return a handle to the first DSP processor on the first DSP board.
%
%   Example: Multi-processor board (three processors in board 0)
%   target = ccsdsp('boardnum',0); 
%   - will return an array of handles, i.e., target(1), target(2), target(3), 
%   where each handle corresponds to a DSP processor in the first board.
%   
%   See also CCSBOARDINFO, RTDX, GET, SET.

% Copyright 2004 The MathWorks, Inc.
