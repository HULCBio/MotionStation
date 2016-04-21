function newestring = parseit(estring,n,errhan)
%PARSEIT Parse a DEE expression.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.13 $

% Jay Torgerson

if isempty(estring),
   newestring = estring;
   return
end

estring = [' ',estring];
lenestring = length(estring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert x(i) values in estring into u(n+i) values for the ith Fcn
%         block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check for:
%            x(
%            x (
%            x[
%            x [

% find where all the important x's live in the input equation.
x1ind = findstr('x(',estring);
x2ind = findstr('x (',estring);
x3ind = findstr('x[',estring);
x4ind = findstr('x [',estring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filter out those indecies with an alphanumeric char just before the x in
%    x1ind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lownumbound = 48; uppernumbound = 57; % lower and upper bounds for numbers
lowCapbound = 65; upperCapbound = 90; % lower and upper bounds for Cap. letters
lowlocbound = 97; upperlocbound = 122;% lower and upper bounds for lower letters

% an1ind = alhpanumeric index for first index vector
an1ind = x1ind - 1;

% anvals = vector of ascii codes for the chars before the x's
anvals = abs(estring(an1ind));

nummask = ( ( anvals < lownumbound ) | (anvals > uppernumbound) );
Capmask = ( ( anvals < lowCapbound ) | (anvals > upperCapbound) );
locmask = ( ( anvals < lowlocbound ) | (anvals > upperlocbound) );

anmask = nummask & Capmask & locmask;

x1ind = an1ind(anmask) + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filter out those indecies with an alphanumeric char just before the x in
%    x2ind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% an2ind = alhpanumeric index for first index vector
an2ind = x2ind - 1;

% anvals = vector of ascii codes for the chars before the x's
anvals = abs(estring(an2ind));

nummask = ( ( anvals < lownumbound ) | (anvals > uppernumbound) );
Capmask = ( ( anvals < lowCapbound ) | (anvals > upperCapbound) );
locmask = ( ( anvals < lowlocbound ) | (anvals > upperlocbound) );

anmask = nummask & Capmask & locmask;

x2ind = an2ind(anmask) + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filter out those indecies with an alphanumeric char just before the x in
%    x3ind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% an3ind = alhpanumeric index for first index vector
an3ind = x3ind - 1;

% anvals = vector of ascii codes for the chars before the x's
anvals = abs(estring(an3ind));

nummask = ( ( anvals < lownumbound ) | (anvals > uppernumbound) );
Capmask = ( ( anvals < lowCapbound ) | (anvals > upperCapbound) );
locmask = ( ( anvals < lowlocbound ) | (anvals > upperlocbound) );

anmask = nummask & Capmask & locmask;

x3ind = an3ind(anmask) + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filter out those indecies with an alphanumeric char just before the x in
%    x4ind
% an4ind = alhpanumeric index for first index vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
an4ind = x4ind - 1;

% anvals = vector of ascii codes for the chars before the x's
anvals = abs(estring(an4ind));

nummask = ( ( anvals < lownumbound ) | (anvals > uppernumbound) );
Capmask = ( ( anvals < lowCapbound ) | (anvals > upperCapbound) );
locmask = ( ( anvals < lowlocbound ) | (anvals > upperlocbound) );

anmask = nummask & Capmask & locmask;

x4ind = an4ind(anmask) + 1;

% build xind
xind = [x1ind,x2ind,x3ind,x4ind];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  check to see that there are no paranthesis / bracket problems
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find all left and right paranthesis and brackets
lp = find(estring=='(');
rp = find(estring==')');
lb = find(estring=='[');
rb = find(estring==']');


% check to make sure that the left and right parans and brackets match
if (length(lp) ~= length(rp)),
   % do that status  thing
   set(errhan,'String','Status:  parans don''t match')
   return
end

if (length(lb) ~= length(rb)),
   % do that status  thing
   set(errhan,'String','Status:  brackets don''t match')
   return
end

% make sure that the first paran is a left paran and that the first barcket
%   is a left bracket and make sure that the last paran and last barket are
%   right orientated

if ~isempty(lp) & ~isempty(rp),
   if lp(1) > rp(1),
      %  status  error
      set(errhan,'String','Status:  first paran is not a left paran')
      return
   end

   if lp(length(lp)) > rp(length(rp)),
      %  status  error
      set(errhan,'String','Status:  last paran is not a right paran')
      return
   end
end


if ~isempty(lb) & ~isempty(rb),
   if lb(1) > rb(1),
      %  status  error
      set(errhan,'String','Status:  first bracket is not a left bracket')
      return
   end

   if lb(length(lb)) > rb(length(rb)),
      %  status  error
      set(errhan,'String','Status:  last bracket is not a right bracket')
      return
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  build index vectors for left parans and brackets corresponding to valid
%    x's and find the corresponding right parans and brackets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lpind = [(x1ind+1),(x2ind+2)];
lbind = [(x3ind+1),(x4ind+2)];

% force lpind and lbind to be row vectors - this is done for
%    dimension purposes when building the the lpmat and lbmat
lpind = lpind(:)';
lbind = lbind(:)';


% find corresponding right parans
if ~isempty(lpind)
  lpmat = lpind(ones(size(rp)),:);
  rpmat = rp(ones(size(lpind)),:)';
  diffmat = rpmat - lpmat;
  diffmat(diffmat<=0) = inf*ones(size(diffmat(diffmat<=0)));
  rpind = min(diffmat)+lpind;
else
  rpind = [];
end

% find corresponding right brackets
if ~isempty(lbind)
  lbmat = lbind(ones(size(rb)),:);
  rbmat = rb(ones(size(lbind)),:)';
  diffmat = rbmat-lbmat;
  diffmat(diffmat<=0) = inf*ones(size(diffmat(diffmat<=0)));
  rbind = min(diffmat)+lbind;
else
  rbind = [];
end


%***************************************************************************%
% find out if the values between parans/brackets are integers as            %
%     they have to be                                                       %
%***************************************************************************%
lind = [lpind,lbind];
rind = [rpind,rbind];
% check for empty args
if any((rind - lind) == 1),
  % status error
  set(errhan,'String','Status:  input arg for x() or x[] is empty')
  return
end
indmat = [(lind+1);(rind-1)];
if ~isempty(indmat),
   q = sprintf('%d:%d ',indmat);
   q = ['[ ',q,'];'];
   eval(['qinds =',q]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % check to make sure that there are no junk chars in the text that should
   %       only be integers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   numbers = estring(qinds);
   if any(numbers == ' ');
      numbers(numbers == ' ') = [];
   end

   if any( (numbers < lownumbound) | (numbers > uppernumbound) ),
      % status error no non integer arg to x
      set(errhan,'String','Status:  non integer arg found for x() or x[]')
      return
   end

   % use str2num to check for internal spaces and other problems
   if isempty(str2num(estring(qinds))),
      set(errhan,'String','Status:  arg for x() or x[] must be an int')
      return
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % convert all valid x's to u's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   estring(xind) = setstr(abs('u')+zeros(size(xind)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % convert arg strings to valid x's to numbers, add offset n, and convert back
   %    to string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %  create argument vector of old arg + offset n
   argvec = [];
   s = sprintf('argvec = [argvec,str2num(estring(%d:%d)) + n];',indmat);
   eval(s);

   indargmat = [[1,rind];[lind,lenestring];[argvec,0]];

   newestring = [];
   s = sprintf('newestring = [newestring,estring(%d:%d),int2str(%d)];',indargmat);
   eval(s);

   newestring = newestring(2:(length(newestring)-1));

else
   newestring = estring(2:lenestring);
end
