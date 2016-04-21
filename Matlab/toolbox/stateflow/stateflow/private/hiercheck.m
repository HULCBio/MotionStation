function valid = hiercheck(top)
%HIERCHECK Do sanity checks on SF hierarchy
%   valid = HIERCHECK(node) checks the part of the SF
%   tree below node for validity.  Returns true for
%   valid trees; prints report to screen and returns
%   false if a problem is detected
%

% Copyright 2002 The MathWorks, Inc.


% To force an error report, look for lines with DEBUG
% and uncomment them.
  [valid, errmsg] = is_valid_tree(top);
  if (~valid)
    disp(errmsg);
  end
  

% Takes a UDD handle and makes sure its subtree agrees with 
% what's in the SF data dictionary
function [valid, errmsg] = is_valid_tree(top)

  [valid, errmsg] = is_valid_node(top);

  if (isHierarchical(top))
    kids = find(top, '-depth', 1);
    for i=1:length(kids)
      thisNode = kids(i);
      if (~isequal(thisNode, top))
        [subvalid, suberrmsg] = is_valid_tree(thisNode);
        if (~subvalid)
          errmsg = [errmsg suberrmsg];
          valid = logical(0);
        end
      end
    end
  end
  
  

% Makes sure that SF and UDD agree (and that SF agrees with itself)
% about the children of this node
function [valid, errmsg] = is_valid_node(node)

  
  % UDD's kids
  kids = find(node, '-depth', 1);

  % SF's kids
  nodeid = get(node, 'id');
  sfids = [nodeid get_all_child_sf_ids(node)];
  
  % Massage UDD data into usable form
  uddidscol = get(kids, 'id');
  uddids = cell_array_to_row_vector(uddidscol);

  % Super- and non-driver-sub-wires should not have UDI's
  sftrimmed = trim_wire_ids(sfids);
  
  % sort lists for easy comparison
  sftrimmed = sort(sftrimmed);
  sfids = sort(sfids);
  uddids = sort(uddids);

  %DEBUG
  %sfids = [12 sfids];

  % Check that the two lists are identical
  uddvalid = (isequal(sftrimmed, uddids));
  
  % If not, construct an error message
  errmsg = [];
  if (~uddvalid)
    errmsg = sprintf(['SF and UDD disagree on children of ' ... 
                      get_node_name(node) ... 
                      '\nSF:  ' int2str(sftrimmed) ...
                      '\nUDD: ' int2str(uddids) '\n']);
  end
  
  
  % Now, make sure all SF kids agree about their parent
  sfvalid = logical(1);
  for i=1:length(sfids)
    thisId = sfids(i);
    if (thisId ~= nodeid)
      parent = get_parent_id(thisId);
      if (parent ~= nodeid)
        sfvalid = logical(0);
        errmsg = [errmsg ...
                  'SF inconsistency: ' int2str(nodeid) ' has child ' int2str(thisId) ...
                  ' which has parent ' int2str(parent) sprintf('\n')];
      end
    end
  end
  
  valid = uddvalid & sfvalid;
  

