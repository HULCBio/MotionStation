function [varargout] = tlc(varargin)
% TLC	Target Language Compiler
%
%	tlc [options] main-file
%
%	The Target Language Compiler is used by Real Time Workshop
%	to generate C code from the model.rtw file.
%
%	The build scripts for RTW automatically invoke the Target
%	language compiler to do this translation.  Users generally
%	need not invoke it directly.  See the Target Language Compiler
%       documentation for more information.
%
%
%	OPTIONS:
%
%	-r <name>	Specify that the RTW file being used
%			should be <name>
%
%	-v[<number>]	Specify the verbose level (1) if a level is
%			omitted
%
%	-I<path>	Specify a path to local include files.  The
%			TLC will search this path in the order
%			specified.
%
%	-m[<number>|a]	Specify the maximum number of errors (5
%			by default) that will be reported by the TLC
%			prior to terminating the translation
%			of the .tlc file.
%
%	-O<path>	Specify the path to place output files.
%			By default all TLC output will be created
%			in this directory.
%
%	-d[a|c|n|o]	Invoke the TLC's debug mode.
%                       -da will make TLC execute any %assert
%                       directives.
%                       -dc will invoke TLC's command line
%                       debugger.
%                       -dn will cause TLC to produce log files
%			indicating which lines were and were not
%			hit during compilation.
%                       -do will disable TLC's debugging behavior.
%
%	-a<ident>=<expression>
%			Use this option to specify parameters that
%			can be used to change the behavior of your
%			TLC program.  This option is used by RTW
%			to set things like inlining of parameters,
%			file size limits, etc.
%
%       -p<number>      Print a '.' indicating progress for every
%                       <number> of TLC primitive operations executed.
%
%       -lint           Perform some simple performance checks and
%                       collect some runtime statistics.
%
%       -x0             Just parse a TLC file, do not execute it.
%
%
%	EXAMPLES
%
%	Load the mymodel.rtw and run the generic real-time TLC
%	program in verbose mode:
%
%	tlc -r mymodel.rtw -v grt.tlc
%
%	See also RTWGEN, RTW, MAKE_RTW, RTW_C, TLC_C, SIMULINK

%	JTM	2/7/97
%	Copyright 1994-2002 The MathWorks, Inc.
%
%	$Revision: 1.12 $
%
if(nargout == 0)
  tlc_new(varargin{:});
else
  varargout = cell(1,nargout);
  [varargout{:}] = tlc_new(varargin{:});
end

