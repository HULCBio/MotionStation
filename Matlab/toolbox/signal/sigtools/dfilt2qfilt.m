function Hq = dfilt2qfilt(H,Hq)
%DFILT2QFILT Convert DFILT object to QFILT object.
%   Hq = dfilt2qfilt(H,Hq_in) converts DFILT object H to QFILT object Hq
%   using Hq_in as a starting point.

%   Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.27 $  $Date: 2002/11/21 15:36:33 $ 

error(nargchk(2,2,nargin));

if isa(H,'qfilt')
  % Already a qfilt.
  Hq = H;
  return
end

if ~isquantizable(H),
    error('QFilts cannot handle non-homogenous cascades or cascades of cascades');
end

wrn = warning('off');
Hq = copyobj(Hq); % Dont return refqfilt. 

% Autocorrect for wrong length scale values
Hq = scalevaluefixup(Hq);

fstruc = classname(H);
c = coefficients(H);
% Unwrap a single section.  E.g., convert {{b,a}} to {b,a}, 
%  but leave {{b1,a1},{b2,a2}} alone.
if ~isempty(c) & length(c)==1 & iscell(c{1})
  c = c{1};
end
if strcmpi(fstruc, 'latticemamin'),
    fstruc = 'latticema';
end

switch fstruc
case 'calattice',
    % lattice coupled-allpass
    set(Hq,'latticeca',get(H, {'Allpass1', 'Allpass2', 'Beta'}));
case 'calatticepc',
    % power complementary lattice coupled-allpass
    set(Hq,'latticecapc',get(H, {'Allpass1', 'Allpass2', 'Beta'}));
case {'df1sos', 'df2sos', 'df1tsos', 'df2tsos'}
    set(Hq, d2qname(fstruc), sos2cell(get(H, 'sosMatrix')), 'scale', get(H, 'ScaleValues'));
case 'cascade'
    
    nsecs = 0;
    c = {};
    
    % Find all the non scalar sections
    fstruc = [];
    for i = 1:length(H.Section),
        if ~isscalarstructure(H.Section(i)),
            fstruc = classname(H.Section(i));
            nsecs = nsecs + 1;
            c{nsecs} = coefficients(H.Section(i));
        end
    end
    
    s = ones(1, nsecs+1);
    
    % Find all the scalar sections
    nscalars = 1;
    for i = 1:length(H.Section),
        if isa(H.Section(i), 'dfilt.scalar'),
            s(nscalars) = get(H.Section(i), 'Gain');
        else
            nscalars = nscalars + 1;
        end
    end
   
    if all(s(2:end) == 1), s = s(1); end
    if all(s == 1), s = []; end
    
    set(Hq, d2qname(fstruc), c, 'scale', s);
otherwise
    set(Hq, d2qname(fstruc), c);
end
warning(wrn)

%-------------------------------------------------------------
function qfiltname = d2qname(dfiltname)

switch dfiltname
case {'df1','df1t','df2','df2t','latticearma','latticear','statespace'}
    qfiltname = dfiltname;
case {'df1sos', 'df2sos', 'df1tsos', 'df2tsos'}
    qfiltname = dfiltname(1:end-3);
case 'cascade'
    qfiltname = 'cascade';
case 'latticeallpass'
    qfiltname = 'latcallpass';
case 'latticemamax'
    qfiltname = 'latcmax';
case 'latticemamin'
    qfiltname = 'latticema';
case 'dffir'
    qfiltname = 'fir';
case 'dffirt'
    qfiltname = 'firt';
case 'dfsymfir',
    qfiltname = 'symmetricfir';
case 'dfasymfir'
    qfiltname = 'antisymmetricfir';
case 'calattice',
    qfiltname = 'latticeca';
case 'calatticepc',
    qfiltname = 'latticecapc';
otherwise
    error('Unrecognized filter structure.')
end

% [EOF]
