function PrintLog=simprintlog(Systems,Resolved,Unresolved)
%SIMPRINTLOG Simulink printing log.
%   PrintLog=SIMPRINTLOG(Systems,Resolved,Unresolved,Stateflow) creates a
%   a printing log which is used by the Simulink Printing Dialog.
%
%   Systems    - list of systems to be printed
%   Resolved   - list of unique resolvable library links
%   Unresolved - list of unique unresolvable library links
%
%   The lists musts be column cell arrays of strings or Handles.  For example:
%
%     Systems={'simulink';'simulink/Sources'}
%
%   PrintLog   - a string matrix
%
%   See also SIMPRINTDLG.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

error(nargchk(3,3,nargin));
% Preliminary setup
Spc=blanks(2);
ReturnChar=sprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Develop strings for the system log
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SysLog=cell(length(Systems),1);
for SysLp=1:length(Systems),
  Name=Systems{SysLp};
  if ~isstr(Name),Name=getfullname(Name);end

  if  ~strcmp(get_param(Name,'Type'),'block_diagram') & ...
      strcmp(get_param(Name,'Mask'),'on') & ...
      strcmp(get_param(Name,'MaskType'),'Stateflow'),
    SFHdr=' (SF) ';
  else,
    SFHdr='      ';
  end
  Name(Name==ReturnChar)=' ';
  SysLog{SysLp,1}=[sprintf('%6d',SysLp) SFHdr Name];
end % for SysLp

% Cover the case where it's empty, This is used later for page # purposes.
SysLp=length(Systems);

% Develop header for system log
SysLog=char(SysLog);
if ~isempty(SysLog),
  SysTitle=['  Page' blanks(length(SFHdr)) 'System Name'];
  SysWidth=max(size(SysLog,2),size(SysTitle,2));
  Banner='-';
  Banner=Banner(1,ones(1,SysWidth));
  SysLog=str2mat(SysTitle,Banner,SysLog,'','');
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Develop strings for the resolved log
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ResolvedLog=cell(length(Resolved),1);
for Rslv=1:length(Resolved),
  Name=Resolved{Rslv};
  if ~isstr(Name),Name=getfullname(Name);end

  if  ~strcmp(get_param(Name,'Type'),'block_diagram') & ...
     strcmp(get_param(Name,'Mask'),'on') & ...
     strcmp(get_param(Name,'MaskType'),'Stateflow'),
    SFHdr=' (SF) ';
  else,
    SFHdr='      ';
  end

  [XRef,XRefStr]=LocalGetCrossReference(Systems,Resolved,Name);

  Name(Name==ReturnChar)=' ';

  if ~isempty(XRef),
    XReferences={};
    for lp=length(XRef):-1:1,
      XReferences{lp,1}=[blanks(4) Spc '  (' sprintf('%3d',XRef(lp)) ...
                      Spc XRefStr{lp} ')'];
    end % for lp

    XReferences=char(XReferences);
    ResolvedLog{Rslv,1}= ...
      str2mat('',[sprintf('%6d',SysLp+Rslv) SFHdr Name],XReferences);

  % This is a subsystem to the library link
  % Indicate it as such.
  else,
    ResolvedLog{Rslv,1}=[sprintf('%6d',SysLp+Rslv) Spc ' -- ' Name];

  end % if ~isempty

end % for Rslv

% Cover the case where it's empty
Rslv=length(Resolved);

