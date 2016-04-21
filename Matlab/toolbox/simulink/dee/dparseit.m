function newestring = dparseit(estring,n,errhan),
%DPARSEIT Unparse a string for the DEE.
%   DPARSEIT unparses a string for a DEE system.
 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $

%   Jay Torgerson

if isempty(estring),
   newestring = estring;
   return
end

estring = [' ',estring];
lenestring = length(estring);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert valid u(i) values in estring into u(i-n) values for the ith Fcn
%         block, where valid means that i > n
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check for:
%            u(
%            u (
%            u[
%            u [

% find where all the important u's live in the input equation.
x1ind = findstr('u(',estring);
x2ind = findstr('u (',estring);
x3ind = findstr('u[',estring);
x4ind = findstr('u [',estring);

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

% find ALL left and right paranthesis and brackets
lp = find(estring=='(');
rp = find(estring==')');
lb = find(estring=='[');
rb = find(estring==']');


% check to make sure that the left and right parans and brackets match
if (length(lp) ~= length(rp)),
   % do that status  thing
   disp('error - parans don''t match') 
   return
end

if (length(lb) ~= length(rb)),
   % do that status  thing
   disp('error - brackets don''t match') 
   return
end

% make sure that the first paran is a left paran and that the first barcket
%   is a left bracket and make sure that the last paran and last barket are
%   right orientated

if ~isempty(lp) & ~isempty(rp),
   if lp(1) > rp(1),
      %  status  error
      disp('first paran is not a left paran')
      return
   end

   if lp(length(lp)) > rp(length(rp)),
      %  status  error
      disp('last paranis is not a right paran')
      return
   end
end


if ~isempty(lb) & ~isempty(rb),
   if lb(1) > rb(1),
      %  status  error
      disp('first bracket is not a left paran')
      return
   end

   if lb(length(lb)) > rb(length(rb)),
      %  status  error
      disp('last bracket is not a right paran')
      return
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  build index vectors for left parans and brackets corresponding to valid 
%    u's and find the corresponding right parans and brackets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lpind = [(x1ind+1),(x2ind+2)];
lbind = [(x3ind+1),(x4ind+2)];
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
  disp('error- arg for x is empty')
  return
end

indmat = [(lind+1);(rind-1)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %  filter out those u's with args <= offset  (n) since they are actually
   %      the inputs and do not correspond to states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   numvec = [];
if ~isempty(indmat),
   s = sprintf('numvec = [numvec,(str2num(estring(%d:%d)) - n)];',indmat);
   eval(s);
   badmask = numvec<=0;

   % remove all indicies in index vectors corresponding to input u's 
   xind(badmask) = [];
   indmat(:,(badmask)) = [];
   rind(badmask) = [];
   lind(badmask) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build qinds to hold all the values between valid parans and check args
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   q = sprintf('%d:%d ',indmat);
   q = ['[ ',q,'];'];
   eval(['qinds =',q]);

if ~isempty(qinds),
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
      disp('error - non int arg to x')
      return
   end

   % use str2num to check for internal spaces and other problems
   if isempty(str2num(estring(qinds))) & (qinds ~= []),
      % status  - arg to x must be an int
      disp('error - arg to x must be an int')
      return
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % convert all valid u's to x's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   estring(xind) = setstr(abs('x')+zeros(size(xind)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % convert arg strings to valid u's to numbers, substract offset n, and 
   %    convert back to string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %  create argument vector of old arg - offset n
   argvec = [];
if ~isempty(indmat),
   s = sprintf('argvec = [argvec,str2num(estring(%d:%d)) - n];',indmat);
   eval(s);
end
   % sort rind and lind
   rind = sort(rind); lind = sort(lind);
   indargmat = [[1,rind];[lind,lenestring];[argvec,0]];

   newestring = [];
   s = sprintf('newestring = [newestring,estring(%d:%d),int2str(%d)];',indargmat);
   eval(s);

   newestring = newestring(2:(length(newestring)-1));

else
   newestring = estring(2:lenestring);
end
