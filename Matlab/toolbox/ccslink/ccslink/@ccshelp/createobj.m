function symbobj = createobj(cc,sname,opt,varargin)
% CREATEOBJ Creates a link to an embedded symbol.
% 	O = CREATEOBJ(CC,SYMBOL) - returns an object handle O to the embedded
% 	symbol SYMBOL. SYMBOL can be any variable name or function name. By
% 	default, the embedded variable within scope is created. 
% 	
% 	O = CREATEOBJ(CC,SYMBOL,OPT) - returns an object handle O to the
% 	embedded symbol SYMBOL, the scope of which is specified by OPT. OPT can
% 	be 'local', 'global' or 'static'. OPT can also be 'function' - see more
% 	information below. 
% 	
% 	Depending on the type and storage device of the symbol, object O
% 	created can be fall on any of four major object classes:
% 	
% 	I.  MEMORYOBJ
%         Any symbol that resides in the DSP memory.
%         
%         Derived Classes:
% 		1.  NUMERIC class       -       handle to a primitive data type (float,int,short,...)
%             
%           Derived Classes:
% 			a.  POINTER class   -       handle to a pointer data type (unsigned int)
% 			b.  ENUM class      -       handle to an enumerated data type (int)
% 			c.  STRING class    -       handle to a string data type (char)
%             
% 		2.  BITFIELD class      -       handle to a bitfield data type
% 	
% 	II. REGISTEROBJ
%         Any symbol that resides in a DSP register.
%         
%         Derived Class
% 		  RNUMERIC class        -       handle to a primitive data type (float,int,short,...)
%             
%           Derived Classes:
% 			a.  RPOINTER class  -       handle to a pointer data type (unsigned int)
% 			b.  RENUM class     -       handle to an enumerated data type (int)
% 			c.  RSTRING class   -       handle to a string data type (char)
%             
% 	III.STRUCTURE
% 		Container class for MEMORYOBJ and/or REGISTEROBJ objects.
%         - C struct type
%         - C union type.
% 	
% 	IV. FUNCTION
% 		Any C-callable functions.
%
% 	    O = CREATEOBJ(CC,SYMBOL,'function',OPT1,VALUE1,...) - Creates a
% 	    Function handle, where OPTn can be 'funcdecl', 'filename',
% 	    'allocate'.
%
%       OPTION          VALUE
%       'funcdecl'      C function declaration (string)
%       'filename'      File where function definition is found (string)
%       'allocate'      Cell array containing name of pointer input as the 1st element 
%                       and size of buffer the input points to as the 2nd element
%       Example:
%       ff = createobj(cc,'foo','function','funcdecl','int foo(int *a, int *b, short n)')
%       ff = createobj(cc,'foo','function','filename','c:\MATLAB6p5\work\FilterFFT.c')
%       - constructor uses this information to set I/O properties of the
%       Function object
%
%       ff = createobj(cc,'foo','function','allocate',{'a',5},'allocate',{'b',10})
%       - constructor allocates for inputs 'a' and 'b' each a buffer of size 5 (elements) 
%       on the stack
%
% 	See also LIST.

% Copyright 2004 The MathWorks, Inc.
