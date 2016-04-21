function name = unique_name_for_list(objs, classType)
% NAME = UNIQUE_NAME_FOR_LIST( OBJS, CLASSTYPE )

%	Jay R. Torgerson
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.12.2.1 $

   [DATA,EVENT,TARGET] = sf('get','default','data.isa','event.isa','target.isa');
	
	switch(classType),
		case DATA, base = sf('get','default','data.name');
		case EVENT, base = sf('get','default','event.name');
		case TARGET,base = sf('get','default','target.name');
		otherwise , base = 'untitled';
	end;

   true = 1;
   false = 0;

   ind = 0;
   indStr = '';
   unique = false;
   
	while(unique == false),
      unique = true;
      name = [base,indStr];
		for o = objs(:)',
			oName = sf('get', o, '.name');
			if (strcmp(name,oName)), unique = false; end;
      end;	
      ind=ind+1;
      indStr = int2str(ind);
   end;
   

