function [result,status] = maple(varargin)
%MAPLE String access to the Maple kernel.
%   MAPLE(STATEMENT) sends STATEMENT to the Maple kernel. 
%   STATEMENT is a string representing a syntactically valid Maple 
%   command. A semicolon for the Maple syntax is appended to STATEMENT
%   if necessary. The result is a string in Maple syntax.
%
%   MAPLE('function',ARG1,ARG2,..,) accepts the quoted name of any Maple
%   function and its corresponding arguments. The Maple statement is formed
%   as: function(arg1, arg2, arg3, ...), that is, commas are added between
%   the arguments. All of the input arguments must be strings that are
%   syntactically valid in Maple. The result is returned as a string in the 
%   Maple syntax.  To convert the result from a Maple string to a symbolic
%   object, use SYM.
%
%   [RESULT,STATUS] = MAPLE(...) returns the warning/error status.
%   When the statement execution is successful, RESULT is the result
%   and STATUS is 0. If the execution fails, RESULT is the corresponding 
%   warning/error message, and STATUS is a positive integer.
%
%   The statements
%      maple traceon  or  maple trace on
%   cause subsequent Maple commands and results to be printed.
%   The statements
%      maple traceoff  or  maple trace off
%   turn off this facility.
%   The statement
%      clear maplemex
%   clears the Maple workspace and reinitializes the Maple kernel.
%
%   MAPLE is not available for general use in the Student Version.
%
%   See also SYM, SYM/MAPLE

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.38.4.2 $  $Date: 2004/04/16 22:23:25 $

% Convert and concatenate arguments.

statement = ' ';
if nargin > 0
   F = varargin{1};
   % Check for 'trace' or 'help'.
   if strncmp(F,'trace',5)
      if nargin == 1 
         v = F(6:end);
      else
         v = varargin{2};
      end
      if strcmp(v,'on') | strcmp(v,'off')
         maplemex(v,3);
         return
      else
         error('symbolic:maple:errmsg1','Option %s not recognized.',v)
      end
   elseif strncmp(F,'clear',5) | strncmp(F,'restart',7)
      warning('symbolic:maple:warnmsg1','Use clear maplemex to clear Maple')
      clear maplemex
      return
   elseif strncmp(F,'help',4) & (nargin > 1)
      maplemex(varargin{2},1)
      return
   end
   statement = F;
end
if nargin > 1
   statement(end+1) = '(';
   for k = 2:nargin
      v = varargin{k};
      if ~isstr(v)
         v = char(sym(v));
      end
      statement = [statement v ','];
   end
   statement(end) = ')';
end
if isempty(statement) | statement(end) ~= ';'
   statement(end+1) = ';';
end

% Convert any floating point syms.

p = findstr(statement,'''');
q = findstr(statement,')');
for k = fliplr(findstr(statement,'''*2^('))
   s = max(p(p<k));
   e = min(q(q>k));
   statement = [statement(1:s-1) fl2str(statement(s:e)) statement(e+1:end)];
end

% Convert Inf

if length(statement) > 3
   for k = fliplr(findstr(statement,'Inf'))
      statement = [statement(1:k-1) 'infinity' statement(k+3:end)];
   end
   for k = fliplr(findstr(statement,'NaN'))
      statement = [statement(1:k-1) 'undefined' statement(k+3:end)];
   end
end

% Access the Maple kernel via Mex-file interface.

[result,status] = maplemex(statement);

% Handle any error messages.

if status ~= 0 & nargout < 2
   error('symbolic:maple:errmsg2',result)
end

% Convert some of Maple's exceptional constructions.

if length(result) > 6

   % Message about definite integrals.
   if ~isempty(findstr(result,'Definite'))
      k = max(findstr(result,'int'))-1;
      disp(result(1:k))
      result(1:k) = [];
   end

   % Imaginary unit when i or j is a sym.

   for k = findstr(result,'sqrtmone')
      result(k:k+7) = 'sqrt(-1)';
   end

   % Maple Float(indefinite/infinities)

   for k = fliplr(findstr(result,'Float('))
      if isequal(result(k+6:k+14),'infinity)')
         result = [result(1:k-1) '(Inf)' result(k+15:end)];
      elseif isequal(result(k+6:k+15),'-infinity)')
         result = [result(1:k-1) '(-Inf)' result(k+16:end)];
      elseif isequal(result(k+6:k+15),'undefined)')
         result = [result(1:k-1) '(NaN)' result(k+16:end)];
      end
   end
   for k = fliplr(findstr(result,'infinity'))
      result = [result(1:k-1) 'Inf' result(k+8:end)];
   end
   for k = fliplr(findstr(result,'undefined'))
      result = [result(1:k-1) 'NaN' result(k+9:end)];
   end

   % Evaluation of 'C'

   for k = fliplr(findstr(result,'codegen:-C'))
      result(k:k+8) = [];
   end
end

% Put backquotes around all @@ that precede derivative operator D.
if length(result) > 2 & ~isempty(findstr(result,'@@D'))
   for k = fliplr(findstr('@@D',result));
      result = [result(1:k-1) '`@@`D' result(k+4:end)];
   end
end
if length(result) > 3 & ~isempty(findstr(result,'@@(D'))
   for k = fliplr(findstr('@@(D',result));
      result = [result(1:k-1) '`@@`(D' result(k+4:end)];
   end
end

% Shift decimal point in any Maple E-notation numbers.
if ~isempty(findstr(result,'E'))
   result = shiftept(result);
end

%------------------------------%

function s = fl2str(s)
%FL2STR Convert sym(x,'f') quantity to Maple expression.
%   FL2STR('1.0000000000001'*2^(0)) is 4503599627370497*2^(-52).
 
   p = find(s=='.');
   d = real(s(p+(1:13)))-48;
   k = d > 10;
   d(k) = d(k)-39;
   f = 16^13 + d*16.^(12:-1:0)';
   if s(2) == '-'
      f = -f;
   end
   e = str2double(s(p+19:end-1))-52;
   s = [int2str(f) '*2^(' int2str(e) ')'];


function s = shiftept(s)
%SHIFTEPT Shift decimal point in any Maple E-notation numbers.
%   SHIFTEPT('1234.0E10') is '1.234e13'.

for k = fliplr(findstr('E',s))
   l = length(s);
   if k < 3 || k > l-2 || s(k-2) ~= '.' || s(k-1) < '0' ...
      || s(k-1) > '9' || s(k+1) < '0' || s(k+1) > '9'
      continue
   end
   f = max(find(s(1:k-3) < '0' | s(1:k-3) > '9'));
   if isempty(f), f = 1; else, f = f+1; end
   e = min(find(s(k+2:l) < '0' | s(k+2:l) > '9'));
   if isempty(e), e = l; else, e = e+k; end
   if f < k-3
      s = [s(1:f) '.' s(f+1:k-3) s(k-1) 'e'  ...
          int2str(eval(s(k+1:e))-f+k-3) s(e+1:l)];
   else
      s(k) = 'e';
   end
end