% Remove any superwires from list
% Also, remove any subwires that are not driver wires
function ids = trim_wire_ids(allids)
    ids = [];
    
    transids = sf('get', allids, 'trans.id')';
    nontransids = sf('Private', 'vset', allids, '-', transids);
    
    simpletrans = transids(find(sf('get', transids, '.type')' == 0));
    subtrans = transids(find(sf('get', transids, '.type')' == 1));
    % Don't care about superwires as they do not have UDI's
    
    drivertrans = subtrans(find(sf('get', subtrans, '.subLink.before')' == 0));
    
    ids = [nontransids simpletrans drivertrans];
      

% Remove any superwires from list
% Also, remove any subwires that are not driver wires
function ids = old_trim_wire_ids(allids)
    ids = [];
    for i=1:length(allids)
        thisid = allids(i);
        class = sf('get', thisid, '.isa');
        if (isequal(class, 5))   % Wish to remove this '5'
            type = sf('get', thisid, '.type');
            switch(type)
            case 0 %simple
                ids = [ids thisid];
            case 1 %sub
                % Only add a subwire if it has no predecessor
                if isequal(0, (sf ('get', thisid, '.subLink.before')))
                    ids = [ids thisid];
                end
            case 2 %super
                % skip all superwires
            end
        else
            % add any non-transition
            ids = [ids thisid];
        end
    end
  
% Try to find the name of node.
% If no name exists, use the class name
function name = get_node_name(node)
  id = get(node, 'id');
  try
    prename = get(node, 'Name');
  catch
    prename = get(classhandle(node), 'Name');
  end
  name = [prename ' (' int2str(id) ')'];
  
  
  
function rv = cell_array_to_row_vector(carr)
  rv = [];
  l = length(carr);
  if (l == 1)
    rv = carr;
  else
    for i=1:length(carr)
      rv = [rv carr{i}];
    end
  end
  
  
  
function childids = get_all_child_sf_ids(parent)
  childids = [get_all_hier_child_ids(parent) ...
              get_all_leaf_child_ids(parent)
              ];
  



% This will return a list of the IDs of all the 
% hierarchical objects that SF thinks are under this node
function childids = get_all_hier_child_ids(parent)
  childids = [];

  if (~isHierarchical(parent))
    return
  end
  
  parentid = get_id(parent);
  firstkid = sf('get', parentid, '.treeNode.child');
  while (firstkid ~= 0)
    childids = [childids firstkid];
    firstkid = sf('get', firstkid, '.treeNode.next');
  end
  

% Returns a list of the IDs of all the leaf objects
% that SF thinks are under this node
function childids = get_all_leaf_child_ids(parent)
  childids = [];
  classes = {'Data', 'Event', 'Transition', 'Junction', 'Target'};
  for i=1:length(classes)
    newkids = get_specific_leaf_child_ids(parent, classes{i});
    childids = [childids newkids];
  end

  
  
% Returns a list of IDs of all leaf objects of a specific type
% that SF thinks are under this node
function childids = get_specific_leaf_child_ids(parent, classname)
  childids = [];
  propName = ['.first' classname];
  parentid = get_id(parent);
  
  if (~is_valid_underclass(parent, classname))
    return
  end
  
  tid = sf('get', parentid, propName);
  while (tid ~= 0)
    childids = [childids tid];
    tid = sf('get', tid, '.linkNode.next');
  end


  
% This function has intelligence about which classes 
% can parent which other classes in Stateflow.
% Yucky.
function isValid = is_valid_underclass(parentnode, childclass)
  true = logical(1);
  false = logical(0);

  clname = get(classhandle(parentnode), 'Name');

  switch (clname)
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   case 'State'
    switch(childclass)
     case 'Event'
      isValid = true;
     case 'Data'
      isValid = true;
     case 'Transition'
      isValid = true;
     case 'Junction'
      isValid = true;
     otherwise
      isValid = false;
    end
   case 'Box'
    switch(childclass)
     case 'Event'
      isValid = true;
     case 'Data'
      isValid = true;
     case 'Transition'
      isValid = true;
     case 'Junction'
      isValid = true;
     otherwise
      isValid = false;
    end
   case 'Function'    
    switch(childclass)
     case 'Event'
      isValid = true;
     case 'Data'
      isValid = true;
     case 'Transition'
      isValid = true;
     case 'Junction'
      isValid = true;
     otherwise
      isValid = false;
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%
   
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   case 'Chart'
    switch(childclass)
     case 'Event'
      isValid = true;      
     case 'Data'
      isValid = true;      
     case 'Transition'
      isValid = true;      
     case 'Junction'
      isValid = true;      
     case 'State'
      isValid = true;
     otherwise
      isValid = false;
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   case 'Machine'
    switch(childclass)
     case 'Event'
      isValid = true;
     case 'Data'
      isValid = true;
     case 'Target'
      isValid = true;
     otherwise
      isValid = false;
    end
   %%%%%%%%%%%%%%%%%%%%%%%%%
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   otherwise
    isValid = false;
   %%%%%%%%%%%%%%%%%%%%%%%%%
  
  end
  

  
% For convenience
function id = get_id(node)
  id = get(node, 'id');
  
function h = get_handle(nodeid)
  rt = sfroot;
  h = rt.find('id', nodeid);
  
  

function parentid = get_parent_id(childid)
 if (is_id_hierarchical(childid))
   parentid = get_hierarchy_parent_id(childid);
 else
   parentid = get_leaf_parent_id(childid);
 end

 %DEBUG
 % parentid = 12;
 
function isH = is_id_hierarchical(idtocheck)
    class = sf('get', idtocheck, '.isa');
    switch class
    case 2  % target
        isH = logical(0);
    case 4  % state
        isH = logical(1);
    case 5  % transition
        isH = logical(0);
    case 6  % junction
        isH = logical(0);
    case 7  % event
        isH = logical(0);
    case 8  % data 
        isH = logical(0);       
    end 
    
function parentid = get_hierarchy_parent_id(childid)
  parentid = sf('get', childid, '.treeNode.parent');

function parentid = get_leaf_parent_id(childid)
  parentid = sf('get', childid, '.linkNode.parent');
  