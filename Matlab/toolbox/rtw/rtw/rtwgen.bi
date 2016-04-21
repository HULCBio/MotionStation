function [varargout] = rtwgen(varargin)
% RTWGEN Creates RTW file (model.rtw) from a block diagram.
%
%       RTWGEN is designed to be used from the RTW Build procedures. The
%       syntax may change from release to release. It is not intended for
%       direct use.
%
%       Usage:
%          [sfcns,buildInfo] = rtwgen('model','OptionName','OptionValue',...)
%
%       The following option name and value pairs are valid.
%
%       'CaseSensitivity': Specified as either 'on' or 'off'. Case
%       sensitivity for identifiers. The default is on.
%
%       'ReservedIdentifiers': Specified as a cell array of strings.
%       These are illegal identifiers.
%
%       'StringMappings': This is a cell array of strings giving a
%       string mapping table for Name values in the model.rtw file.
%       For example {sprintf('\n'),' '} converts new-lines to space
%       characters.
%
%       'WriteBlockConnections' Specified as either 'on' or 'off'.
%        Specifying 'on' causes the connections record to be written
%        out for all blocks instead of only s-function blocks. Also,
%        the DirectFeedThrough setting is written out for block inputs.
%
%	'SrcWorkspace': Specified as 'base', 'current' or 'parent'. This
%        is the workspace for rtwgen.
%
%       'OutputDirectory': Location to place model.rtw file in.
%
%       'Language': Specified as 'C', 'Ada', 'none', the default is 'C'.
%       Specifying a language causes a default list of reserved
%       identifiers and string mappings to be used for the language.
% 	ReservedIdentsForC:
%	    ['auto',      'break',       'case',    'char',      'const',
%	     'continue',  'default',     'do',      'double',    'else',
%	     'enum',      'extern',      'float',   'for',       'goto',
%	     'if',        'int',         'long',    'register',  'return',
%	     'short',     'signed',      'sizeof',  'static',    'struct',
%	     'switch',    'typedef',     'union',   'unsigned',  'void',
%	     'volatile',  'while',       'fortran', 'asm',       'Vector',
%	     'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%	     'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%	     'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani'
%            'TRUE',      'FALSE']
%	ReservedIdentsForAda:
%	    ['abort',     'abs',         'abstract','accept',    'access',
%	     'aliased',   'all',         'and',     'array',     'at',
%	     'begin',     'body',        'case',    'constant',  'declare',
%	     'delay',     'delta',       'digits',  'do',        'else',
%	     'elsif',     'end',         'entry',   'exception', 'exit',
%	     'for',       'function',    'generic', 'goto',      'if',
%	     'in',        'is',          'limited', 'loop',      'mod',
%	     'new',       'not',         'null',    'of',        'or',
%	     'others',    'out',         'package', 'pragma',    'private',
%	     'procedure', 'protected',   'raise',   'range',     'record',
%	     'rem',       'renames',     'requeue', 'return',    'reverse',
%	     'select',    'separate',    'subtype', 'tagged',    'task',
%	     'terminate', 'then',        'type',    'until',     'use',
%	     'when',      'while',       'with',    'xor',       'Vector',
%	     'Matrix',    'rtInf',       'Inf',     'inf',       'rtMinusInf',
%	     'rtNaN',     'NaN',         'nan',     'rtInfi',    'Infi',
%	     'infi',      'rtMinusInfi', 'rtNaNi',  'NaNi',      'nani',
%            'integer',   'boolean',     'float'}
%      	StringMappings:
%           ['\n',' ', '/*','/+', '*/','+/']
%
%       Return arguments
%       ----------------
%       The first return argument, sfcns, is a cell array containing a list of
%       all S-functions in the model. Each entry is a cell of length 3 or 4,
%       where the first element is the S-function block handle, the
%       second element is the S-function name, the third element is set (1.0)
%       if the S-function is inlined and the optional fourth element is any 
%       additional S-function modules that need to be linked with this model.
%
%       The second return argument, buildInfo, is a cell containing
%       build information for the model:
%             {modulesAndNoninlinedSFcns, tlcIncDirs, numStateflowSFcns}
%       The first entry is a (unique) list of non-inlined S-function
%       names and any additional modules. On the PC, the first entry contains
%       only lower case names. The second entry is a (unique) list of
%       directories to be used for TLC include paths (where the .tlc file for
%       S-functions lives). The third entry is the number of Stateflow
%       S-functions.
%

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.16.2.4 $

if nargout == 0
  builtin('rtwgen', varargin{:});
else
  [varargout{1:nargout}] = builtin('rtwgen', varargin{:});
end