% Develop header for the resolved log
ResolvedLog=char(ResolvedLog);
if ~isempty(ResolvedLog),
  ResolvedTitle= ...
    str2mat(['  Page' blanks(length(SFHdr)) ...
             'Unique Resolved Library Links'], ...
            [blanks(4) Spc '  (Page and Block Name referencing link)']);
  ResolvedWidth=max(size(ResolvedLog,2),size(ResolvedTitle,2));
  Banner='-';
  Banner=Banner(1,ones(1,ResolvedWidth));
  ResolvedLog=str2mat(ResolvedTitle,Banner,ResolvedLog,'','');
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Develop strings for the unresolved log
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UnresolvedLog=cell(length(Unresolved),1);
for UnRslv=1:length(Unresolved),
  Name=Unresolved{UnRslv};
  SysRef={};
  if ~isempty(Systems),
    SysRef=find_system(Systems{1},'SourceBlock',Name);
  end
  if ~isempty(SysRef),SysRef=SysRef(1);end
  if  ~strcmp(get_param(SysRef,'Type'),'block_diagram') & ...
     strcmp(get_param(SysRef,'Mask'),'on') & ...
     strcmp(get_param(SysRef,'MaskType'),'Stateflow'),
    SFHdr=' (SF) ';
  else,
    SFHdr='      ';
  end

  [XRef,XRefStr]=LocalGetCrossReference(Systems,Resolved,Name);
  XReferences={};
  for lp=length(XRef):-1:1,
    XReferences{lp,1}=[blanks(8) SFHdr '  (' sprintf('%3d',XRef(lp)) ...
                       Spc XRefStr{lp} ')'];
  end % for lp
  XReferences=char(XReferences);
  Name(Name==ReturnChar)=' ';
  UnresolvedLog{UnRslv,:}=str2mat([blanks(8) Spc Name],XReferences);
end % for UnRslv
% Cover the case where it's empty
UnRslv=length(Unresolved);

% Develop header for the unresolved log
UnresolvedLog=char(UnresolvedLog);
if ~isempty(UnresolvedLog),
  UnresolvedTitle= {
     '(  Not         Unique Unresolved Library Links'
     ' Printed)        (Page and System Name referencing link)'
                   };
  UnresolvedTitle=str2mat(UnresolvedTitle{:});

  UnresolvedWidth=max(size(UnresolvedLog,2),size(UnresolvedTitle,2));
  Banner='-';
  Banner=Banner(1,ones(1,UnresolvedWidth));
  UnresolvedLog=str2mat(UnresolvedTitle,Banner,UnresolvedLog);
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put all three logs together
PrintLog=str2mat(SysLog       , ...
                 ResolvedLog  , ...
                 UnresolvedLog  ...
                );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetCrossReference %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XRefPage,XRefStr]=LocalGetCrossReference(Systems,Resolved,Name)
% Get the cross references for the specified link

Systems=[Systems;Resolved];
SystemsH=get_param(Systems,'Handle');
if iscell(SystemsH),
  SystemsH=cat(1,SystemsH{:});
end

XRefChildH=[find_system(SystemsH,'SearchDepth',1,'SourceBlock',Name)
          find_system(SystemsH,'SearchDepth',1,'ReferenceBlock',Name)
         ];

% A subsystem inside a link
if isempty(XRefChildH),
  XRefPage='';
  XRefStr='';
  return
end % if

XRefName=get_param(XRefChildH,'Parent');
XRefH=get_param(XRefName,'Handle');

if ~iscell(XRefName),
  XRefName={XRefName};
end

if iscell(XRefH),
  XRefH=cat(1,XRefH{:});
end

[XRefPage,Ind]=sort(findindices(SystemsH,XRefH,1));
% The above line reverts back to original behavior in
% order to deal with duplicated handles in XRefH.
%[XRefPage,Ind]=find(ismember(SystemsH,XRefH));
%XRef=int2str(XRef(:)');

XRefStr={};
ReturnChar=sprintf('\n');
for lp=length(XRefH):-1:1,
  %XRefStr{lp,1}=[XRefName{Ind(lp)} get_param(XRefChildH(Ind(lp)),'Name')];
  XRefStr{lp,1}=get_param(XRefChildH(Ind(lp)),'Name');
  XRefStr{lp,1}(XRefStr{lp,1}==ReturnChar)=' ';
end % for lp
