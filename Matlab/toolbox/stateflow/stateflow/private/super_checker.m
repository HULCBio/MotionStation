function nags = super_checker
% SUPER_CHECKER
%
%	Diagnostic tool for hierarchy integrity. To use,
%   simply define a specific global at the MATLAB command prompt:
%
%       >> global ENGAGE_SUPER_CHECKER
%   
%   This must be done BEFORE stateflow is loaded into memory.
%   Any integrity errors will be visible in the command window
%
%   Warning: this may override the display of other errors. Only
%   use this function if you're trying to track down a specific
%   bug with super transitions.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $  $Date: 2004/04/15 01:00:52 $

try
  nags =[];
  
  rt = sfroot;
  charts = rt.find('-isa', 'Stateflow.Chart');
  for chart=charts
    hiercheck(chart);
  end
catch
  disp(lasterr);
end



function allTheOldCode
% SUPER_CHECKER
%
%	Diagnostic tool for super transition integrity. To use,
%   simply define a specific global at the MATLAB command prompt:
%
%       >> global ENGAGE_SUPER_CHECKER
%   
%   This must be done BEFORE stateflow is loaded into memory.
%   Any Super Transition integrity errors will be visible in the
%   Simulation Diagnostics Window. 
%
%   Warning: this may override the display of other errors. Only
%   use this function if you're trying to track down a specific
%   bug with super transitions.

%   Copyright (c) 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $  $Date: 2004/04/15 01:00:52 $

  persistent initialized

  try,        
        
	if isempty(initialized), 
      disp('Super Checker Engaged');
      initialized = 1;
	end;
	
	had_super_nags_l('flush');
	
	editors = sf('get', 'all', 'chart.id');
	for editor=editors(:).',
      scan_wires_l(editor);
	end;
	
	if 0 & had_super_nags_l, 
      % get all nags in the naglog (even those NOT displayed!) this forces them into view
      nags = slsfnagctlr('Naglog', 'get');
      slsfnagctlr('View'); 
	end;
  catch,
	disp(lasterr);
  end
  
%---------------------------------------------------------
function scan_wires_l(editor),
%
%
%
	wires = sf('get', 'all','trans.id');

   editorWires = sf('find', wires, '.chart', editor);
	superWires  = sf('find', wires, '.type', 2, '.chart', editor);
   subWires    = sf('find', wires, '.type', 1, '.chart', editor);
    
   try,
      %
      % superWires
      %
      for wire=superWires(:).',
        check_superwire_sublinks_are_well_formed_l(wire, editorWires);
        check_superwire_src_dst_l(wire);
        check_superwire_hierarchy_l(wire, editorWires);
      end;     

      %
      % subWires
      %
      for wire=subWires(:).',
        check_subwire_src_dst_list_membership_l(wire);
        check_subwire_intersection_spaces_l(wire);
      end; 
      
        check_all_wires_link_integrity_l(editorWires);
   catch,
        lasterr
   end;
   
 
