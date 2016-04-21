function varargout = stbrk(st, varargin)
%STBRK Part(s) of an stform.
%
%   [CENTERS, COEFS, TYPE, INTERV] = STBRK(ST)  returns as many of the
%   parts of the stform in ST as specified by the output arguments. 
%
%   OUT1 = STBRK(ST, PART)  returns the part specified by the string PART 
%   which may be (the beginning characters) of one of the following strings:
%    'centers', 'coefficients', 'type ', 'interval', 'dimension', 'var'.
%
%   ST = STBRK(ST,INTERV) changes the basic interval of the stform in ST to
%   the one specified by the cell array INTERV.
%
%   [OUT1,...,OUTo] = RPBRK(SP, PART1,...,PARTi)  returns in OUTj the part 
%   specified by the string PARTj, j=1:o, provided o<=i.
%
%   STBRK(ST) returns nothing, but prints out all the parts.
%
%   See also STMAK, STCOL, FNBRK.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.5 $

if ~isstruct(st)
   if st(1)~=25
      error('SPLINES:STBRK:notst',...
      'The input array does not seem to describe a function in stform.')
   end

   dce = st(2); nce = st(3);
   dco = st(4+dce*nce); nco = st(5+dce*nce);

   st = stmak( reshape(st(3+(1:dce*nce)),dce,nce), ...
               reshape(st(5+dce*nce+(1:dco*nco)),dco,nco), 'tp00' );
end

if length(st.form)<2||~isequal(st.form(1:2),'st')
   error('SPLINES:STBRK:unknownfn',...
   'The input does not seem to describe a function in stform.')
end

if nargin>1 % we have to hand back one or more parts
   lp = max(1,nargout);
   if lp>length(varargin)
      error('SPLINES:STBRK:moreoutthanin', ...
            'Too many output arguments for the given input.')
   end
   varargout = cell(1,lp);
   for jp=1:lp
      part = varargin{jp};
      if ischar(part)
         if isempty(part)
	    error('SPLINES:STBRK:partemptystr',...
	    'Part specification should not be an empty string.')
	 end
         switch part(1)
         case 'f',       out1 = 'stform';
         case 'c'
            if length(part)<2
               error('SPLINES:STBRK:ambiguouspart',['For Part %g, ', ...
	              'did you mean ''centers'' or ''coefficients''?'],jp)
            else
               switch part(2)
               case 'e', out1 = st.centers;
               case 'o', out1 = st.coefs;
               end
            end
         case 'd', out1 = st.dim;
         case 'i', out1 = st.interv;
         case 'n', out1 = st.number;
         case 't', out1 = st.form(4:end);
         case 'v', out1 = size(st.centers,1);
         otherwise
            error('SPLINES:STBRK:wrongpart',...
	    ['''',part,'''',' is not part of an stform.'])
         end
      else % part is expected to be a basic interval spec.
         if ~iscell(part)
            if size(st.centers,1)==1, part = {part};
            else
               error('SPLINES:STBRK:inarg2notcell',...
	       'The second argument is expected to be a cell array.')
            end
         end
         lpart = length(part);
         if lpart~= size(st.centers,1)
            error('SPLINES:STBRK:toofewinterv',...
	    ['A basic interval spec. must have as many entries', ...
                   ' as the function has variables.'])
         end 
         for j=1:length(part)
	    if isempty(part{j}), part{j} = st.interv{j};
            elseif ~isequal(size(part{j}),[1 2])||part{j}(1)>=part{j}(2)   
               error('SPLINES:STBRK:wronginterv',...
	       ['A basic interval must be a cell array,\n', ...
                      'with each nonempty entry of the form\n', ...
                      '[a b] for some a < b.'],0)
            end
         end
         
         st.interv = part; out1 = st;
      end
      varargout{jp} = out1;
   end
   
else
   if nargout==0
      disp(st)
   else
      varargout = {st.centers, st.coefs, st.form(4:end), st.interv};
   end
end
