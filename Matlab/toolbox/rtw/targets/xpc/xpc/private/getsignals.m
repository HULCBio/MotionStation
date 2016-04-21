function S=getsignals(signals,mdlname)

% GETSIGNALS - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $

signals1=signals;

S.values=0:length(signals)-1;
% loop over all signal strings
for i=1:length(signals)
  name=signals{i};
  % replace all double slashed by underscores
  name=strrep(name,'//','_');
  % replace all non-alphabtecical and non-numerical characters by undersores
  name(find(name<47 | (name > 57 & name <65) | (name > 90 & name <95) | (name >95 & name < 97) | name > 122))='_';
  % remove all leading undersores and leading numerical characters, so the first character is a letter
  index= find(name=='/');%xpcosc/Sine_Wave
  remove=[];
  outofrange=0;
  if isempty(index)
    index=1;    
  end
  
  for n=1:length(index)
    j=1;
    tmp=name(index(n)+j);
    while tmp=='_' | (tmp>47 & tmp<58)
      remove=[remove,index(n)+j];
      j=j+1;
      if (index(n)+j)>length(name)
        outofrange=1;
        break
      end
      tmp=name(index(n)+j);
    end
    if tmp=='/' | outofrange
      name(index(n)+j-1)='X';
      remove(end)=[];
    end
  end

  name(remove)=[];

  % replace all slashes by dots to get struct notation  
  index=find(name=='/');
  if ~isempty(index)
      name(index)='.';
      % remove model name from block path
  end
  % build struct
  % if field already exists add undersore to block path
  % repeat this until field is unique
  try
    eval(['S.model.',name,';']);
    exists=1;
  catch 
    exists=0;
  end
   
  while exists
    name=[name,'_'];
    try
       eval(['S.model.',name,';']);
       exists=1;
    catch 
      exists=0;
    end
  end
  % build struct 
  try
    eval(['S.model.',name,'=',num2str(i-1),';']);
  catch
    txt={signals1{i},'','this block name is not valid. Correct it in the Simulink-model and',...
  	'rebuild the xPC Target-application.',...
   	'Valid names start with a letter followed by alpha/numerical characters'};
    errordlg(txt,'','modal');
    S.model.error=1;
    return
  end
  
end

S.modelname=mdlname;
S.signals=signals;