%--------------------------------------------------------
function check_superwire_hierarchy_l(superWire, editorWires),
%
%
%
    parent = sf('get', superWire, '.linkNode.parent');
    depth  = sf('get', parent', '.depth');
    
    if isequal(parent, 0),
        hilight_wire_l(superWire, sprintf('SuperWire (#%d) parent == 0!\n', superWire));   
    end;
    
    
    subLinks = sf('find', editorWires, '.subLink.parent', superWire);
    subParents = sf('get', subLinks, '.linkNode.parent');
    subDepths  = sf('get', subParents, '.depth');
    
    if any(subDepths<depth),
        hilight_wire_l(superWire, sprintf('Bad hierarchy depth for superWire (#%d)!\n', superWire));
    end;

  
   
   

%--------------------------------------------------------
function check_superwire_src_dst_l(superWire),
%
%
%
    srcId = sf('get', superWire, '.src.id');
    dstId = sf('get', superWire, '.dst.id');

    fsw = sf('get', superWire, '.firstSubWire');

    if ~isequal(fsw, 0), 
        subSrcId  = sf('get', fsw, '.src.id');
        if ~isequal(srcId, subSrcId),
            hilight_wire_l(fsw, sprintf('SuperWire (#%d) srcId (#%d) != firstSubWire (#%d) srcId (#%d)\n', superWire, srcId, fsw, subSrcId)); 
        end
    else,
        % this can't happen since the superWire MUST have a firstSubWire and this would have been detected by 'check_superwire_sublinks_are_well_formed_l(wire, editorWires);
        keyboard
    end;

    % find last sub wire (==terminating wire)
    link = fsw;
    while isa_wire_l(link),
        lsw = link;
        link = sf('get', link, '.subLink.next');
    end;

    if ~isequal(fsw, lsw), 

        lswDstSpace = sf('get', lsw, '.dst.intersection.space');

        if isequal(lswDstSpace, 0), 
        subDstId = sf('get', lsw, '.dst.id');
    
        if ~isequal(dstId, subDstId),
            hilight_wire_l(fsw, sprintf('SuperWire (#%d) dstId (#%d) != terminatingSubWire (#%d) dstId (#%d)\n', superWire, dstId, lsw, subDstId)); 
        end
        else
            if ~isequal(dstId, 0),
                hilight_wire_l(fsw, sprintf('SuperWire (#%d) has no terminating wire BUT it''s dstId (#%d) != 0\n', superWire, dstId, lsw, subDstId)); 
            end       
        end;
    else
        if ~isequal(dstId, 0), 
            hilight_wire_l(fsw, sprintf('SuperWire (#%d) has no terminatingSubWire but it''s dstId = (#%d)!\n', superWire, dstId)); 
        end;
    end;
    
 
%--------------------------------------------------------
function check_superwire_sublinks_are_well_formed_l(superWire, editorWires),
%
%
%
    
    %
    % confirm firstSubWire is valid
    %
    link = sf('get', superWire, '.firstSubWire');

    if ~isa_wire_l(link), 
        hilight_wire_l(superWire, sprintf('SuperWire (#%d) has no firstSubWire!\n', superWire));
    end;

    %
    % confirm subLink.parent and subLink.before fields based on subLink.next 
    %    


    subLinks = [];
    while isa_wire_l(link),
        subLinks = [subLinks, link];
        parent = sf('get', link, '.subLink.parent');
        if ~isequal(superWire, parent), 
            hilight_wire_l(link, sprintf('Sublink (#%d) invalid sublink parent (#%d), expected (#%d)\n(or possible stray wire)\n', link, parent, superWire));
        end;

         nextLink = sf('get', link, '.subLink.next');
         if isa_wire_l(nextLink);
             prevLink = sf('get', nextLink, '.subLink.before');
             if ~isequal(prevLink, link),
                 hilight_wire_l(nextLink, sprintf('Sublink (#%d) INVALID subLink.before field (#%d) expected (#%d)\n', nextLink, prevLink, link));
             end;
         end;
         link = nextLink;
    end;

    %
    % check for stray subWires that THINK they're on the superWire's sublink list but aren't
    %
    subWires = sf('find', editorWires, '.subLink.parent', superWire);
    
    subLinks = sort(subLinks);
    subWires = sort(subWires);
    
    strayWires = sf('Private', 'vset', subLinks, '-', subWires);
    
    for strayWire=strayWires(:).',
        supposedParent = sf('get', strayWire, '.subLink.parent');
        hilight_wire_l(strayWire, sprintf('STRAY WIRE (#%d): Not on parent''s (#%d) sublink list!', strayWire, supposedParent));
    end;

     %
     % check for any bogus links that think they're in the same hierarchy as the superwire
     %

     % Validate the Next refs
     nextRefs    = sf('find', editorWires, '.linkNode.next', superWire, '~trans.chart', 0);
     superBefore = sf('get', superWire, '.linkNode.before');
     switch length(nextRefs),
        case 0, 
            if ~isempty(superBefore) & ~isequal(superBefore, 0),
                hilight_wire_l(superWire, sprintf('Superwire (#%d) thinks it''s linkNode.before is (#%d) but none was found', superWire, superBefore));
            end;
        case 1,
            if  ~isequal(superBefore, nextRefs),
                hilight_wire_l(superWire, sprintf('Superwire''s (#%d) before (#%d) not linked up (but (#%d) thinks it is!', superWire, superBefore, nextRefs)); 
            end;
        otherwise,
            hilight_wire_l(superWire, sprintf('More than one wire''s linkNode.next == (#%d)!', superWire));
     end;
        
     % Validate the before refs
     beforeRefs = sf('find', editorWires, '.linkNode.before', superWire, '~trans.chart', 0);
     superNext = sf('get', superWire, '.linkNode.next');
     switch length(beforeRefs),
        case 0,
            if ~isempty(superNext) & ~isequal(superNext, 0),
                hilight_wire_l(superWire, sprintf('Superwire (#%d) thinks it''s linkNode.next is (#%d) but none was found', superWire, superNext));
            end;
        case 1,
        	if ~isequal(superNext, beforeRefs),
              hilight_wire_l(superWire, sprintf('Superwire''s (#%d) next (#%d) not linked up (but (#%d) thinks it is!', superWire, superNext, beforeRefs)); 
             end;
     otherwise,
          hilight_wire_l(superWire, sprintf('More than one wire''s linkNode.before == (#%d)!', superWire));
     end;
     
     % Validate the parent refs  
     refs = sf('find', 'all', 'state.firstTrans', superWire, '~state.chart', 0);
     superParent = sf('get', superWire, '.linkNode.parent');
     switch length(refs),
        case 0,
        case 1,
            if ~isequal(superParent, refs),
              hilight_wire_l(superWire, sprintf('Superwire''s (#%d) parent (#%d) not linked up (but (#%d) thinks it is!', superWire, superParent, refs)); 
            end;
        otherwise,
            hilight_wire_l(superWire, sprintf('More than one state''s firstTransition == (#%d)!', superWire));
     end;


%--------------------------------------------------------
function x = isa_wire_l(id),
%
%
%
    WIRE = sf('get', 'default', 'trans.isa');
    isa = sf('get', id, '.isa');
    if isequal(isa, WIRE), x = logical(1); else x = logical(0); end;



%--------------------------------------------------------
function hilight_wire_l(wire, msg),
%
%
%
    disp(['Super Checker Diagnostic: ', msg]);
    editor = sf('get', wire, '.chart');
    highlit = sf('find','all', '~trans.chart', 0);
    highlit = sf('find', highlit, 'trans.chart', editor, 'trans.highlit', 1);
 
    nag = slsfnagctlr('NagTemplate');
    
    nag.type          = 'Error';
    nag.msg.typ       = 'SuperTrans';
    nag.msg.details   = msg;
    nag.msg.summary   = msg;  
    nag.sourcFullName = sf('FullNameOf', editor,'/');
    nag.sourceName    = sf('get', editor,'.name');
    nag.component     = 'Stateflow';

    nags = slsfnagctlr('GetNags');
    
    duplicate = logical(0);
    for i=1:length(nags);
        if isequal(nags(i), nag) duplicate = logical(1); end;
    end;

    if ~duplicate,
        slsfnagctlr('Push', nag);
        sf('Highlight', editor, [highlit, wire]);
    end;

    had_super_nags_l('mark');


    
    
%--------------------------------------------------------
function check_subwire_src_dst_list_membership_l(subWire),
%
%
%
    srcId = sf('get', subWire, '.src.id');
    dstId = sf('get', subWire, '.dst.id');

    %
    % check src list
    %
    if ~isequal(srcId, 0),
        srcWires = sf('get', srcId, '.srcTrans');
        if ~any(srcWires==subWire),
            hilight_wire_l(subWire, sprintf('Sublink (#%d) NOT on srcId''s (#%d) srcWires list\n', subWire, srcId));
        end;
    end;


    %
    % check dst list
    %
    if ~isequal(dstId, 0),
        dstWires = sf('get', dstId, '.dstTrans');
        if ~any(dstWires==subWire),
            hilight_wire_l(subWire, sprintf('Sublink (#%d) NOT on dstId''s (#%d) dstWires list\n', subWire, dstId));
        end;
    end;


    
%--------------------------------------------------------
function check_subwire_intersection_spaces_l(subWire),
%
%
%
    NORMAL = 0;
    SUPER  = 1;
    SUB    = 2;

    srcSpace = sf('get', subWire, '.src.intersection.space');
    dstSpace = sf('get', subWire, '.dst.intersection.space');

    switch srcSpace,
        case NORMAL,
            switch dstSpace,
                case NORMAL, hilight_wire_l(subWire, sprintf('Subwire (#%d) has malformed intersection space(s) \n(BOTH src & dst intersection.spaces are NORMAL_SPACE ==> SIMPLE wire!)\n', subWire));
                case SUB,
                case SUPER,
                otherwise,   hilight_wire_l(subWire, sprintf('Subwire (#%d) has an undefined dst intersection space!\n', subWire));
            end;
        case SUB,
            switch dstSpace,
                case NORMAL,
                case SUB,
                case SUPER,  
                otherwise,   hilight_wire_l(subWire, sprintf('Subwire (#%d) has an undefined dst intersection space!\n', subWire));  
            end;
        case SUPER,
            switch dstSpace,
                case NORMAL,
                case SUB,    
                case SUPER,  hilight_wire_l(subWire, sprintf('Subwire (#%d) has malformed intersection space(s) \n(src == SUPER_SPACE && dst == SUPER_SPACE!)\n', subWire));
                otherwise,   hilight_wire_l(subWire, sprintf('Subwire (#%d) has an undefined dst intersection space!\n', subWire));                   
            end;
        otherwise,
            hilight_wire_l(subWire, sprintf('Subwire (#%d) has an undefined src intersection space!\n', subWire));
    end;


%--------------------------------------------------------
function check_all_wires_link_integrity_l(wires),
%
%
%
    if isempty(wires) | length(wires) < 1, return; end;

    linkNodes = sf('get', wires, '.linkNode');
    
    prevs = linkNodes(:,2);
    prevs(prevs==0) = [];
    prevs = sort(prevs);
    uPrevs = unique(prevs);
    if ~isequal(uPrevs, prevs),
        % error detected, isolate it.
        dups = sf('Private', 'vset', prevs, '-', uPrevs);
        for dup = dups(:).',
            hilight_wire_l(dup, 'LINKNODE error: wire (%d), is pointed to by two different wire''s linkNode.before field!');
        end;
    end;
    
    nexts = linkNodes(:,3);
    nexts(nexts==0) = [];
    nexts = sort(nexts);
    uNexts = unique(nexts);
    if ~isequal(uNexts, nexts),
        % error detected, isolate it.
        dups = sf('Private', 'vset', nexts, '-', uNexts);
        for dup = dups(:).',
            hilight_wire_l(dup, 'LINKNODE error: wire (%d), is pointed to by two different wire''s linkNode.next field!');
        end;
    end;
    
    for wire=wires(:).',
        subviewer = sf('get', wire, '.subviewer');
        localWires = sf('get', subviewer, '.localTransitions');
        ind = find(wire==localWires);
        switch length(ind),
            case 0, hilight_wire_l(wire, sprintf('Wire (#%d) not on subviewer list (#%d)', wire, subviewer));
            case 1,
            otherwise,
                hilight_wire_l(wire, sprintf('Wire (#%d) was found on several subviewer lists', wire));
        end;
     end;
    
    
%--------------------------------------------------------
function x = had_super_nags_l(arg),
%
%
%
    persistent hadNags;
   
    if isempty(hadNags), hadNags = logical(0); end;

    if nargin == 1, 
        switch arg,
            case 'flush', hadNags = logical(0);
            case 'mark',  hadNags = logical(1);
            otherwise,    hadNags = logical(0);
        end;
    end;

    x = hadNags;
   
   


	

	
