function rg( ids, format, gSFoutFileName, targetDirName, toPrint )
% RG  This is the book generator for Stateflow
% supported format is Postscript and PDF

%   Vladimir Kolesnikov
%   Jay R. Torgerson
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.24.2.5 $ $Date: 2004/04/15 00:59:07 $

if nargin == 1 & strcmp( ids, 'cancel' )
   global gSFCancelFlag;
   gSFCancelFlag = 1;
   disp( 'Stateflow Print Book cancelled' );
   return;
end

if nargin <= 2,

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Disable print as book if  any
    % of the charts contain subcharts.
    chartArgs = sf('find', ids, '.isa', sf('get','default','chart.isa'));
    allCharts = sf('get',sf('get',chartArgs(1),'chart.machine'),'machine.charts');
    for chart = allCharts(:)'
        if rg_printbook_cant_handle_chart(chart)
            errordlg('Print as book is disabled for models containing subcharts, truthtables, or Embedded MATLAB functions.');
            return;
        end
    end

	rg_dialog('construct', ids, format );
	return;
end
	
html = 0;
ps = 0;
pdf = 0;
%if strcmp( format, 'html' )
%	html = 1;
%end
if strcmp( format, 'ps' )
	ps = 1;
end
if strcmp( format, 'pdf' )
	pdf = 1;
end

if ~(ps|pdf)
	error( [ 'Unsupported format: ' format ] );
end

% do the pdf
%pdf = 0;
clear_all_global;
init_pdfOffset;


% set the type table used in  type2num and num2type
global gSFtypeTable;
types = {'machine', 'chart', 'target', 'instance', 'state', 'transition', ...
      'junction', 'event', 'data', 'note' };
for i = 1:length(types)
	curType = sf( 'get', 'default', [ types{i} '.isa' ]);
	gSFtypeTable{curType+1} = types{i};
end
% and our special case:
gSFtypeTable{12} = 'function';
gSFtypeTable{13} = 'group';
gSFtypeTable{14} = 'index';
pageBreakTag = '<SF_PAGE_BREAK>';


% ids must be charts. assert on that
charts = sf( 'find', ids, '.isa', type2num('chart') );
if length( ids ) ~= length( charts ) | isempty(ids)
   error('The argument must be a vector of chart id''s');
end


% variable declarations that are global to the function
% they all will be deleted upon termination of the function

global gSFvalueRuleChar; gSFvalueRuleChar = '$';  % the character that denotes that what follows it is
											 % the rule to convert the value
global gSFprintRuleChar; gSFprintRuleChar = '^';  % the character that denotes that what follows it is
										    % the rule to convert the print entry of the new value
global gSFignoreRuleChar; gSFignoreRuleChar = '@';  % the character that denotes that what follows it is
										    % the rule to ignore the entry

psFontName = 'Courier';
psBoldFontName = 'Courier-Bold'; 
psItalicFontName = 'Courier-Oblique'; 
global gSFpsJapaneseFontName;
gSFpsJapaneseFontName = 'HeiseiKakuGo-W5-90ms-RKSJ-H';
global gSFisJapanese;
lang = get(0, 'language' );
if length( lang ) >=2 & strcmp( lang(1:2), 'ja' )
   gSFisJapanese = 1;
else
   gSFisJapanese = 0;
end


psFontSize = 10;
psLineSpace = 2;
global gSFpsLeftMargin; gSFpsLeftMargin = 72;
global gSFpsRightMargin; gSFpsRightMargin = 35;
psTopMargin = 35;
psBottomMargin = 72;
pageHeight = 790;
global gSFpageWidth; gSFpageWidth = 600;
  

                          
global gSFimageDirName;
%targetDirName = pwd;
gSFimageDirName = [ targetDirName filesep 'Images'];
global gSFinitDirName;
gSFinitDirName = pwd;
fullOutFileName = [targetDirName filesep gSFoutFileName];
global gSfORStateType; gSfORStateType = 0;
global gSfANDStateType; gSfANDStateType = 1;
global gSfFunctionStateType; gSfFunctionStateType = 2;
global gSfGroupStateType;  gSfGroupStateType = 3;
global gSFlegibleSize; gSFlegibleSize = 6;
global gSFCancelFlag; gSFCancelFlag = 0;
global gSFFullOutFileName;

global gSFobjAbbr;
gSFobjAbbr.machine = 'M';
gSFobjAbbr.chart = 'C';
gSFobjAbbr.target = 'Trgt-';
gSFobjAbbr.instance = 'I';
gSFobjAbbr.state = 'S';
gSFobjAbbr.transition = 'T';
gSFobjAbbr.junction = 'J';
gSFobjAbbr.event = 'E';
gSFobjAbbr.data = 'D';
gSFobjAbbr.function = 'F';
gSFobjAbbr.group = 'B';

global gSFobjCount;
gSFobjCount.machine = 0;
gSFobjCount.chart = 0;
gSFobjCount.target = 0;
gSFobjCount.instance = 0;
gSFobjCount.state = 0;
gSFobjCount.transition = 0;
gSFobjCount.junction = 0;
gSFobjCount.event = 0;
gSFobjCount.data = 0;
gSFobjCount.function = 0;
gSFobjCount.group = 0;


global gSFlayoutTable;
gSFlayoutTable = read_layout_table;  % set table values

global gSFmaxDepth;
gSFmaxDepth = 0;
widthRatio = 0.65;

%open the file for writing
outFile = fopen( fullOutFileName, 'w' );
if outFile == -1
   error( ['Could not open the out file:  ', ... 
      fullOutFileName] );
end
gSFFullOutFileName = fullOutFileName;

global gSFreportList;
reportStructList = (generate_all_ids( ids ));

sfIndexId = sf( 'new', 'note' );
sf( 'set', sfIndexId, '.labelString', num2str( (reportStructList (:,1))' ) ); 
%fullReportStructList = [reportStructList; [sfIndexId, 0]];

% Now clear the gSFreportList accordingly to the conditions set in the layout file
for i = 1:length(reportStructList)
	listEntryId = reportStructList( i );
	myType = whoami( listEntryId );
	defStruct = gSFlayoutTable{ myType + 1 };
	while i <= length(gSFreportList) & (defStruct.repMinChildren > length( eval( 'sf( ''ObjectsIn'', listEntryId )', '[]' ) ) ...
				| defStruct.ignore == 1) 
		% remove the object from the list of reportable objects
		reportStructList(i,:) = [];
		listEntryId = reportStructList( i );
		myType = whoami( listEntryId );
		defStruct = gSFlayoutTable{ myType + 1 };	
	end
end


gSFreportList = (reportStructList (:,1))';
%write headers
%if html,
%	fprintf( outFile, '<html>\n' );
%	fprintf( outFile, '<head><title>Stateflow Report</title></head>\n' );
%	fprintf( outFile, '<body>\n\n' );
%end

if ps,

   global gSFtContents;   % global table of contents ( a map id -> page no )
	gSFtContents = sparse( 100000000, 1 );   
   
   fprintf( outFile, '%s\n', '%!PS-Adobe-2.0' );
   fprintf( outFile, '%s\n', '%%Creator: Stateflow, MATLAB, The Mathworks, Inc.' );
   fprintf( outFile, '%s\n', ['%%CreationDate: ' sf_date_str ] );
   fprintf( outFile, '%s\n', '%%EndComments' );
   c = clock;
   curTime = [date '  ' rg_num2str( c(4)) ':' rg_num2str(c(5)) ':' rg_num2str(floor(c(6))) ];
	fprintf( outFile, '%s\n', '%!' );
	fprintf( outFile, '%s\n', '%%BeginProlog' );
	fprintf( outFile, '/xdef{ \n exch \n def \n} def \n 0 setlinewidth\n' );
	rrectDef = [...
		'%% Draws rectangle with rounded corners\n' ...
		'%% Arguments  x y w h r.\n' ...
		'/rrect{\n' ...
		'/r xdef\n' ...
		'/h xdef\n' ...
		'/w xdef\n' ...
		'/y xdef\n' ...
		'/x xdef\n' ...
		'/y1 y h r sub add def  %% absolute value\n' ...
		'/x1 x w r sub add def  %% absolute value\n' ...
		'x y moveto\n' ...
		'0 r rmoveto\n' ...
		'x y1 lineto\n' ...
		'r r rmoveto\n' ...
		'x1 y h add lineto\n' ...
		'r 0 r sub rmoveto\n' ...	
		'x w add y r add lineto\n' ...
		'0 r sub dup rmoveto\n' ...
		'x r add y lineto\n' ...
		'%% to this point all lines are drawn\n' ...
		'%% draw the four curves\n' ...
		'%% lower left:\n' ...
		'x y r add moveto\n' ...
		'x r add y r add r 180 270 arc\n' ... 
		'%% upper left\n' ...
		'x r add y h add 2 copy moveto r sub r 90 180 arc\n' ...
		'%% upper right\n' ...
		'x w add y1 moveto\n' ...
		'x1 y1 r 0 90 arc\n' ...
		'%% lower right\n' ...
		'x1 y moveto\n' ...
		'x1 y r add r 270 0 arc\n' ...
		'} def\n' ];
	transDef = [ ...
		'%% Draws a transition given the coefficients in form\n' ...
		'%%   x(t) =  c(1,1)t^4 + c(2,1)t^3 + c(3,1)t^2 + c(4,1)t + c(5,1)\n' ...
		'%%   y(t) =  c(1,2)t^4 + c(2,2)t^3 + c(3,2)t^2 + c(4,2)t + c(5,2)\n' ...
		'%%   and two points p1 and p2 to draw the arrowhead\n' ...
		'%%   Arguments: c11, c21, ... c51, c12, ... c52, p1x, p1y, p2x, p2y, p3x, p3y\n' ...
		'/trans{\n' ...
		'/p3y xdef\n' ...
		'/p3x xdef\n' ...
		'/p2y xdef\n' ...
		'/p2x xdef\n' ...
		'/p1y xdef\n' ...
		'/p1x xdef\n' ...
		'/c52 xdef\n' ...
		'/c42 xdef\n' ...
		'/c32 xdef\n' ...
		'/c22 xdef\n' ...
		'/c12 xdef\n' ...
		'/c51 xdef\n' ...
		'/c41 xdef\n' ...
		'/c31 xdef\n' ...
		'/c21 xdef\n' ...
		'/c11 xdef\n' ...
		'/step 0.025 def\n' ...  % define the number of points to define the spline curve
		'c51 c52 neg moveto\n' ... %move to the beginning of the curve
		'0 step 1{\n' ...
		'/t xdef\n' ...
		't t mul dup mul c11 mul\n' ... 	% c11 * t^4 put on stack
		't t t mul mul c21 mul\n' ... 	% c21 * t^3 put on stack
		't t mul c31 mul\n' ...				% c31 * t^2 put on stack
		't c41 mul\n' ...						% c41 * t put on stack
		'c51 add add add add\n' ...		% x(t) on stack
		't t mul dup mul c12 mul\n' ... 		% c12 * t^4 put on stack
		't t t mul mul c22 mul\n' ... 		% c22 * t^3 put on stack
		't t mul c32 mul\n' ...					% c32 * t^2 put on stack
		't c42 mul\n' ...							% c42 * t put on stack
		'c52 add add add add neg\n' ...			% y(t) on stack
		'lineto\n'...		% and draw this part of the spline		
		'} for\n' ...
		'%% draw the arrow\n' ...
		'p1x p1y neg moveto\n' ...
		'p2x p2y neg lineto\n' ...
		'p3x p3y neg lineto\n' ...
		'p1x p1y neg lineto\n' ...
		'} def\n' ];
	rectDef = [ ...
		'%% Draws rectangle. its arguments are x y w h\n' ...
		'/rect{\n' ...
 		'4 2 roll  %% roll the top 4 elements on the stack\n' ...
		'          %% so that it is w h x y\n' ...
		'moveto    %% move to (x,y). the top of the stack is w h\n' ...
		'2 copy    %% the stack is now w h w h\n' ...
		'0 exch      %% the stack is now w h w 0 h\n' ...
		'rlineto   %%                  w h w\n' ...
		'0 rlineto %%                  w h\n' ...
		'0 exch sub%%                  w -h\n' ...
  		'0 exch\n' ...
   	'rlineto   %%                  w\n' ...
   	'0 exch sub%%                  -w\n' ...
		'0 rlineto\n' ...
		'} def\n' ];
	

	fprintf( outFile, rrectDef );
	fprintf( outFile, transDef );
	fprintf( outFile, rectDef );
   fprintf( outFile, '%s\n', ['/' psBoldFontName ' findfont /bfn xdef '] );  
   fprintf( outFile, '%s\n', ['/' psItalicFontName ' findfont /ifn xdef '] );  
	fprintf( outFile, '%s\n', ['/inf {ifn ' rg_num2str( psFontSize ) ' scalefont setfont} def'] );
	fprintf( outFile, '%s\n', ['/nf {fn ' rg_num2str( psFontSize ) ' scalefont setfont} def'] );
   fprintf( outFile, '%s\n\n', ...
      ['/' psFontName ' findfont dup /fn xdef ' ...
			rg_num2str(psFontSize) ' scalefont setfont ' ...
			'0 setlinewidth' ] );
	fprintf( outFile, '%s\n', '/cur1ptfont{currentfont dup /FontMatrix get 0 get 1 exch div 1000 div scalefont setfont currentfont}def' );
	% output all the functions to draw graphic primitives and set the gSFdrawInfo struct.
	generate_image_primitives( outFile, gSFreportList, 'ps' );
	
	fprintf( outFile, '%s\n', '%%EndProlog' );
	fprintf( outFile, '%s\n', '%%Page: 0 0' );
end

if pdf,

   global gSFtContents;   % global table of contents ( a map id -> page no )
	gSFtContents = sparse( 100000000, 1 );   

   write_pdf_header( outFile );
	

	% output all the functions to draw graphic primitives and set the gSFdrawInfo struct.
	generate_image_primitives( outFile, gSFreportList, 'pdf' );
end

% see if cancelFlag is set
if gSFCancelFlag
   cancel_fcn( outFile );
   return;
end
   

% generate a report on all machines and their children
%if html,
%	eval( 'mkdir ( gSFimageDirName );', ...
%   'warning([''Could not create temporary directory '' gSFimageDirName '' (already exists?)'']);' );
%end
%eval( ['cd ' gSFimageDirName ';'], 'error( ''Could not cd to temporary directory '' gSFimageDirName');

spaceLeft = pageHeight - psTopMargin;
prevId = gSFreportList(1);
curPageNum = 1;
global gSFdocument;  gSFdocument = {};  %the structure that contains all text information of the document
waitbarHandle = waitbar(0, 'SF Print Book: laying out the page', ...
   	'createCancelBtn',['sf(''Private'', ''rg'', ''cancel''); closereq']);
progress = 0;
repListLength = length(gSFreportList);
toRemove = [];
curColumn = 1;
columnVec = [1];
for i = gSFreportList
   if gSFCancelFlag
      cancel_fcn( outFile );
      return;
   end
   
   progress = progress + 1;
   % progress indicator
   if rem( i, 10 ) == 0;
      waitbar( progress/repListLength, waitbarHandle );
   end
   
   
   %if html
   %	fprintf( outFile, [ '\n' pageBreakTag '\n'] );
   %end
   [spaceLeft curPageNum hiddenContent curColumn] = report_it...
      ( outFile, i, format, spaceLeft, pageHeight, gSFpageWidth, psFontSize, psLineSpace, ...
      gSFpsLeftMargin, gSFpsRightMargin, psTopMargin, psBottomMargin, prevId, curPageNum, '', columnVec, curColumn );
   if hiddenContent == 0
      % the object will not be printed. 
      toRemove = [toRemove, i];
   else
      prevId = i;
   end
end
set( waitbarHandle, 'closeRequestFcn','closereq' );
close(waitbarHandle);
%generate index
columnVec = [0.343 0.343 0.314]; % the numbers are selected based on the fact that to leave space between 
											% columns all but last columns are defined to be 92% of the suggested width
											% these numbers will ensure equal column length. 
[spaceLeft curPageNum hiddenContent curColumn] = report_it...
	( outFile, sfIndexId, format, spaceLeft, pageHeight, gSFpageWidth, psFontSize, psLineSpace, ...
	gSFpsLeftMargin, gSFpsRightMargin, psTopMargin, psBottomMargin, prevId, curPageNum, 'index', columnVec, curColumn );
%remove objects not to be printed from reportStructList
[garbage indexes] = intersect( gSFreportList, toRemove );
reportStructList( indexes, : ) = [];
gSFreportList(indexes) = [];
% draw the last page number (if we just didn't do it)
if ( ps|pdf ) & spaceLeft ~= pageHeight - psTopMargin
	new_page( outFile, gSFreportList( length( gSFreportList ) ), ...
			curPageNum,...
			psFontSize,widthRatio,psBottomMargin-psFontSize*2,gSFpageWidth-gSFpsRightMargin);
end
   
% generate the  array of the nearest reported parents
allIds = str2num( sf( 'get', sfIndexId, '.labelString' ) );
nearestParent.data = zeros(1, length( allIds ) );
nearestParent.map = sparse( 100000000, 1 );
counter = 1;
for i = allIds
	parent = sf('ParentOf', i );
	while isempty( find( gSFreportList == parent ) ) & parent ~= 0
		parent = sf( 'ParentOf', parent );
	end
	nearestParent.data( counter ) = parent;
	nearestParent.map( i ) = counter;
	counter = counter + 1;
end
%gSFdrawInfo.nearestParent = nearestParent;
clear counter;	



%if html
%	fprintf( outFile, [ '\n' pageBreakTag '\n'] );
%	% and write the ending of the file
%	fprintf( outFile, '\n\n</body>\n' );
%	fprintf( outFile, '</html>\n' );
%end
if ps | pdf
   % this is the second pass of the program.  
   % global varable 'document' contains all the information on the document.
   % gSFtContents contains the mapping id -> page number
   % go through it and execute corresponding 

   % first, print the title page and the table of contents
   curPageNo = 1;
   curPageNo = print_table_of_contents( outFile, reportStructList, psFontSize, ...
      psLineSpace, gSFpsLeftMargin, gSFpsRightMargin, psTopMargin, psBottomMargin, ...
      pageHeight, gSFpageWidth, curPageNo, format );
	
	global gSFpagesOfTContents;
	global gSFdrawInfo;
   gSFpagesOfTContents = curPageNo - 1;
	
   waitbarHandle = waitbar(0, 'SF Print Book: generating file', ...
  	   	'createCancelBtn',['sf(''Private'', ''rg'', ''cancel''); closereq']);
	documentLength = length(gSFdocument);
	stream = '';
	objectsOnThisPage = [];
	for i = 1:length( gSFdocument )
      if gSFCancelFlag
         cancel_fcn( outFile );
         return;
      end
      if rem( i, 10 ) == 0;
			waitbar( i/documentLength, waitbarHandle );
		end
      entry = gSFdocument{i};
      cmd = entry{1};
      if iscell( cmd )
         % we are processing text entry.
         pos = entry{2};
			boldVal = entry{3};
			underline = entry{4};
			cellWidth = entry{5};
			justifyOffset = entry{6};
			posStr1 = rg_num2str( pos(1) + justifyOffset );
			posStr2 = rg_num2str( pos(2) - psFontSize - psLineSpace );
			t = '';
         if underline
				if ps
			  		t = [ ...
   		         '0 setlinewidth ' rg_num2str( pos(1) ) ' ' rg_num2str( pos(2) - psFontSize - psLineSpace - 2 ) ...
						 ' moveto ' rg_num2str( cellWidth ), ' 0 rlineto ' ...
      		   ];
				end
				if pdf
					stream = [ stream, ...
								' 0 w ' rg_num2str( pos(1) ) ' ' rg_num2str( pos(2) - psFontSize - psLineSpace - 2 ) ...
								' m ' rg_num2str( pos(1) + cellWidth ) ' ' rg_num2str( pos(2) - psFontSize - psLineSpace - 2 ) ' l S ' ...
					];
				end
			end
			if ps
            t = [ t, ...
                  posStr1 ' ' posStr2  ' moveto nf ' ...
            ];
			end
			if pdf
				stream = [ stream ' BT ' posStr1 ' ' posStr2 ' Td /NFt ' rg_num2str( psFontSize ) ' Tf ' ];
			end
         entryText = cmd{1};
         entryRef = cmd{2};
			pdfEntryRef = entryRef;
         if strcmp( entryRef, 'N' ) 
            % it is the name of the field.  make it bolder
				if ps
	            t = [t 'bfn ' rg_num2str( psFontSize ) ' scalefont setfont (' entryText ') show ' ];
				end
				if pdf
					stream = [ stream ' /BFt ' rg_num2str( psFontSize ) ' Tf (' entryText ') Tj ' ];
				end
         else
				directRef = 1;
				if ~isempty( entryRef) & entryRef > 0 & isempty( find( gSFreportList == entryRef ) )
					if nearestParent.map( entryRef ) == 0
						% no reference exists
						entryRef = -1; pdfEntryRef = -1;
					else
						entryRef = nearestParent.data( nearestParent.map( entryRef ) ); pdfEntryRef = entryRef;
						directRef = 0;
					end
				end
            if ~isempty( entryRef ) & entryRef > 0 & gSFtContents( entryRef ) ~= 0
               pageNo = gSFtContents( entryRef ) + gSFpagesOfTContents;
               entryRef = [ sf( 'get', entryRef, '.rgTag' ) ' p' rg_num2str(pageNo)];	
            else
               entryRef = '';
            end
				if boldVal == 1
					if ps
                  t = [t ...
                        ' bfn ' rg_num2str( psFontSize ) ' scalefont setfont (' ps_string(entryText) ') show ' ...
                  ];
					end
					if pdf
						stream = [ stream ' /BFt ' rg_num2str( psFontSize ) ' Tf (' ps_string(entryText) ') Tj ' ];
					end
            else
					if ps
                  t = [t ...
                        'nf (' ps_string(entryText) ') show ' ...
                     ];
					end
					if pdf
						if ~isempty( entryRef )
							stream = [ stream, ' S 0 0 0.5 rg ' ];
						end
						stream = [ stream ' /NFt ' rg_num2str( psFontSize ) ' Tf (' ps_string(entryText) ') Tj S 0 g ' ];	
					end
				end
				% the coordinates of a link
				x1 = pos(1) + justifyOffset;
				x2 = x1 + (length( entryText ) + 3) * psFontSize * 0.65;
				y1 = pos(2) - psFontSize - psLineSpace*3;
				y2 = y1 + psFontSize+psLineSpace;			
				if ps
               if directRef,
                  font = 'fn ';
               else
                  font = 'ifn ';
               end
               if ~isempty( entryRef )
                  t = [t ...
                        rg_num2str( psFontSize/5 ) ' ' rg_num2str( psFontSize/4 ) ' neg rmoveto ' ...
                        font rg_num2str( psFontSize/1.7 ) ' scalefont setfont ' ...
               	   '(' ps_string(entryRef) ') show '...
					%		'[ /Rect [' num2str( [x1,y1,x2,y2] ) '] ' ...
					%		'/Border [ 16 16 1 [ 3 10 ] ] '...
					%		'/Color [ 0 .7 1 ] ' ...
					%		'/Dest /SFD' rg_num2str( pdfEntryRef ) ' '...
					%		'/Subtype /Link ' ...
					%		'/ANN '...
					%		'pdfmark '...
                    ];
               end
            end
				if pdf
               if directRef,
                  font = '/NFt ';
               else
                  font = '/IFt ';
               end
               if ~isempty( entryRef )
						stream = [ stream ' S 0 0 0.5 rg '...
									rg_num2str( -psFontSize/4 ) ' Ts ' font rg_num2str( psFontSize/1.7 ) ' Tf (' ...
									ps_string(entryRef) ') Tj 0 Ts S 0 g ' ...
						];
			
			
						pdf_add_link( outFile, [x1,y1, x2, y2], pdfEntryRef );
               end
            end
         end 
			if ps
	         fprintf( outFile, '%s\n', t ); 
			end
			if pdf
				stream = [ stream ' ET ' ];
			end
      else
         if strcmp( cmd, 'newPage' )
            pos = entry{3};
				id = entry{4};
            pageN = rg_num2str( entry{2} + gSFpagesOfTContents );
				% compute the footer
				
				myParent = sf( 'ParentOf', id );
				footer = '';
				if myParent ~= 0
					footer = sf( 'FullNameOf', myParent, '/' );
				end

				maxChars = floor( (pos(1) - gSFpsLeftMargin) / (psFontSize * 0.65) );
       		if length( footer ) > maxChars
         		extra = length(footer) - maxChars;
         		numChars = length( footer ) - extra-3;
         		footer = [ footer( 1:floor(numChars/5) ) '...' ...
						footer( floor(length(footer)-numChars*4/5):length(footer)) ];
				end
				
				if ps
               t = [ ...
                     rg_num2str( gSFpsLeftMargin ) ' ' rg_num2str( pos(2) ) ' moveto '...
                     'fn ' rg_num2str( psFontSize ) ' scalefont setfont ' ...
                     '(' footer  ') show ' ...
                  ];
               
               
               t = [ t ...
                     rg_num2str( pos(1) ) ' ' rg_num2str( pos(2) ) ' moveto '...
                     'fn ' rg_num2str( psFontSize ) ' scalefont setfont ' ...
                     '(' pageN  ') show ' ...
                     'stroke showpage' ...
                  ];
               fprintf( outFile, '%s\n', t );
               fprintf( outFile, '%s\n', '%%PageTrailer' ); 
            end
				if pdf
					stream = [ stream ...
						' BT ' rg_num2str( gSFpsLeftMargin ) ' ' rg_num2str( pos(2) ) ' Td '...
						' /NFt ' rg_num2str( psFontSize ) ' Tf (' footer ') Tj ET BT ' ...
						rg_num2str( pos(1) ) ' ' rg_num2str( pos(2) ) ' Td '...						
						'(' pageN ') Tj ET ' ...
					];
					% now the stream is ready. Create the page object
					streamObjNum = write_pdf_object( outFile, stream, 'st', 0 );
					pageObj = [ ' /Type /Page ', ... % parent obj id is added in write_pdf_obj
						'/Contents ' rg_num2str( streamObjNum ) ' 0 R '...
		...				'/Trans << /S /Dissolve /D 0.1 >> ' ...
						'/Resources 3 0 R ' ...
					];
					if i == length( gSFdocument )
						isLastPage = 1;
					else
						isLastPage = 0;
					end
					pageObjNum = write_pdf_object( outFile, pageObj, 'pg', curPageNo, objectsOnThisPage,isLastPage );
					stream = '';
					objectsOnThisPage = [];
				end
	        	curPageNo = curPageNo + 1;
         	pn = rg_num2str( curPageNo );

         	% start a new page only if there is something following this doc entry
				if i < length( gSFdocument )
					if ps
						fprintf( outFile, '%s\n', ['%%Page: ' pn ' ' pn] );	
					end
				end
         end
			if strcmp( cmd, 'id' ) & pdf
				objectsOnThisPage = [objectsOnThisPage, entry{2}];
			end
         if strcmp( cmd, 'image' )
				if ps | pdf
               id = entry{2};
               imCoords = entry{3};
               leftMargin = entry{4};
               spaceLeft = entry{5};
               imStream = print_image( outFile, id, imCoords, leftMargin, spaceLeft, ...
										gSFpageWidth - gSFpsRightMargin,gSFreportList, format );
					if pdf
						stream = [ stream imStream ];
					end
            end
         end
         if strcmp( cmd, 'ref' )
            id = entry{2};
            leftMargin = entry{3};
            spaceLeft = entry{4};
            entryRef = gSFdrawInfo.context( gSFdrawInfo.map( id ) );
            if entryRef ~= id & entryRef ~= 0
               pageNo = gSFtContents( entryRef ) + gSFpagesOfTContents;
					pdfEntryRef = entryRef;
               entryRef = [sf( 'get', entryRef, '.rgTag' ) ' p' rg_num2str(pageNo)];
               entryText = [ '(For context see ', entryRef, ')'];
               xPos = (gSFpageWidth - gSFpsRightMargin+gSFpsLeftMargin-psFontSize*0.65*length(entryText))/2;
               posStr1 = rg_num2str( xPos );
					yPos = spaceLeft - psFontSize - psLineSpace;
               posStr2 = rg_num2str( yPos );
					if ps
                  t = [ ...
                        posStr1 ' ' posStr2 ' moveto inf (' ps_string(entryText) ') show nf'...
                  ];
						%t = ['[/Dest /SFD' rg_num2str( i ) ' /Page ' rg_num2str( curPageNo ) ...
						%		' /View [ /FitH 5 ] /DEST pdfmark ' ];
                  fprintf( outFile, '%s\n', t );
					end
					if pdf
						stream = [ stream ' S BT 0 0 0.5 rg /IFt ' rg_num2str( psFontSize ) ' Tf ' posStr1 ' ' posStr2...
									' Td (' ps_string(entryText) ') Tj ET S 0 g ' ];
						pdf_add_link( outFile, ...
							[xPos-psFontSize/2, yPos-psLineSpace, xPos+(length(entryText)+2)*psFontSize*0.65, yPos+psFontSize],...
							 pdfEntryRef );
					end 
            end	
			end  %if strcmp      
      end % if iscell
      
   end % for
  

%fprintf( outFile, '%s\n', [ '%%Pages: ' rg_num2str( curPageNo ) ] );
	set( waitbarHandle, 'closeRequestFcn','closereq' );
	close(waitbarHandle);
	if pdf
		fullReportStructList = [reportStructList; [sfIndexId, 0]];
		write_pdf_trailer( outFile, psFontName, psBoldFontName, psItalicFontName, fullReportStructList );
	end
  	sf( 'delete', sfIndexId );  % remove this 'note'-index object we have created.
end % if ps | pdf

fclose( outFile );
if ps == 1 & toPrint == 1
	% print it
	%
	% here goes pretty much the cut'n'paste from print.m to handle sending file to printer	
	lprcmd = printopt;
	comp = computer;
	if (comp(1:2) == 'PC')
      cmd = sprintf(strrep(lprcmd,'\','\\'), fullOutFileName);
      [dstatus, doutput] = dos(cmd);
      sf_delete_file(fullOutFileName);
   elseif isunix
      % it is unix
      [ustatus, uoutput] = unix([lprcmd ' ' fullOutFileName]);
      if exist( fullOutFileName ) == 2,
		   sf_delete_file(fullOutFileName);
      end
   else
      error('Platform not supported');
	end
end	
% we are done, cleanup.
cleanup_fcn;


function cancel_fcn( outFile )
fclose( outFile );
global gSFFullOutFileName;
sf_delete_file( gSFFullOutFileName );
cleanup_fcn;


function cleanup_fcn
global gSFinitDirName;
cd ( gSFinitDirName );
clear_all_global;


function [gSFpageWidth, leftMargin ] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn )
% this function updates values of gSFpageWidth and leftMargin to facilitate use of several columns per page.
% none of the rest of the code is changed.
	global gSFpsLeftMargin; leftMargin = gSFpsLeftMargin;
	if curColumn == length( columnVec )
		leaveSpaceCoef = 1;
	else
		leaveSpaceCoef = 0.92;
	end
	gSFpageWidth = leftMargin + rightMargin + realPageWidth * ...
		( columnVec * [ones( 1, curColumn ), zeros( 1, length( columnVec ) - curColumn ) ]' )* leaveSpaceCoef ; 
	leftMargin = leftMargin + realPageWidth * ...
		( columnVec * [ones( 1, curColumn - 1), zeros( 1, length( columnVec ) - curColumn + 1) ]' ); 


function [newSpaceLeft, curPageNum, hiddenContent, curColumn] = report_it ...
			( fid, id, format, spaceLeft, pageHeight, gSFpageWidth, fontSize, lineSpace, ...
			leftMargin, rightMargin, topMargin, bottomMargin, prevId, curPageNum, typeName, columnVec, curColumn )
% the function takes object's id and writes the report to the file fid. 
% format: either pdf or ps.
% spaceLeft, gSFpageWidth and pageHeight are 'ps'-specific.


% Update gSFpageWidth, rightMargin and leftMargin according to the current coulmn information
realPageWidth = gSFpageWidth - leftMargin - rightMargin;
[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
%rightMargin unchanged


objectDistance = 35; % distance in points between 2 objects
global gSFlayoutTable;
%global gSFoutFileName;
newSpaceLeft = 0;  % initialize it for the 'html' output.

html = 0;
ps = 0;
pdf = 0;
%if strcmp( format, 'html' )
%	html = 1;
%end

if strcmp( format, 'ps' )
	ps = 1;
end

if strcmp( format, 'pdf')
	pdf = 1;
end

if ~( pdf | ps)
	error( [ 'Unsupported format: ' format ] );
end




% Now we have to query the gSFlayoutTable to determine where
% to put what

% first, determine which cell describes my layout
if ~isempty( typeName )
	type = type2num( typeName );
else
	type = whoami( id );
end
defStruct = gSFlayoutTable{ type + 1 };
layout = defStruct.layout;

global gSFdrawInfo;
% check to see if we have image description. 
imageDescription = defStruct.image;
imagePresent = 0; imageCoords = []; imageFormat = '';
hiddenContent = 0;
if ~isempty( imageDescription ) & ...
		(gSFdrawInfo.numLegibleKids( gSFdrawInfo.map( id ) ) > 0   | ...
		gSFdrawInfo.legibleIn( gSFdrawInfo.map( id ) ) == id )
		% do not draw the image if both are true:
		% 1. I look fine on my ancestor's picture 
		% 2. I have no children that I make legible
   imagePresent = 1;
   imageCoords = [imageDescription{1}, imageDescription{2}];
   imageFormat = imageDescription{3}; 
	hiddenContent = 1; 
end


global gSFdocument;


stringTable = {};
tableNum = -1;
for i = 1:length(layout)
   property = layout{i};
	
	if tableNum ~= property{3}
		% clear the nonEmpty table for the next virtual table
		clear global SFCellEmpty;
		global SFCellEmpty;
	end;
   
   sfName = property{1};
   printName = property{2};
	tableNum = property{3};
   coords = property{4};
   valueRule = property{5};
   printRule = property{6};
   widthPercent = property{7};
	boldVal = property{8};
	important = property{9};
	ignoreRule = property{10};
	underline = property{11};
	rightJustify = property{12};
   %construct the entry
   isLink = 0;
   if sfName(1) == '~' 
      sfName(1) = [];
      isLink = 1;
   end
   if ~strcmp( sfName, 'SF_TEXT' )
	   value = sf( 'get', id, sfName );
	else
		value = printName;
		printName = [];
	end

   % apply the value rule if specified

   if ~isempty( valueRule )
      global gSFvalueRuleChar;
      value = eval( strrep( valueRule, gSFvalueRuleChar, ['[' rg_num2str14(value) ']'] ) );
   end
   
   % 2 cases: not a link, or a vector of links( may have length == 1, of course )
   global gSFprintRuleChar;
	global gSFignoreRuleChar;
   entry.printName = printName;
	entry.putInTable = defStruct.putInTable;
   entry.printValue = {}; 
   entry.numColumns = 1;
	entry.boldVal = boldVal;
	entry.underline = underline;
	entry.rightJustify = rightJustify;
	valueNotEmpty = 0;
   if isLink == 0
      if ~isempty( printRule )
         printValue = eval( strrep( printRule, gSFprintRuleChar,  ['[' rg_num2str14(value ) ']'] ) );
      else 
         printValue = value;
      end
   	entry.printValue{1} = {printValue, ''};     
		if ~isempty( printValue )	valueNotEmpty = 1;	end    
	else
      global gSFreportList;
      for j = value
         if ~isempty( printRule )
            refPrint = eval( strrep( printRule, gSFprintRuleChar, rg_num2str14(j) ) );
         else % default rule is the name of the link   
            refPrint = sf('get', j, '.name' );            
         end
			if isempty( refPrint)
				refPrint = '?';
			end
         
			len = length( entry.printValue );
			ref = '';
			%if ~ismember( j, gSFreportList )
            %ref = sf('get', j, '.rgTag'); 
			%end
			entry.printValue{ len + 1 } = { refPrint, j };  
			if ~isempty( refPrint )	valueNotEmpty = 1;	end    
      end
	end

	if important == 1 & valueNotEmpty == 1
		hiddenContent = 1;
	end
   entry.widthPercent = widthPercent;   
	if valueNotEmpty
		SFCellEmpty( coords(1)+1, coords(2)+1 ) = 0;
	else
		SFCellEmpty( coords(1)+1, coords(2)+1 ) = 1;
	end
	ignore = 0;		
	if ~isempty (ignoreRule),
		% try applying the ignore rule
		ignore = eval( strrep( ignoreRule, gSFignoreRuleChar, ['[' rg_num2str14(value ) ']'] ) );
	end
	if ~ignore
	  	stringTable{tableNum}{coords(1)+1}{coords(2)+1} = entry;
	else
		SFCellEmpty( coords(1)+1, coords(2)+1 ) = 1;		
	end
end
if hiddenContent == 0
	newSpaceLeft = spaceLeft;
	return;
end
clear global SFCellEmpty;


% stringTable now contains what we need for filling the two tables

% ---------------------------------------------------------------------------
% the following code is legacy since print book does not support
% html anymore (Report Generator does this much better)
% so, comment it out, but leave in the file:
%
%if html
%%
%%   Generate HTML Tables here
%%
	
%% first thing, of course, is printing a label
%myLabel = sf( 'get', id, '.rgTag' );
%fprintf( fid, ['<a NAME = ' myLabel ' > </a>\n']);
%fprintf( fid, '\n <table BORDER=3 width = "100%%" align = right> \n');
%fprintf( fid, ...
% 		['<tr align = right> <td> ' myLabel '</td> </tr>\n </table> \n<br><br><br>\n'] );

%for i = 1:length(stringTable)  %should be i = 1:2 for original version only
%   table = stringTable{i};
%  	fprintf( fid, '\n<TABLE  BORDER = 1 width = "95%%" > \n' );
%   % determine the dimensions of the table
%   maxY = 0;
%   maxX = length(table);
%   for j = 1:maxX
%      if length( table{j} ) > maxY 
%         maxY = length( table{j} );
%      end
%   end
%   for y = 1:maxY
%      fprintf( fid, '<TR ALIGN = LEFT > \n' );
%      for x = 1:maxX
%         % fill in the row
%			%
%			% set the width attribute for the first row only
%			widthAttribute = '';
%			if y == 1
%				percent = floor( 100 / maxX );
%				widthAttribute = [' WIDTH = ' rg_num2str( percent ) '%%'];
%			end
	
%         fprintf( fid, ['<TD ' widthAttribute ' >'] );
%         % print the entry
%         entry = eval( 'table{x}{y}', ' '''' ' );
%         if ~isempty( entry )
%            s = [ entry.printName ': ' ];
%            for j = 1:length( entry.printValue )
%               refPrint = entry.printValue{j}{1};
%               ref = entry.printValue{j}{2};
%               if ~isempty( ref )
%                  refVal = sf( 'get', ref, '.rgTag' );
%               	s = [s '<A HREF = "' gSFoutFileName '#' refVal '">' refPrint '</A>, '];
%					else
%                  s = [s refPrint ', '];  
%               end
%            end
%            % if length of entry.printValue > 0 then remove two last chars (a comma and a space)
%            if length( entry.printValue ) > 0
%               s( length(s) ) = [];
%               s( length(s) ) = [];
%            end
%            fprintf( fid, '%s', s );
%         end
%         fprintf( fid, '</TD>\n' );
%      end
%      fprintf( fid, '</TR>\n' );
%   end
%   fprintf( fid, '\n</TABLE> ');
%   fprintf( fid, '\n<BR> \n' );
%   if i == 1 & imagePresent == 1 %  insert the image after the first table (if there is one)
%      global  gSFimageDirName;
%      imageFileName = strcat( gSFimageDirName, filesep, ['obj' rg_num2str(id) '.' imageFormat]);
%      rg_nice_shot( id, imageFileName, imageCoords, imageFormat);
%      %fprintf( fid, '%s\n', ['<IMG SRC = ' gSFimageDirName filesep 'screenshot.jpg >'] );
%      fprintf( fid, '%s\n', ['<IMG SRC = "file:///' imageFileName '" WIDTH = 95%%>'] );

%      %fprintf( fid, ['Image size = [' rg_num2str(imageCoords) '], format is ' imageFormat ] );
%   end
%end
%fprintf( fid, '\n<BR><BR><BR><BR><BR><BR> \n' );
%end  % if html

if ps | pdf
%
% Generate ps here (or pdf)  here we generate primitives, not code, so it doesn't matter
%
	global gSFdrawInfo;
	if imagePresent
		scale = gSFdrawInfo.data{gSFdrawInfo.map(id)}{2};
		viewRec = gSFdrawInfo.data{gSFdrawInfo.map(id)}{3};
		imageCoords = [viewRec(3) viewRec(4)] * scale;
		imHeight = imageCoords(2);
	end

	widthRatio = 0.65;  % = charWidth / charHeight.

	tableRows = zeros( 1, length( stringTable ) );
	splitTable = {};
	maxCellHeight = [];
	totalRows = 0;
	for i = 1:length(stringTable)  %should be i = 1:2 for original version only
		table = stringTable{i};

	 	% determine the dimensions of the table
   	maxY = 0;
   	maxX = length(table);
		if maxX > 0
			cellIndent(i, 1:maxX) = 0;  
		end
	
		% this array contains the distances of the columns from 
		% the left margin (in percent of pagewidth)
  		for j = 1:maxX
      	if length( table{j} ) > maxY 
         	maxY = length( table{j} );
      	end 
   	end % for
		
		for y = 1:maxY
			maxCellHeight(i,y) = 0;
			for x = 1:maxX
				entry = eval( 'table{x}{y}', ' '''' ' );

            if ~isempty( entry )
            	% check how many lines the entry would take
            	[lines entry] = layOut( entry, fontSize * widthRatio, ...
               		(gSFpageWidth - leftMargin - rightMargin ) * entry.widthPercent / 100 );
               maxCellHeight(i,y) = max( maxCellHeight(i,y), lines );
					if x ~= maxX
 						cellIndent(i,x+1) = max( cellIndent(i,x+1),entry.widthPercent+cellIndent(i,x) ); 
					end
           end
            splitTable{i}{x}{y} = entry;
			end
			tableRows(i) = tableRows(i) + maxCellHeight(i,y);
		end
		totalRows = totalRows + tableRows(i);
	end % for

	prevDefStruct = gSFlayoutTable{ whoami( prevId ) + 1 };
	if prevDefStruct.putInTable == 1 & whoami( id ) ~= whoami( prevId )
		% add object distance space because that was not done previously.
		spaceLeft = spaceLeft - objectDistance;
	end
	if (defStruct.sharePage == 0) | (prevDefStruct.sharePage == 0)
		% new page
		new_page( fid, prevId, ...
			curPageNum,...
			fontSize, widthRatio, bottomMargin - fontSize*2, gSFpageWidth-rightMargin);
		curPageNum = curPageNum + 1;
		spaceLeft = pageHeight-topMargin;
		curColumn = 1;
		[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
	end
 

	% OK, now let's find out the height of the whole thing
	
	height=0;
	if imagePresent
		height = (totalRows)*(fontSize+lineSpace)+imHeight; %+objectDistance * (length(stringTable)-1);
	else
		height = (totalRows)*(fontSize+lineSpace); %+objectDistance/2 * (length(stringTable)-1);
		if defStruct.putInTable
			height = height - objectDistance/2; % we have list, don't waste space
		end
	end
	
	% See if it fits on what's left on the page
	if (height > spaceLeft - bottomMargin) & (spaceLeft ~= pageHeight-topMargin ) ...
				& (defStruct.avoidTwoPageObj == 1 ) ...
				| defStruct.spaceLeftToNewPage > spaceLeft - bottomMargin
		% there was something on the page, and our new object doesn't fit
		% so start new page
		if curColumn == length( columnVec )
			new_page( fid, prevId, ...
				curPageNum,...
				fontSize, widthRatio, bottomMargin - fontSize*2, gSFpageWidth-rightMargin);
			curPageNum = curPageNum + 1;	
			curColumn = 1;	
		else
			curColumn = curColumn + 1;
		end
		[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
		spaceLeft = pageHeight-topMargin;
	end
   
   % Here is the place where we start printing the object, so this
   % page number will go to the table of contents or whatever reference   
   
   % modify the tag of the object being printed to reflect the page number
   global gSFtContents;
   gSFtContents(id) = curPageNum;

	%register sf object for the pdf file generation purposes
	gSFdocument{ length( gSFdocument ) + 1 } = {'id', id};

      
	% Rule: can split into the second page anything except the image.
	for i = 1:length(stringTable)  %should be i = 1:2 for original version only
		table = stringTable{i};
	 	% determine the dimensions of the table
   	maxY = 0;
   	maxX = length(table);
   	for j = 1:maxX
      	if length( table{j} ) > maxY 
         	maxY = length( table{j} );
      	end 
   	end % for
		
		for y = 1:maxY
			for j = 1:maxCellHeight(i,y)
				lineUsed = 0;
				for x = 1:maxX
					if spaceLeft < fontSize + lineSpace + bottomMargin
						if curColumn == length( columnVec )
							new_page( fid, id, ...
								curPageNum,... 
								fontSize, widthRatio, bottomMargin - fontSize*2, ...
								gSFpageWidth-rightMargin);
							curPageNum = curPageNum + 1;
							curColumn = 1;
						else
							curColumn = curColumn + 1;
						end
						[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
						spaceLeft = pageHeight-topMargin;
					end
               entry = eval( 'splitTable{i}{x}{y}', ' '''' ');
               if ~isempty(entry)
                  cellW = (gSFpageWidth-leftMargin-rightMargin)*entry.widthPercent/100;
               	pos = [ (gSFpageWidth-leftMargin-rightMargin)*cellIndent(i,x)/100 + leftMargin,
									spaceLeft ];
               	if j == 1
							% draw the cell header only for not putInTable types, for the first
							% object of putInTable type, and for the first object on a page
							if ((entry.putInTable ~= 1) | (type ~= whoami( prevId )) | ... 
											(spaceLeft == pageHeight-topMargin)) & ...
								~isempty(entry.printName )
                 			% here 'N' in the tag area means that this string is the field name.
                 			gSFdocument{length(gSFdocument)+1} = { {entry.printName, 'N'}, pos, entry.boldVal, entry.underline, cellW, 0 };
								lineUsed = 1;
							end
                  else
                  	columns = entry.numColumns;     
                     for jj = 1:columns  
                        pv = eval( 'entry.printValue{(j-2)*columns + jj}', ' '''' ');
                        if (~isempty( pv ) & ~isempty( pv{1} )) | entry.underline ~= 0
                           xc = pos(1) + ceil( cellW / columns ) * (jj - 1);
                           yc = pos(2);
									justifyOffset = 0;
 			 						if entry.rightJustify & ~isempty( pv ) & ~isempty( pv{1} )
										if columns == 1
											justifyOffset = cellW - (length( pv{1} ) + (length(pv{2})>0) * 1.5 ) * fontSize * 0.65;
										end
									end
                      		gSFdocument{length(gSFdocument)+1} = {pv, [xc, yc], entry.boldVal, entry.underline, cellW, justifyOffset};
									lineUsed = 1;
                        end
                     end    
                  end
               end 	% if
				end 	% for x = 1:maxX
				if lineUsed
					spaceLeft = spaceLeft - fontSize - lineSpace;
				end
			end 	%	for j = 1:maxCellHeight(i,y)
			spaceLeft = spaceLeft - lineSpace;
		end 	% for y = 1:maxY
		numberOfChildren = length(eval( 'sf( ''ObjectsIn'', id )', '[]' ));
		if i == 1 & imagePresent & numberOfChildren >= defStruct.picMinChildren
		spaceLeft = spaceLeft - objectDistance / 2;	
			% see if the image fits now
			if spaceLeft < imHeight + bottomMargin
				if curColumn == length( columnVec )
					new_page( fid, id, ...
						curPageNum,...
						fontSize,widthRatio,bottomMargin-fontSize*2,gSFpageWidth-rightMargin);
					curPageNum = curPageNum + 1;
					curColumn = 1;
				else
					curColumn = curColumn + 1;
				end
				[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
				spaceLeft = pageHeight-topMargin;
			end
			%
			% code to draw the image
         %
         gSFdocument{length(gSFdocument) +1} = {'image', id, imageCoords, leftMargin, spaceLeft};
         
         %fprintf( fid, [rg_num2str(leftMargin) ' ' rg_num2str(spaceLeft-imageCoords(2)) ' '...
			%		 rg_num2str(imageCoords(1)) ' ' rg_num2str(imageCoords(2)) ' rectstroke\n' ] );
			%print_image( fid, id, imageCoords, leftMargin, spaceLeft );
			spaceLeft = spaceLeft - imHeight;
			spaceLeft = spaceLeft - objectDistance / 2;
 			if spaceLeft < fontSize + bottomMargin
				if curColumn == length( columnVec )
					new_page( fid, id, ...
						curPageNum,...
						fontSize,widthRatio,bottomMargin-fontSize*2,gSFpageWidth-rightMargin);
					curPageNum = curPageNum + 1;
					curColumn = 1;
				else
					curColumn = curColumn + 1
				end
				[gSFpageWidth, leftMargin] = nextColumnUpdate( leftMargin, rightMargin, realPageWidth, columnVec, curColumn );
				spaceLeft = pageHeight-topMargin;
			end
        gSFdocument{length(gSFdocument) +1} = { 'ref', id, leftMargin, spaceLeft};
			spaceLeft = spaceLeft - lineSpace - fontSize;
		end
	end % for
	
	% leave space between objects unless they are in a table
	if defStruct.putInTable ~= 1
		newSpaceLeft = spaceLeft - objectDistance;
	else
		newSpaceLeft = spaceLeft;
	end
		
end % if ps

function im_size = generate_image_primitives( fid, gSFreportList, fileFormat )
	% the function  writes all the procedures to draw every graphic
	% primitive into the file.
	% it also creates global structure gSFdrawInfo that contains the
	% minimal font size (in Stateflow coordinates) used in rendering
	% an object.  This information may be used, for example, in
	% determining readability of text.

	pdf = 0; ps = 0;
	if strcmp( fileFormat, 'ps' );
		ps = 1;
	end
	if strcmp( fileFormat, 'pdf' );
		pdf = 1;
	end

	global gSFdrawInfo;
	global gSFlayoutTable;
	global gSFlegibleSize;
	%
	% first get the information how to draw the picture from nice_shot.
	%
	gSFdrawInfo.data = [];
	gSFdrawInfo.legibleIn = [];
	gSFdrawInfo.numLegibleKids = zeros( 1, length( gSFreportList ) );
	gSFdrawInfo.context = zeros( 1, length( gSFreportList ) );
	gSFdrawInfo.map = sparse( 100000000, 1 );
	
	nice_shot( 'initialize' );
	global dData;
   nice_shot( gSFreportList, 'get_image_primitives', 'show_progress' );
   global gSFCancelFlag;
   if gSFCancelFlag
      return;
   end
      
	% now dData contains all the info about drawing all objects
	% save it into a file and maintain a structure containing the size info of objects
	%
	pics = dData.data;
	for i = 1:length( pics )  % go through all the objects' descriptions
     pic = pics{i};
	  % write the header for the definition
	  id = pic{4};
	  if ps
		  fprintf( fid, ['/o' rg_num2str( id ) '{\n' ] ); 
	  end
	  fontSize = Inf;
	  stream = '';
     for i = 1:length( pic{1} ) % go through all entries in an object's description
		cmd = pic{1}{i};
		type = cmd{1};
	 	switch type
			case 'text',
				% the x and y coordinates specify the upper left corner of the text
				x = cmd{2}(1);
			 	t = cmd{4};
				fs = cmd{3};	
				str = {};
				maxWidth = 0;
				while ~isempty(t)
					[t1, t] = strtok( t, char(10) );
					str{length(str)+1} = t1;
					maxWidth = max(maxWidth, str_width( t1, 0.65, 1 ) );
				end
				if fs < 0 % no font size given. Set it.
					% determine the font size such that the text fits into the bounding rect
					w = cmd{2}(3);
					h = cmd{2}(4);
					fsw = w/maxWidth;
					fsh = h / length(str) / 1.2;
					fs = min( fsh, fsw );
				end
				y = -cmd{2}(2) - fs / 1.5;		% - (y pos of text + font size )
				if ps
					fprintf( fid,'%s\n',['cur1ptfont ' rg_num2str(fs) ' scalefont setfont' ] );
					for j = 1:length(str)
						fprintf( fid, '%s\n', [rg_num2str(x) ' ' rg_num2str(y-fs*1.2*(j-1)) ' moveto'] );
						fprintf( fid,'%s\n',['(' ps_string(str{j}) ') show stroke ' ] );
            	end
				end
				fontSize = min( fontSize, fs );
				
				if pdf
					stream = [ stream pdf_draw_text( [ x, y ], fs, str ) ];
				end				
			% 'tag' is not used anymore
         %case 'tag'
         %   pos = cmd{2};
         %   x = rg_num2str( pos(1) );
         %   y = rg_num2str( -pos(2) );
         %   fontSize = cmd{3};
         %   t = ps_string( cmd{4} );
			%	if ps
	      %      fprintf( fid, '%s\n', ['0.7 setgray ' x ' ' y ' moveto (' t ') show 0 setgray'] );
			%	end

			case 'rrect',
				rect = cmd{2};
				x = rect(1);
				y = -rect(2) - rect(4);
				w = rect(3);
				h = rect(4);
				%c = min( w, h ) * 0.1;
				c = 0.18;
				
				cx = 0.5*(max(w,h) *  c);
 				cx = 0.75*min(cx, min(w,h)/(3-c));
				c = cx;

				dash = cmd{3};
				if ps
               if dash ~= 0
                  fprintf( fid, '%s\n', [ 'stroke [' rg_num2str( dash ) '] 0 setdash' ] );
               end 
               fprintf( fid, '%s\n', [ rg_num2str( x ) ' ' rg_num2str( y ) ' ' rg_num2str( w ) ' ' ...
                     rg_num2str( h ) ' ' rg_num2str( c ) ' rrect' ] ); 
               if dash ~= 0
                  fprintf( fid, '%s\n', 'stroke [] 0 setdash' );
               end
            end
				if pdf
					if dash ~= 0
						stream = [stream, 'S [' rg_num2str( dash ) '] 0 d ' ];
					end
					%draw the rrect
					% define the string points:
					pxpc = rg_num2str(x+c); % Point X Plus C
					py = rg_num2str(y);
					px = rg_num2str(x);
					pxpwmc = rg_num2str(x+w-c);
					pyph = rg_num2str(y+h);
					pypc = rg_num2str(y+c);
					pyphmc = rg_num2str(y+h-c);
					pxpw = rg_num2str(x+w);

					
					stream = [ stream, ...
						pxpc ' ' py ' m '  pxpwmc ' ' py ' l ' ...
						pxpw ' ' py ' ' pxpw ' ' pypc ' y ' pxpw ' ' pyphmc ' l ' ...
						pxpw ' ' pyph ' ' pxpwmc ' ' pyph ' y ' pxpc ' ' pyph ' l ' ...
						px ' ' pyph ' ' px ' ' pyphmc ' y ' px ' ' pypc ' l ' ...
						px ' ' py ' ' pxpc ' ' py ' y S ' ...
					];
					if dash ~= 0
						stream = [stream, ' [] 0 d ' ];
					end
					
				end % if pdf

			case 'srect',
				rect = cmd{2};
				x = rect(1);
				y = -rect(2) - rect(4);
				w = rect(3);
				h = rect(4);
				if ps
					fprintf( fid, '%s\n', [ rg_num2str( x ) ' ' rg_num2str( y ) ' ' rg_num2str( w ) ' ' ...
						rg_num2str( h ) ' rectstroke' ] ); 
				end
			
				if pdf

					%draw the rrect
					% define the string points:
					py = rg_num2str(y);
					px = rg_num2str(x);
					pyph = rg_num2str(y+h);
					pxpw = rg_num2str(x+w);

					stream = [ stream, ...
						px ' ' py ' m '  pxpw ' ' py ' l ' ...
						pxpw ' ' pyph ' l ' px ' ' pyph ' l ' ...
						px ' ' py ' l S ' ...
					];
					
				end % if pdf


				

			case 'circ',
				c = cmd{2}; rad = cmd{3};
				if ps
               fprintf( fid, '%s\n', [rg_num2str( c(1) + rad ) ' ' rg_num2str(-c(2)) ...
                     ' moveto ' rg_num2str( c(1) ) ' ' rg_num2str( -c(2) ) ' ' ...
                     rg_num2str( rad ) ' 0 360 arc' ] );
            end

				if pdf
					stream = [ stream, ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2) ) ' m ' ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2)+rad ) ' ' ...
						  rg_num2str( c(1) ), ' ', rg_num2str( -c(2)+rad ) ' y ' ...
						rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2)+rad ) ' ' ...
						  rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2) ) ' y ' ...
						rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2)-rad ) ' ' ...
						  rg_num2str( c(1) ), ' ', rg_num2str( -c(2)-rad ) ' y ' ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2)-rad ) ' ' ...
						  rg_num2str( c(1) -rad ), ' ', rg_num2str( -c(2) ) ' y S ' ...	
					];					
				end


			case 'fcirc',
				c = cmd{2}; rad = cmd{3};
				if ps
					fprintf( fid, '%s\n', ['stroke ' rg_num2str( c(1) + rad ) ' ' rg_num2str(-c(2)) ...
						' moveto ' rg_num2str( c(1) ) ' ' rg_num2str( -c(2) ) ' ' ...
						rg_num2str( rad ) ' 0 360 arc fill' ] );
				end

				if pdf
					stream = [ stream, ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2) ) ' m ' ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2)+rad ) ' ' ...
						  rg_num2str( c(1) ), ' ', rg_num2str( -c(2)+rad ) ' y ' ...
						rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2)+rad ) ' ' ...
						  rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2) ) ' y ' ...
						rg_num2str( c(1) + rad ), ' ', rg_num2str( -c(2)-rad ) ' ' ...
						  rg_num2str( c(1) ), ' ', rg_num2str( -c(2)-rad ) ' y ' ...
						rg_num2str( c(1) - rad ), ' ', rg_num2str( -c(2)-rad ) ' ' ...
						  rg_num2str( c(1) -rad ), ' ', rg_num2str( -c(2) ) ' y b ' ...	
					];					
				end


			case 'spline',
				dash = cmd{3};
				vec = cmd{2};
				
				if ps				
               if dash ~= 0
                  fprintf( fid, '%s\n', [ 'stroke [' rg_num2str( dash ) '] 0 setdash' ] );
               end
              
               for j = 1:length(vec)
                  fprintf( fid, '%s', [rg_num2str( vec(j) ) ' '] );
               end
               fprintf( fid, 'trans\n' );
               
               if dash ~= 0
                  fprintf( fid, '%s\n', 'stroke [] 0 setdash' );
               end
            end

				if pdf %write this and go home sleep
					% vec(j) contains coefficients
					%   x(t) =  c(1,1)t^4 + c(2,1)t^3 + c(3,1)t^2 + c(4,1)t + c(5,1)\n' ...
					%   y(t) =  c(1,2)t^4 + c(2,2)t^3 + c(3,2)t^2 + c(4,2)t + c(5,2)\n' ...
					if dash ~= 0
						stream = [stream, 'S [' rg_num2str( dash ) '] 0 d ' ];
					end

					step = 0.05;
					stream = [ stream, ' ' rg_num2str( vec(5) ) ' ' rg_num2str( -vec(10) ) ' m ' ];
					for t = 0:step:1
						nextX = vec(1)*t^4+vec(2)*t^3+vec(3)*t*t+vec(4)*t+vec(5);
						nextY = vec(6)*t^4+vec(7)*t^3+vec(8)*t*t+vec(9)*t+vec(10);
						stream = [ stream rg_num2str( nextX ) ' ' rg_num2str( -nextY ) ' l ' ];
					end
					% draw the arrow
					stream = [ stream ...
								rg_num2str( vec(11) ) ' ' rg_num2str( -vec(12) ) ' m ' ...
								rg_num2str( vec(13) ) ' ' rg_num2str( -vec(14) ) ' l ' ...
								rg_num2str( vec(15) ) ' ' rg_num2str( -vec(16) ) ' l ' ...
								rg_num2str( vec(11) ) ' ' rg_num2str( -vec(12) ) ' l ' ...
								'S ' ];
					if dash ~= 0
						stream = [stream, ' [] 0 d ' ];
					end					
				end

			otherwise,
				error( [ 'Unknown draw command: ' cmd ] );
      end % switch
	  end % for go through all entries in an object's description
	  if ps
	 	  fprintf( fid, '} def\n' );
	  end
	  
	  if pdf  %& ~isempty( stream )
			% the stream is ready. write it to the file 
			%strId = write_pdf_object( fid, stream, 'st', 0 );
			%now create the XObject containing the stream to this stream
			pdf_rec_obj( id, stream );
			%xobj = ['/Type /XObject /Subtype /Form ' ...
			%		'/Name /SF' rg_num2str( id ) ' /FormType 1 ' ...
			%		'/BBox [ ' rg_num2str( pic{3}(1) ) ' ' rg_num2str( -pic{3}(2)- pic{3}(4)  )  ' ' ...
			%		rg_num2str( pic{3}(1)+pic{3}(3) ) ' ' rg_num2str( -pic{3}(2) ) ...  
			%		' ] /Matrix [1 0 0 1 0 0] /Resources 4 0 R ' ...
			%];
			%xobjId = write_pdf_object( fid, {xobj, stream}, 'xo', id );
	  end
	  % put the fontSize and the list of objects I depend on into the gSFdrawInfo
	  

	  % define the scale factor for the image of this object depending on
	  % the font sizes
	  type = whoami( id );
	  defStruct = gSFlayoutTable{ type + 1 };
	  imageDescription = defStruct.image;
	  dynamicSize = defStruct.dynamicSize;
	  viewRec = pic{3}; w = 0; h = 0; scale = 0;
	  newFS = fontSize;
	  maxScale = 0;
	  if ~isempty( imageDescription )
	  		w = imageDescription{1};
	  		h = imageDescription{2};
			xScale = w / viewRec(3);
			yScale = h / viewRec(4);
			maxScale = min( xScale, yScale );
			newFS  = fontSize * maxScale;
			if newFS > gSFlegibleSize & newFS ~= Inf & dynamicSize == 1
				scale = maxScale * gSFlegibleSize / newFS;
			else
				newFS = fontSize;
				scale = maxScale;
			end
	  end
	  pointRec = pic{5};
	  parent = pic{6};
	  gSFdrawInfo.data{ length( gSFdrawInfo.data ) + 1 } = ...
					{[id pic{2}], scale, viewRec, pointRec, parent, newFS, fontSize, maxScale };
	  gSFdrawInfo.legibleIn(length(gSFdrawInfo.legibleIn)+1) = id;
	  gSFdrawInfo.map(id) = length( gSFdrawInfo.data );
	end % for go through all the objects' descriptions

	imScale = zeros(1, length( gSFdrawInfo.data ) );
	SFfSize = imScale;
	
	for i = 1:length(gSFdrawInfo.data)
		child = gSFdrawInfo.data{i};
		SFfSize(i) = child{7};
		imScale(i) = child{2};
	end
	for i = 1:length(gSFdrawInfo.data)
		obj = gSFdrawInfo.data{i};
		children = obj{1};
		id = children(1);
		myType = sf( 'get', id, '.isa' );
		children = intersect( children, sf( 'ObjectsIn', id ) );
		if ~isempty(children)  % scale is not max => potentially makes sense to increase to draw children legibly
			childrenFS = SFfSize(gSFdrawInfo.map(children))*imScale(i);
			minFS = min( childrenFS );
			if minFS < gSFlegibleSize
				moreScale = min(gSFlegibleSize / minFS);
				scale = min( obj{8}, imScale(i) * moreScale );
				imScale(i) = scale;
				gSFdrawInfo.data{i}{2} = scale;
			end
			% let's see who of the children became legible at this object's picture
			legibleNow = children(SFfSize(gSFdrawInfo.map(children))*imScale(i) >= gSFlegibleSize - 0.05);
			prevLegibleParents = gSFdrawInfo.legibleIn( gSFdrawInfo.map( legibleNow  ) );
			kidsToFix = intersect( children, prevLegibleParents );
			fixedKids = intersect( legibleNow, kidsToFix );
			% set their legibleIn value
			gSFdrawInfo.legibleIn( gSFdrawInfo.map( fixedKids  ) ) = id;
			%remember how many kids I make legible
			gSFdrawInfo.numLegibleKids( i ) = length( fixedKids );
			gSFdrawInfo.legibleKids{ i } = fixedKids;
		else
			gSFdrawInfo.legibleKids{ i } = [];
		end
	end %for i = 1:length(gSFdrawInfo.data)
	
	% now we can free the dData variable
	clear global dData;



function stream = print_image( fid, id, imageCoords, leftMargin, spaceLeft, rightLimit, gSFreportList, format )
	global gSFlayoutTable;
	global gSFpagesOfTContents;
	global gSFtContents;
	global gSFdrawInfo;
	
	ps = 0;
	pdf = 0;
	stream = [];
	if strcmp( format, 'ps' )
		ps = 1;
	end
	if strcmp( format, 'pdf' )
		pdf = 1;
	end

	% imageCoords that we receive here are already dynamically sized (if user chose it)

	myDrawInfo = gSFdrawInfo.data{ gSFdrawInfo.map( id ) };
	%
	% first get the information how to draw the picture from nice_shot.
	%
   pointers = {};
	scale = myDrawInfo{2};
	viewRec = myDrawInfo{3};
	lineWidth = rg_num2str( 0.2/scale );
	% center the image
	picLeftSideCoord = ( rightLimit + leftMargin - imageCoords(1) ) / 2;
	w = imageCoords(1);
	h = imageCoords(2);

	% draw a border if necessary
	type = whoami( id );
	defStruct = gSFlayoutTable{ type + 1 };
	if defStruct.border == 1
		if ps,
         fprintf( fid, '%s\n', [rg_num2str(picLeftSideCoord) ' ' rg_num2str( spaceLeft-imageCoords(2) ) ...
               ' ' rg_num2str( imageCoords(1) ) ' ' rg_num2str( imageCoords(2) ) ...
               ' rect'] );
         fprintf( fid, '%s\n', [rg_num2str(picLeftSideCoord-1) ' ' rg_num2str( spaceLeft-imageCoords(2)-1 ) ...
               ' ' rg_num2str( imageCoords(1)+2 ) ' ' rg_num2str( imageCoords(2)+2 ) ...
               ' rect'] );
		end
		if pdf
			stream = [ stream ...
				rg_num2str(picLeftSideCoord) ' ' rg_num2str( spaceLeft-imageCoords(2) ) ...
           	' ' rg_num2str( imageCoords(1) ) ' ' rg_num2str( imageCoords(2) ) ' re ' ...
         	rg_num2str(picLeftSideCoord-1) ' ' rg_num2str( spaceLeft-imageCoords(2)-1 ) ...
            ' ' rg_num2str( imageCoords(1)+2 ) ' ' rg_num2str( imageCoords(2)+2 ) ' re ' ... 
			];
		end

   end



	% save the graphic environment and
	% set the clipping path
   dependOn = myDrawInfo{1};
	if ps
      fprintf( fid, 'gsave\n' );
      fprintf( fid, '%s\n', [rg_num2str(picLeftSideCoord) ' ' rg_num2str( spaceLeft-imageCoords(2) ) ...
            ' ' rg_num2str( imageCoords(1) ) ' ' rg_num2str( imageCoords(2) ) ...
            ' rectclip'] );
      
      % translate to the location on page
      fprintf( fid, '%s\n', [ rg_num2str( picLeftSideCoord ) ' ' ...
            rg_num2str( (spaceLeft ) ) ' translate' ] );
      
      %scale
      fprintf( fid, '%s\n', [ rg_num2str( scale ) ' ' rg_num2str( scale ) ' scale' ] );
      
      % translate from SF axes to (0, 0)
      fprintf( fid, '%s\n', [ rg_num2str( -viewRec(1) ) ' '...
            rg_num2str( (viewRec(2)) ) ' translate' ] );

      % draw the first object bold
      fprintf( fid, '%s\n', [ rg_num2str( 1 / scale ) ' setlinewidth bfn setfont' ] );
      fprintf( fid, ['o' rg_num2str( dependOn(1) ) ' stroke ' ] );
      fprintf( fid, [lineWidth ' setlinewidth fn setfont\n'] );
   end      

	if pdf
		% calculate the transformation matrix
		%
		%   s         0      0
		%   0         s      0
		% x1*s+x2   y1*s+y2  1
		%
		%tma = scale;
		%tmb = 0;
		%tmc = 0;
		%tmd = scale;
		%tme = picLeftSideCoord * scale - viewRec(1);
		%tmf = spaceLeft * scale + viewRec(2);
		
		tm1 = [ 1 0 0; 0 1 0; picLeftSideCoord spaceLeft 1 ];
		tm2 = [ scale 0 0; 0 scale 0; 0 0 1 ];
		tm3 = [ 1 0 0; 0 1 0; -viewRec(1) viewRec(2) 1 ];

		tm = tm3 * tm2 * tm1 ;
		%tm = [ 1 0 0; 0 1 0; 0 0 1];
		cmstr = [ rg_num2str( tm(1,1) ) ' ' rg_num2str( tm(1,2)) ' ' rg_num2str( tm(2,1) ) ' ' rg_num2str( tm(2,2) ) ' ' ...
					rg_num2str( tm(3,1) ) ' ' rg_num2str( tm(3,2) ) ];

		stream = [ stream ...
					' S q ' rg_num2str(picLeftSideCoord) ' ' rg_num2str( spaceLeft-imageCoords(2) ) ...
	            ' ' rg_num2str( imageCoords(1) ) ' ' rg_num2str( imageCoords(2) ) ' re W S 0 w ' ... % set the clipping path
					cmstr ' cm ' ...
	...				rg_num2str( 1 / scale ) ' w 0.5 0.1 0.1 rg 0.5 0.1 0.1 RG /SF' rg_num2str( dependOn(1) ) ' Do S 0 g 0 G ' lineWidth ' w '... 
					rg_num2str( 1 / scale ) ' w 0.5 0.1 0.1 rg 0.5 0.1 0.1 RG ' pdf_get_obj( dependOn(1) ) ' S 0 g 0 G ' lineWidth ' w '...
					];
					
	end % if pdf

	
	for i = 2:length(dependOn)
		if ps
			fprintf( fid, ['fn setfont o' rg_num2str( dependOn(i) ) ' ' ] );
		end
		if pdf
			%stream = [ stream ' /SF' rg_num2str( dependOn(i) ) ' Do' ];
			stream = [ stream pdf_get_obj( dependOn(i) ) ' ' ];
			% add the link if necessary
			if ~strcmp( 'transition', num2type( whoami( dependOn(i) ) ) ) ... %not a transition	
						& ismember( dependOn(i), gSFreportList )
         	rect = gSFdrawInfo.data{ gSFdrawInfo.map( dependOn(i) ) };
         	rect = rect{3}; % that's the viewRect (xywh)
         	p1 = [ rect(1), -rect(2)-rect(4),1]; p1p = p1*tm; p1p = p1p(1:2);
         	p2 = [ rect(3)+rect(1), -rect(2),1];p2p = p2*tm; p2p = p2p(1:2);
				% do not allow the active area to go beyond the view frame
				if p1p(1) < picLeftSideCoord, p1p(1) = picLeftSideCoord; end
				if p1p(2) < spaceLeft-imageCoords(2), p1p(2) = spaceLeft-imageCoords(2); end
				if p2p(1) > picLeftSideCoord+imageCoords(1), p2p(1) = picLeftSideCoord+imageCoords(1); end
				if p2p(2) > spaceLeft, p2p(2) = spaceLeft; end

         	pdf_add_link( fid, [p1p,p2p], dependOn(i) );
      	end
			
		end
		% while we are inside of the loop, calculate the pointer information
		%
		if gSFlayoutTable{ whoami( dependOn(i) ) + 1 }.pointToIt == 1,
			parent = gSFdrawInfo.data{gSFdrawInfo.map( dependOn(i) )}{5};
			while isempty( find( gSFreportList == parent ) )
				parent = gSFdrawInfo.data{gSFdrawInfo.map( parent )}{5};
			end
			gSFdrawInfo.context( gSFdrawInfo.map( dependOn(i) ) ) = parent;
			myFixedKids = gSFdrawInfo.legibleKids{ gSFdrawInfo.map( id ) };
			if ( ~isempty( find( gSFreportList == dependOn(i) ) )) & ...
				( parent ==  id | ...
					(length( myFixedKids ) > 0 & ~isempty( find( myFixedKids == dependOn(i) ) ) ) ...
				)
				pointRec = gSFdrawInfo.data{gSFdrawInfo.map( dependOn(i) )}{4};
				pointers{ length( pointers ) + 1 } = { dependOn(i), pointRec };
				gSFdrawInfo.context( gSFdrawInfo.map( dependOn(i) ) ) = parent;
			end
		end
	end
		

	if ps	
		fprintf( fid, '\nstroke \n grestore\n 0 setlinewidth\n' );
	end
	if pdf
		stream = [ stream ' S Q ' ];
	end
	% we are now in the PS system of coordinates

	% now draw the pointers.

	% first, find out how many pointers we can have with this image size
	tagLength = 10;
	fontSize = 8;
	arrowHeadSize = 3;
	tagLengthPix = fontSize * 0.65 * ( tagLength + 2 );
	tagHeightPix = fontSize * 1.2;
	w = imageCoords(1);
	h = imageCoords(2);	
	
	numHorTags  = floor( w / tagLengthPix );
	numVertTags = floor( h / tagHeightPix );
	totalTags = 2 * ( numHorTags + numVertTags );
	ptrsToSkip = 0;
	if totalTags < length( pointers )
		% have to reduce the number of pointers
		warning( 'Too many objects to be pointed to. Dropping some of them.' );
		ptrsToSkip = length( pointers ) - totalTags;
	end
	% now we know that the number of requested pointers is less than or equal to
	% the number of available spaces
	
	if length( pointers ) > 0
		% calculate tag positions now, to save time later
		tagSpaceLeft = (w - numHorTags * tagLengthPix)/2;
		for tagNo = 1:numHorTags*2
			yTag = -floor( tagNo / (numHorTags+1) ) * (h+10) + spaceLeft + 5;
			xTag = picLeftSideCoord + ...
				tagLengthPix * ( mod( tagNo-1, numHorTags ) + 0.5 ) + tagSpaceLeft;
			labelPosYOffset = -floor( tagNo / (numHorTags+1) ) * fontSize*1.6 + fontSize*0.3;
			labelPos = [xTag - tagLengthPix * 0.3, yTag + labelPosYOffset];
			tagCoords{tagNo} = {[xTag, yTag], labelPos };
		end
		for tagNo = numHorTags*2+1:totalTags
			tagNo1 = tagNo - numHorTags * 2;
			xTag = ( 1 - floor( tagNo1 / (numVertTags+1) ) ) * (w+leftMargin*0.2) + picLeftSideCoord-leftMargin*0.1;
			yTag = spaceLeft - tagHeightPix * ( rem( tagNo1-1, numVertTags ) + 0.5 );
			if tagNo1 <= numVertTags  % on the right side of the picture
				labelPosX = xTag;
			else
				labelPosX = picLeftSideCoord - tagLength * fontSize * 0.65;
			end
			labelPos = [labelPosX yTag-fontSize/4];
			tagCoords{tagNo} = {[xTag, yTag], labelPos };
		end
		tags = zeros( 1, totalTags );
	end

	% define the sideOfTag array
	sideOfTag(1:numHorTags) = 1;
	sideOfTag(numHorTags+1:numHorTags*2) = 2;
	sideOfTag(numHorTags*2+1:numHorTags*2+numVertTags) = 3;
	sideOfTag(numHorTags*2+numVertTags+1:totalTags) = 4;

	for i = 1:length( pointers )
	 id = pointers{i}{1};
  	 % don't draw this pointer if there is not enough space for tags and 
	 % this is not a state
	 if ptrsToSkip > 0 & type2num( 'state' ) ~= whoami( id ) & i <= length(pointers)
		ptrsToSkip = ptrsToSkip - 1;
	 else
		% do	the pointer


		rect = pointers{i}{2};
		%rect(4) = -rect(4);
		%rect(2) = -rect(2);
		% first, convert rect to PS coordinate system 
		% translate from SF axes to (0, 0)
		rect(1) = rect(1) - viewRec(1);
		rect(2) = rect(2) - viewRec(2);
		%flip over the x-axis
		%rect(2) = -rect(2)-rect(4)+viewRec(4);
		rect(2) = -rect(2)-rect(4);
		%scale
		rect = rect * scale;
		rect(2) = rect(2) + h;
		% translate to the location on page
		rect(1) = rect(1) + picLeftSideCoord;
		rect(2) = rect(2) + spaceLeft-h;	

		% Now find the shortest distance between
	
		%[ tagNo, corner ] = shortest_distance( rect, tags, tagCoords...
		%		picleftSideCoord, spaceLeft-h, picLeftSideCoord+w, spaceLeft );
		leftX = picLeftSideCoord;
		bottomY = spaceLeft-h;
		rightX = picLeftSideCoord+w;
		topY = spaceLeft;

		distances = [topY - (rect(2)+rect(4)), rect(2) - bottomY, ...
						rightX - (rect(1)+rect(3)), rect(1) - leftX ];
		[sortedDistances, order] = sort( distances );
		notLookedAt = [];
		for i = 1:length(order) % must be 1:4
			side = order(i);
			switch side,		
			case 1,
				sideTags = 1:numHorTags;
			case 2,
				sideTags = numHorTags+1:numHorTags*2;
			case 3,
				sideTags = numHorTags*2+1:numHorTags*2+numVertTags;
			case 4	
				sideTags = numHorTags*2+numVertTags+1:totalTags;
			end
			% now find the tag position that is the closest to the rect
			sideTagsLength = length( sideTags );
			if side > 2
				bestPos = ( (topY - (rect(2)+rect(4)/2) )/(topY-bottomY) ) * sideTagsLength;
			else
				bestPos = ( (rect(1)+rect(3)/2-leftX )/(rightX-leftX) ) * sideTagsLength;
			end
			bestPos = floor( bestPos ) + 1;

			tagNo = 0;
			for j = 1:sideTagsLength
				% calculate the adjustment from the best possible position
				if mod( (j-1), 2 ) == 0
					adjustment = -( j-1 )/2;
				else
					adjustment = j/2;
				end
				curTag = bestPos + adjustment;
				if curTag < 1;
					notLookedAt = [ notLookedAt, sideTags( j:sideTagsLength ) ]; 
					break;
				end
				if curTag > sideTagsLength;
					notLookedAt = [ notLookedAt, sideTags( 1:sideTagsLength-j+1 ) ]; 
					break;
				end
				% if we are here then we can go further.
				if tags( sideTags( curTag ) ) == 0
					% all right, we have found a place
					tagNo = sideTags( curTag );
					break;
				end
			end
			if tagNo ~= 0, 
				break;
			end
		end
		if tagNo == 0
			% our goal is to find first non-occupied place in notLookedAt list
			% 
			notLookedAtVec = zeros(1,length(tags));
			notLookedAtVec(notLookedAt) = 1;
			ind = find(notLookedAtVec & (~tags));
			if length( ind ) < 1
            %error( 'error in laying out pointers' );
			else
			  tagNo = ind( 1 );
           side = sideOfTag( tagNo );  
        end
     end
     if tagNo ~= 0, tags( tagNo ) = 1; end
     
		
		% Now tagNo and side contain the information about where the arrow
		% comes to and from.
		
      % Draw the pointer from the tag to the the middle of the side
      if( tagNo ~= 0 )
         pageNo = gSFtContents( id ) + gSFpagesOfTContents;
         label = ps_string( [sf( 'get', id, '.rgTag' ) ' p' rg_num2str( pageNo ) ] );
         switch side,
         case 1,
            xSide = rect(1) + rect(3)/2;
            ySide = rect(2)+rect(4);			
         case 2,
            xSide = rect(1) + rect(3)/2;
            ySide = rect(2);			
         case 3,
            xSide = rect(1) + rect(3);
            ySide = rect(2) + rect(4) / 2;			
         case 4,
            xSide = rect(1);
            ySide = rect(2) + rect(4) / 2;			
         end
         labelPos = tagCoords{tagNo}{2};
         xTag = tagCoords{tagNo}{1}(1);
         if xTag < leftMargin + imageCoords(1) / 2
            % for the left side of the image, update the pointer origin
            xTag = labelPos(1) + (length( label ) ) * 0.65 * fontSize;
         end
         yTag = tagCoords{tagNo}{1}(2);
         % draw the arrowhead
         vec = [xTag-xSide, yTag-ySide];
         vec = vec / sqrt( vec * vec' ) * arrowHeadSize;
         perpVec = [ vec(2), -vec(1) ] / 3;
         basePoint = [xSide, ySide] + vec;
         point1 = basePoint - perpVec;
         point2 = basePoint + perpVec;
         if ps
            fprintf( fid, '%s\n',  [ 'stroke [2 5] 0 setdash '...
                  rg_num2str( xTag ) ' ' rg_num2str( yTag ) ' moveto ' ...
                  rg_num2str( basePoint(1) ) ' ' rg_num2str( basePoint(2) ) ...
                  ' lineto stroke [] 0 setdash ' ] );
            fprintf( fid, '%s\n', [rg_num2str( xSide ) ' ' rg_num2str( ySide ) ' moveto '... 
                  rg_num2str( point1(1) ) ' ' rg_num2str( point1(2) ) ' lineto ' ...
                  rg_num2str( point2(1) ) ' ' rg_num2str( point2(2) ) ' lineto ' ...
                  rg_num2str( xSide ) ' ' rg_num2str( ySide ) ' lineto ' ] );
            fprintf( fid, '%s\n', [ rg_num2str( labelPos(1) ) ' ' rg_num2str( labelPos(2) ) ' moveto ' ...
                  'fn ' rg_num2str( fontSize ) ' scalefont setfont (' label ') show ' ] );
         end % if ps
         if pdf
            stream = [ stream ' S [2 5] 0 d ' rg_num2str(xTag) ' ' rg_num2str(yTag) ' m ' ...
                  rg_num2str( basePoint(1)) ' ' rg_num2str( basePoint(2) ) ' l S [] 0 d '...
                  rg_num2str( xSide ) ' ' rg_num2str( ySide ) ' m '...
                  rg_num2str( point1(1) ) ' ' rg_num2str( point1(2) ) ' l ' ...
                  rg_num2str( point2(1) ) ' ' rg_num2str( point2(2) ) ' l ' ...
                  rg_num2str( xSide ) ' ' rg_num2str( ySide ) ' l ' ...
                  'S BT 0 0 0.5 rg /NFt ' rg_num2str( fontSize ) ' Tf ' ...
                  rg_num2str( labelPos(1) ) ' ' rg_num2str( labelPos(2) ) ' Td ' ...
                  '(' label ') Tj ET 0 g S ' ...
               ];
            pdf_add_link( fid, [labelPos(1)-fontSize/2, labelPos(2)-fontSize/3, ...
                  labelPos(1)+(length(label)+2)*fontSize*0.65, labelPos(2)+fontSize],id );
         end %if pdf				
      end % if tagNo ~= 0
    end % if ptrsToSkip > 0 & type2num( 'state' ) ~= whoami( id ) & i <= length(pointers)
 end % for i = 1:length(pointers)

%stream = ''; % remove this later


function new_page( fid, id, pageNo, fontSize, widthRatio, bottomPoint, rightPoint)
	string = rg_num2str( pageNo ); 
	global gSFpageWidth; global gSFpsRightMargin;
	rightPoint = gSFpageWidth - gSFpsRightMargin;  
	x = rightPoint - length( string ) * fontSize * widthRatio;
   y = bottomPoint;
   global gSFdocument;
   gSFdocument{length(gSFdocument) + 1} = { 'newPage', pageNo, [ x y ], id };
   
   
   % The function lays out the cell.
   % if the values are links, each entry may take up at most
   % one line. ig it is longer than the space allowed, it is
   % cut to the size.  if the number of values is 1, then the
   % whole value is displayed.
function [numLines, e] = layOut( e, charW, cellW )

if isempty(e)
   numLines = 0;
   return;
end

l = length( e.printValue );

if l == 0
   numLines = 1;
   return;
end
maxChars = floor( cellW / charW );

ref = e.printValue{1}{2};
if ~isempty( ref )
   % each entry will occupy no more than 1 line. Cut the value to fit
   
   % now see how many columns we can have
   numColumns = 20;
	for i = 1:l
   	val = e.printValue{i}{1};
   	ref = e.printValue{i}{2};
   	len = ( length( val ) + length( sf('get', ref, '.rgTag') + 4 ) *0.58 + 2) * charW; % 0.58 is an empirical coefficient
   	if len > cellW
         extra = len - cellW;
         extraChars = ceil( extra / charW );
         numChars = length( val ) - extraChars - 3;
         e.printValue{i}{1} = [ val( 1:floor(numChars/5) ) '...' ...
				val( floor(length(val)-numChars*4/5):length(val)) ];
         len = cellW;
      end
      if numColumns > 1
         numColumns = min( numColumns, floor( cellW / len ) );
      end
   end
   numLines = ceil( length( e.printValue ) / numColumns )+1;
   numColumns = min( numColumns, length( e.printValue ) );
   e.numColumns = numColumns;
   
else
   val = e.printValue{1}{1};
   ref = e.printValue{1}{2};
   e.printValue = {};
   for i = 1:sum( [val '.'] == 10 )+1  % 1:number of <CR>'s in the string
      [tok val] = strtok( val, char(10) );
      lenTok = length( tok );
      res = fit_cell( tok, charW, cellW );
      for j = 1:length( res )
         e.printValue{length( e.printValue ) + 1 } = { res{j}, '' };
		end
   end
   numLines = length( e.printValue)+1;
   e.numColumns = 1;
   e.printValue{max(1, numLines-1)}{2} = ref;
end

   
   
function res = fit_cell( str, charW, cellW )
% the function returns the cell array of strings that best fits the table cell
jcharW = charW /0.65;
maxChars = floor( cellW / charW );
if str_width( str, charW, jcharW ) <= cellW
	res{1} = str;
	return;
end
tok = [];
res = {};
while length( str ) ~= 0
   [tempTok str] = strtok( str );
   while str_width( tempTok, charW, jcharW ) > cellW
      tokLen = fit_j_str_length( tempTok(1:min(length(tempTok),maxChars)), charW, jcharW,cellW );
      tok{ length( tok ) + 1 } = [ tempTok( 1:tokLen - 1 ) '-' ];
		tempTok( 1:tokLen - 1 ) = [];
	end
	tok{ length( tok ) + 1 } = tempTok;
end 

% now all tok's are guaranteed to fit in cell.
i = 1;
while i <= length( tok )
	curStr = '';
   while i <= length( tok ) & str_width( [ curStr tok{i} ], charW, jcharW )<=cellW
      curStr = [curStr ' ' tok{i}];
		i = i + 1;
	end
	if ~isempty( curStr )	
		curStr( 1 ) = [];
	end
	%curStr = ps_string( curStr );
	res{ length( res ) + 1 } = curStr;
end

% this function computes width of a string, possibly contatining non-latin chars
function w = str_width( str, charW, charW2 )
jNum = length( find( str > 127 ) );
w = jNum*(charW2-charW) + length(str)*charW;

% this function computes the length of a substring that would fit
% in cellW
function n = fit_j_str_length( str, charW, jcharW, cellW)
n = length(str);
if n < 1, return; end
w = str_width( str, charW, jcharW );
while w > cellW
   n = max(1,n - ceil((w-cellW)/jcharW));
   str = str(1:n);
   w = str_width( str, charW, jcharW );
end



function res = ps_string( string )
	if isempty( string )
		res = '';
		return;
	end
	res = strrep( string, '\', '\\' );
	res = strrep( res, '(', '\(' );
	res = strrep( res, ')', '\)' );
	

function curPageNo = print_table_of_contents( fid, list, psFontSize, psLineSpace, ...
   gSFpsLeftMargin, gSFpsRightMargin, psTopMargin, psBottomMargin, pageHeight, gSFpageWidth, curPageNo, format)

% do nothing for PDF so far\
pdf = 0; ps = 0;
if strcmp( format, 'pdf')
	pdf = 1;
end
if strcmp( format, 'ps')
	ps = 1;
end


maxNumMachinesOnTitlePage = 10;


% print the title page
middleXPt = (gSFpageWidth + gSFpsLeftMargin - gSFpsRightMargin) / 2;
middleYPt = (pageHeight + psBottomMargin - psTopMargin) / 2;
realPageHt = pageHeight - psTopMargin - psBottomMargin;
spaceLeft = pageHeight - psTopMargin;
realPageWidth = gSFpageWidth - gSFpsLeftMargin - gSFpsRightMargin;

% 'Stateflow Book'
text1 = 'Stateflow Book for';
fs = 25;
posX = rg_num2str( middleXPt - length( text1 ) * fs * 0.65 / 2 );
spaceLeft = spaceLeft - fs - 30;
posY = rg_num2str( spaceLeft );
t = [ ...
	  posX ' ' posY ' moveto ifn ' rg_num2str( fs ) ' scalefont setfont ( ' text1 ' ) show\n' ...
	];
stream = [ ' BT /IFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text1 ') Tj ET ' ];
% print machine ids
machines = sf( 'get', list( :, 1 ), 'machine.name' );
machineIds = sf( 'get', list( :, 1 ), 'machine.id' );

spaceLeft = spaceLeft - 30;
if length( machines(:,1) ) > 1
	for i = 1:length( machines(:,1 ) )
		fs = 12;
		spaceLeft = spaceLeft - fs * 1.2;
		posY = rg_num2str( spaceLeft );
		if i <= maxNumMachinesOnTitlePage;
			text = machines( i,: );
			text = text( find( text ) );
		else
			text = '...';
		end
		posX = rg_num2str( middleXPt - length( text ) * fs * 0.65 / 2 ) ;
		text = ps_string( text );
		t = [ t ...
		  posX ' ' posY ' moveto fn ' rg_num2str( fs ) ' scalefont setfont  ( ' text ' ) show\n' ...
		];
		stream = [ stream, ' BT /NFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text ') Tj ET '];
		if i > maxNumMachinesOnTitlePage break; end;   % stop because there is too much to print
	end
else
	% only one machine reported

	% determine the font size to print the machine name with
	fs = min( 25, realPageWidth / length( machines ) /0.65 );
	text = machines;
	posX = rg_num2str( middleXPt - length( text ) * fs * 0.65 / 2 );
	spaceLeft = spaceLeft - fs - 30;
	posY = rg_num2str( spaceLeft );
	t = [ t ...
		  posX ' ' posY ' moveto bfn ' rg_num2str( fs ) ' scalefont setfont ( ' text ' ) show\n' ...
		];
	stream = [ stream, ' BT /BFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text ') Tj ET '];

	% version
	spaceLeft = spaceLeft - fs - 15;
	text2 = [ 'Version ' sf( 'get', machineIds, '.version' )  ];
	fs = 10;
	posX = rg_num2str( middleXPt - length( text2 ) * fs * 0.65 / 2 );
	posY = rg_num2str( spaceLeft );
	t = [ t ...
		  posX ' ' posY ' moveto fn ' rg_num2str( fs ) ' scalefont setfont  ( ' text2 ' ) show\n' ...
		];
	stream = [ stream, ' BT /NFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text2 ') Tj ET '];

	% creator
	spaceLeft = spaceLeft - fs - 15;
	text2 = [ 'Created by ' sf( 'get', machineIds, '.creator' ) ];
	fs = 10;
	maxLength = floor( realPageWidth / (fs * 0.65) );
	if length( text2 ) > maxLength
		text2 = [text2(1:maxLength - 3) '...'];
	end
	posX = rg_num2str( middleXPt - length( text2 ) * fs * 0.65 / 2 );
	posY = rg_num2str( spaceLeft );
	t = [ t ...
		  posX ' ' posY ' moveto fn ' rg_num2str( fs ) ' scalefont setfont  ( ' text2 ' ) show\n' ...
		];
	stream = [ stream, ' BT /NFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text2 ') Tj ET '];


end

	
% Report generated
c = clock;
curTime = [date '  ' rg_num2str( c(4)) ':' rg_num2str(c(5)) ];
spaceLeft = spaceLeft - fs - 30;
text2 = [ 'Generated ' sf_date_str ];
fs = 10;
posX = rg_num2str( middleXPt - length( text2 ) * fs * 0.65 / 2 );
posY = rg_num2str( spaceLeft );
t = [ t ...
	  posX ' ' posY ' moveto fn ' rg_num2str( fs ) ' scalefont setfont  ( ' text2 ' ) show\n' ...
	];
stream = [ stream, ' BT /NFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text2 ') Tj ET '];



% Stateflow version
spaceLeft = psBottomMargin + 35;
text2 = [ 'Stateflow ' sf('Version') ];
fs = 10;
posX = rg_num2str( middleXPt - length( text2 ) * fs * 0.65 / 2 );
spaceLeft = spaceLeft - fs * 1.2;
posY = rg_num2str( spaceLeft );
t = [ t ...
	  posX ' ' posY ' moveto fn ' rg_num2str( fs ) ' scalefont setfont  ( ' text2 ' ) show\n' ...
	];
stream = [ stream, ' BT /NFt ' rg_num2str( fs ) ' Tf ' posX ' ' posY ' Td (' text2 ') Tj ET '];


t = [t ' stroke showpage \n' ];
if ps
	fprintf( fid,  t );
	fprintf( fid, '%s\n', '%%PageTrailer' );
	fprintf( fid, '%s\n', '%%Page: i i' );
end
if pdf
   streamObjNum = write_pdf_object( fid, stream, 'st', 0 );
   pageObj = [ ' /Type /Page ', ... 
         '/Contents ' rg_num2str( streamObjNum ) ' 0 R '...
         ...'/Trans << /S /Dissolve /D 0.1 >> ' ...
			'/Resources 3 0 R ' ...
      ];
   pageObjNum = write_pdf_object( fid, pageObj, 'pg', curPageNo, [], 0 );
   %return;  %TBR
end





% print all the entries in the order they are in the list
global gSFtContents;
startY = pageHeight - psTopMargin - psFontSize - psLineSpace;
curY = startY;
global gSFmaxDepth;
levelOffset = ( gSFpageWidth - gSFpsLeftMargin - gSFpsRightMargin - 15 * psFontSize * 0.65 )/gSFmaxDepth;
levelOffset = min( levelOffset, psFontSize * 2 );
pageNumX = gSFpageWidth - gSFpsRightMargin - 4 * psFontSize * 0.65;

% print the words 'Table of contents on top of the thing'
x = (pageNumX + gSFpsLeftMargin - 17 * psFontSize * 0.65)/2;
curY = curY - psFontSize - psLineSpace;
text1 = 'Table of Contents';
if ps
	fprintf( fid, [rg_num2str( x ) ' ' rg_num2str( curY ) ' moveto (' text1 ') show\n' ] );
end
if pdf
	stream = [ 'BT /NFt ' rg_num2str( psFontSize ) ' Tf ' rg_num2str( x ) ' ' ...
				rg_num2str( curY ) ' Td (' text1 ') Tj ET '];
end
notForPrint = [];

for i = 1:length( list )
   entry = list(i,:);
   id = entry(1);
   level = entry(2);
	printCheck = ismember( notForPrint, id);
	if sum( printCheck ) ~= 0
		i = i + 1;
		notForPrint( printCheck ) = [];
		if i>length( list )
			break;
		end
	end
   page = gSFtContents(list(i));
	fontSize = psFontSize; % + (gSFmaxDepth - level)*psFontSize/gSFmaxDepth/3;
   if curY < psBottomMargin * 1.5
      curY = startY;
      pnX = gSFpageWidth - gSFpsRightMargin - length( rg_num2str( curPageNo ) ) * psFontSize * 0.65;
      pnY = psBottomMargin;
      pn = rg_num2str( curPageNo );pn = toRoman( curPageNo );
		if ps
         fprintf( fid, '%s\n', [rg_num2str( pnX ) ' ' rg_num2str( pnY ) ' moveto ' ...
               'fn ' rg_num2str( psFontSize ) ' scalefont setfont ' ...
               '(' pn ') show stroke showpage' ] );
         fprintf( fid, '%s\n', '%%PageTrailer' );
         fprintf( fid, '%s\n', ['%%Page: ' toRoman( curPageNo +1 ) ' ' toRoman( curPageNo + 1) ] );
		end
		if pdf
			stream = [ stream, ...
				' BT /NFt ' rg_num2str( psFontSize ) ' Tf ' rg_num2str( pnX ) ' ' ...
				rg_num2str( pnY ) ' Td (' pn ') Tj ET '];
			streamObjNum = write_pdf_object( fid, stream, 'st', 0 );
			stream = '';
		   pageObj = [ ' /Type /Page ', ... 
	      '/Contents ' rg_num2str( streamObjNum ) ' 0 R '...
   	   ...'/Trans << /S /Dissolve /D 0.0 >> ' ...
			'/Resources 3 0 R ' ...
     		 ];
   		pageObjNum = write_pdf_object( fid, pageObj, 'pg', curPageNo, [], 0 );
		end
      curPageNo = curPageNo + 1;
   end
   x = gSFpsLeftMargin + level * levelOffset;
   
   % put only machines, charts, states with a certain number of children in the table 
   type = num2type( whoami( id ) );
   name = '';
   print = 0;
	notForPrintThisParent = eval( 'sf( ''ObjectsIn'', id )', '[]' );
	cordinality = length( notForPrintThisParent );
	if cordinality < 10
		notForPrint = [notForPrint notForPrintThisParent ];
	end
	if ( (strcmp( type, 'state' ) |strcmp( type, 'function' ) | strcmp( type, 'group' )) &...
         cordinality >= 10 ) | ...
         strcmp( type, 'chart' ) | strcmp( type, 'machine' ),
      % print the line in the table of contents for this object
      name = sf( 'get', id, '.name' );
      print = 1;
   else
      % report only the first instance of this type and only if it is a junction, transition
      %   data or event
      if whoami( id ) ~= whoami( list( i-1 ) )
         if strcmp( type, 'transition' ) |strcmp( type, 'junction' ) | ...
               strcmp( type, 'data' ) | strcmp( type, 'event' ) |strcmp( type, 'target' ),
            postfix = '';
            if (whoami( id ) == whoami( list( i+1 ) )) & ~strcmp( type, 'data' )
               postfix = 's';
            end
           	name = ['Report on ' num2type( whoami( id ) ) postfix];
            print = 1;
         end
      end
   end
   if print == 1,
      curY = curY - fontSize - psLineSpace;
      maxLength = floor( (pageNumX - x) / (fontSize * 0.65) - 3 );
      if length( name ) > maxLength
         name = [name( 1:floor(maxLength/5) ) '...' ...
					name(floor((length(name)-maxLength*4/5+3)):length(name)) ];
      end
		if ps
         fprintf( fid, [ 'fn ' rg_num2str( fontSize ) ' scalefont setfont\n'] );
         fprintf( fid, [rg_num2str( x ) ' ' rg_num2str( curY ) ' moveto (' ps_string( name ) ')show\n' ] );
         fprintf( fid, [ 'fn ' rg_num2str( psFontSize ) ' scalefont setfont\n'] );
         % draw the dotted line to the page number
         fprintf( fid, [ 'currentpoint stroke [1 5] 0 setdash moveto ' ...
               rg_num2str( pageNumX ) ' ' rg_num2str( curY ) ' lineto stroke [] 0 setdash ' ] );
         fprintf( fid, ...
            [rg_num2str( pageNumX ) ' ' rg_num2str( curY ) ' moveto (' rg_num2str( page ) ')show\n' ] );
      end
		if pdf
			stream = [ stream, ...
						' 0 0 0.5 rg BT /NFt ' rg_num2str( fontSize ) ' Tf ' ...
						rg_num2str( x ) ' ' rg_num2str( curY ) ' Td (' ps_string( name ) ') Tj ET ' ...
						'BT /NFt ' rg_num2str( fontSize ) ' Tf ' ...
						rg_num2str( pageNumX ) ' ' rg_num2str( curY ) ' Td (' rg_num2str( page ) ') Tj ET ' ...
						'[1 5] 0 d ' rg_num2str( x + length( name )*psFontSize*0.65 ) ' ' rg_num2str( curY ) ' m ' ...
						rg_num2str( pageNumX ) ' ' rg_num2str( curY ) ' l S 0 g 0 G ' ...
			];
			pdf_add_link( fid, [x-fontSize/2, curY-psLineSpace, pageNumX+fontSize*0.65, curY+fontSize], id ); 
		end %if pdf
    end
end % for

if curY ~= startY
   pnX = gSFpageWidth - gSFpsRightMargin - length( rg_num2str( curPageNo ) ) * psFontSize * 0.65;
   pnY = psBottomMargin;
	pn = rg_num2str( curPageNo ); pn = toRoman( curPageNo );
	if ps
      fprintf( fid, '%s\n', [rg_num2str( pnX ) ' ' rg_num2str( pnY ) ' moveto ' ...
            'fn ' rg_num2str( psFontSize ) ' scalefont setfont ' ...
            '(' pn ') show stroke showpage' ] );
      fprintf( fid, '%s\n', '%%PageTrailer' );
      fprintf( fid, '%s\n', '%%Page: 1 1'  );
   end
	if pdf
			stream = [ stream, ...
				' BT /NFt ' rg_num2str( psFontSize ) ' Tf ' rg_num2str( pnX ) ' ' ...
				rg_num2str( pnY ) ' Td (' pn ') Tj ET '];
			streamObjNum = write_pdf_object( fid, stream, 'st', 0 );
			stream = '';
		   pageObj = [ ' /Type /Page ', ... % parent of all pages is the pages objects( #2 )
	      '/Contents ' rg_num2str( streamObjNum ) ' 0 R '...
   	   ...'/Trans << /S /Dissolve /D 0.0 >> ' ...
			'/Resources 3 0 R ' ...
     		 ];
   		pageObjNum = write_pdf_object( fid, pageObj, 'pg', curPageNo, [], 0 );
	end

   curPageNo = curPageNo + 1;
end
% have no page numbering for the table of contents
curPageNo = 1;

function str = toRoman( curPageNo )
switch curPageNo,
	case 1,
		str = 'i';
	case 2,
		str = 'ii';
	case 3,
		str = 'iii';
	case 4,
		str = 'iv';
	case 5,
		str = 'v';
	case 6,
		str = 'vi';
	case 7,
		str = 'vii';
	case 8,
		str = 'viii';
	case 9,
		str = 'ix';
	case 10,
		str = 'x';
end
	


function hierarchy = compute_hierarchy( ids, level )
% ids are chart ids (assumed)
global hierarchy;
global gSFobjAbbr;
global gSFobjCount;
machineIds = [];
for i = ids
   machine = sf( 'get', i, '.machine' );
	if sum( ismember( machineIds, machine ) ) == 0
		machineIds = [machineIds machine];
	  	hierarchy( length( hierarchy(:) )/2 +1, 1:2 ) = [machine, level-1];
   	gSFobjCount.machine = gSFobjCount.machine + 1;
   	sf( 'set', machine, '.rgTag', [gSFobjAbbr.machine  rg_num2str( gSFobjCount.machine )] );
   	targets = [sf( 'TargetsOf', machine) ];
   	for j = 1:length( targets )
    	 	hierarchy( length( hierarchy(:, 1) )+1, 1:2 ) = [targets(j), level];
    		gSFobjCount.target = gSFobjCount.target + 1;
   		sf( 'set', targets(j), '.rgTag', [gSFobjAbbr.target  rg_num2str( gSFobjCount.target )] );
   	end
	 	put_events_and_data_in_the_hierarchy( machine, level );
	end
		put_in_the_hierarchy( i, level );  % pass chart id  
end


%now sort the events and data alphabetically
global gSFeventList;
global gSFdataList;
if ~isempty( gSFeventList )
	eventNames = sf( 'get', gSFeventList(:,1), '.name' );
	[sortedNames index] = sortrows( eventNames );
	hierarchy = [ hierarchy; gSFeventList(index,:) ];
end
if ~isempty( gSFdataList )
	dataNames = sf( 'get', gSFdataList(:,1), '.name' );
	[sortedNames index] = sortrows( dataNames );
	hierarchy = [ hierarchy; gSFdataList(index,:) ];
end

% the function assumes chart or state ids only
function put_in_the_hierarchy( id, level )
	global hierarchy;
	global gSFobjAbbr;
   global gSFobjCount;
   
   hierarchy( length( hierarchy(:,1) )+1, 1:2 ) = [sf( 'get', id, '.id' ), level]; 
   
   % assign a tag to me, depending on who I am (chart, state, group or function)
   me = num2type( whoami( id ) );
   eval( ['gSFobjCount.' me '= gSFobjCount.' me ' + 1;' ] );  % increment corresponding gSFobjCount
   tag = eval( [ '[gSFobjAbbr.' me ' rg_num2str( gSFobjCount.' me ')]' ] );   % get the tag
   sf( 'set', id, '.rgTag', tag );
   
   % recursively (depth first) print all the states
   child = sf( 'get', id, '.treeNode.child' );
   while child ~= 0
      put_in_the_hierarchy( child, level + 1 );
      child = sf( 'get', child, '.treeNode.next' );
   end
   % now print all the rest: junctions, transitions, data, events, 
   junction = sf( 'get', id, '.firstJunction' );
   while junction ~= 0
      hierarchy( length( hierarchy(:, 1) )+1, 1:2 ) = [junction, level+1];
     	gSFobjCount.junction = gSFobjCount.junction + 1;
   	sf( 'set', junction, '.rgTag', [gSFobjAbbr.junction  rg_num2str( gSFobjCount.junction )] );
      junction = sf( 'get', junction, '.linkNode.next' );
 	end
   transition = sf( 'get', id, '.firstTransition' );
	while transition ~= 0
      hierarchy( length( hierarchy(:,1) )+1, 1:2 ) = [transition, level+1];
      gSFobjCount.transition = gSFobjCount.transition + 1;
   	 sf( 'set', transition, '.rgTag', [gSFobjAbbr.transition  rg_num2str( gSFobjCount.transition )] );
      transition = sf( 'get', transition, '.linkNode.next' );
   end
   put_events_and_data_in_the_hierarchy( id, level+1);
   global gSFmaxDepth;
   gSFmaxDepth = max( gSFmaxDepth, level+1 );
   
   
   
   
function put_events_and_data_in_the_hierarchy( id, level )
global gSFeventList;
global gSFdataList;
global gSFobjCount;
global gSFobjAbbr;

   data = sf('get', id, '.firstData');
   while data ~= 0
   	gSFdataList( length( gSFdataList(:) )/2+1, 1:2 ) = [data, 1];
     	gSFobjCount.data = gSFobjCount.data + 1;
      sf( 'set', data, '.rgTag', [gSFobjAbbr.data  rg_num2str( gSFobjCount.data )] );
      data = sf( 'get', data, '.linkNode.next' );
	end

   event = sf('get', id, '.firstEvent');
   while event ~= 0
   	gSFeventList( length( gSFeventList(:) )/2+1, 1:2 ) = [event, 1];
     	gSFobjCount.event = gSFobjCount.event + 1;
   	sf( 'set', event, '.rgTag', [gSFobjAbbr.event  rg_num2str( gSFobjCount.event )] );      
      event = sf( 'get', event, '.linkNode.next' );
	end


function res = generate_all_ids( ids )
% the function takes the list of charts (assumed) and
% generates the list of all objects in the chart plus 
% the machine object and all the events, data and targets
% parented by that machine

% generate the list in hierarchical order and return
global hierarchy; global gSFeventList; global gSFdataList;
clear global hierarchy;
clear global gSFeventList;
clear global gSFdataList;

hierarchy = [];
res = compute_hierarchy( ids, 1 );
clear global hierarchy;
return;

% -----------------------------------------------------------
% the following code constructs a list of objects in
% sorted by type and then alphabetically
% however, some algorithms is rg assume hierarchical
% order, so this option is currently not available.
% so, it is commented out, but left inside the file
% for possible future use.

%global objCounter;
%global gSFobjAbbr;
%% ids are ordered by type
%machines = unique( sf( 'get', ids, '.machine' ));
%machineData = [];
%machineEvents = [];
%targets = [];
%for i = machines
%   machineData = [machineData sf( 'DataOf', i) ];
%   machineEvents = [machineEvents sf( 'EventsOf', i) ];
%   targets = [targets sf( 'TargetsOf', i) ];
%end

%charts = unique( ids );

%all_the_rest = [];
%for i = ids  %transpose, so that we have a row vector
%   all_the_rest = [all_the_rest sf( 'ObjectsIn', i )];
%end
%states = sf( 'find', all_the_rest, '.isa', type2num( 'state' ) );
%transitions = sf( 'find', all_the_rest, '.isa', type2num( 'transition' ) );
%junctions = sf( 'find', all_the_rest, '.isa', type2num( 'junction' ) );
%data = [machineData sf( 'find', all_the_rest, '.isa', type2num( 'data' ) )];
%events = [machineEvents sf( 'find', all_the_rest, '.isa', type2num( 'event' ) )];

%% Now, states include both functions and groups
%% we have to separate those
%functions = sf( 'find', states, '.type', 'FUNC_STATE' );
%groups = sf( 'find', states, '.type', 'GROUP_STATE' );

%% all the rest are real states ({OR_STATE, AND_STATE})
%orStates = sf( 'find', states, '.type', 'OR_STATE' );
%andStates = sf( 'find', states, '.type', 'AND_STATE' );
%states = [orStates andStates];

%% now we can compose the resulting vector
%% the order is the following
%%  machines
%%  targets
%%  charts
%%  states
%%  groups
%%  functions
%%  transitions
%%  junctions
%%  events
%%  data
%res = [machines targets charts states groups functions transitions junctions events data];
%if length(res) ~= length(unique(res))
%   error( 'Warning: entries in gSFreportList are not unique!' );
%end
%%res = unique( res );  % dont use unique because it sorts the output

%% now tag all objects correspondingly
%for i = 1:length(machines)
%   sf( 'set', machines(i), '.rgTag', [gSFobjAbbr.machine rg_num2str(i)] );
%end
%for i = 1:length(targets)
%   sf( 'set', targets(i), '.rgTag', [gSFobjAbbr.target rg_num2str(i)] );
%end
%for i = 1:length(states)
%   sf( 'set', states(i), '.rgTag', [gSFobjAbbr.state rg_num2str(i)] );
%end
%for i = 1:length(transitions)
%   sf( 'set', transitions(i), '.rgTag', [gSFobjAbbr.transition rg_num2str(i)] );
%end
%for i = 1:length(junctions)
%   sf( 'set', junctions(i), '.rgTag', [gSFobjAbbr.junction rg_num2str(i)] );
%end
%for i = 1:length(events)
%   sf( 'set', events(i), '.rgTag', [gSFobjAbbr.event rg_num2str(i)] );
%end
%for i = 1:length(data)
%   sf( 'set', data(i), '.rgTag', [gSFobjAbbr.data rg_num2str(i)] );
%end
%for i = 1:length(functions)
%   sf( 'set', functions(i), '.rgTag', [gSFobjAbbr.function rg_num2str(i)] );
%end
%for i = 1:length(groups)
%   sf( 'set', groups(i), '.rgTag', [gSFobjAbbr.group rg_num2str(i)] );
%end

%for i = 1:length(charts)
%   sf( 'set', charts(i), '.rgTag', [gSFobjAbbr.chart rg_num2str(i)] );
%end

% ------------ end of commented out section of code ---------------------------


function res = read_layout_table
% the function sets the tables (2d cell arrays) of 4 columns
% where each row corresponds to a printable entry
% where the first column is the name as it appears in
% data dictionary, the second column is the name of
% the property as it appears on the output, the
% third coulmn is the number of the table {1,2} for
% the property to be printed to, and the fourth
% column is the position of the property within an HTML
% 2d table
% It also sets other parameters read from the layout file,
% such as 'image', etc.
% the data is read from a layout file

layoutFileName = 'rglayout.dat';
layoutFile = fopen( layoutFileName, 'r' );
if layoutFile == -1
   error( ['Could not open the layout file:  ', ... 
      layoutFileName] );
end
res = {};
str = read_line( layoutFile );
%read all the stuff in the loop
while ~strcmp( str, 'end' )
   % str must contain the type of object
   type = strtok( str );
   typeN = type2num( type );
   
   % create the cell in the cell array that
   % contains information on this type's layout
   % res{typeN} is the cell we want to set up
   str = read_line( layoutFile );
   % if it starts 'end' then go to the next iteration of the loop
   temp_cell = {};
	objDefStruct = [];
   if ~strcmp( strtok( str ), 'end' )
      % alright, process the info
      i = 1; j = 1;
      while 1,  % for j = 1:2
      	if ~strcmp( strtok( str ), 'table' )
         	error('keyword ''table'' expected in the layout file');
         end
         str = read_line( layoutFile );
      	[sysName str] = strtok( str );
      	while ~strcmp( sysName, 'end' )
				if strcmp( sysName, 'SF_TEXT' )
					% get the text between single back quotes (char(96) is a single quote)
					[printName str] = strtok( str, char(96));  %remove all chars before the 1st quote
					[printName str] = strtok( str, char(96));  %get the text between the quotes
					str(1) = [];  % remove the closing quote
				else
					[printName str] = strtok( str );  % default case.
				end
				if strcmp( printName, 'SF_EMPTY' )
					printName = '';
				end
            [x str] = strtok( str );
				
				% x may contain the word 'bold' to notify to print printValues in bold.
				boldVal = 0;
				if strcmp( x, 'bold' )
					boldVal = 1;
            	[x str] = strtok( str );
				end
				% x may contain the word 'important' to notify that this field is important.
				important = 0;
				if strcmp( x, 'important' )
					important = 1;
            	[x str] = strtok( str );
				end
				% x may contain the word 'underline' to notify that this field is important.
				underline = 0;
				if strcmp( x, 'underline' )
					underline = 1;
            	[x str] = strtok( str );
				end

				% x may contain the word 'rightJustify' to notify the right justification of the field.
				rightJustify = 0;
				if strcmp( x, 'rightJustify' )
					rightJustify = 1;
            	[x str] = strtok( str );
				end

            x = str2num( x );
      		[y str] = strtok( str );
            y = str2num( y );
      		[widthPercent str] = strtok( str );
            widthPercent = str2num( widthPercent );
            %check if the user specified the rules (value and/or display)
            [rule the_rest] = strtok(str);
            valueRule = '';
            printRule = '';
				ignoreRule = '';
            while ~isempty(rule)
               rule = [rule the_rest];
					the_rest = '';
               global gSFprintRuleChar;
               global gSFvalueRuleChar;
               global gSFignoreRuleChar;
					switch rule(1)+0,
               case gSFprintRuleChar+0,
                  [printRule rule] = strtok( rule, [gSFvalueRuleChar,gSFignoreRuleChar] ); 
                	if ~isempty( printRule )
                 		printRule(1) = [];
               	end	
             	case gSFvalueRuleChar+0,
                  [valueRule rule] = strtok( rule, [gSFprintRuleChar, gSFignoreRuleChar] ); 
                	if ~isempty( valueRule )
                  	valueRule(1) = [];
               	end
               case gSFignoreRuleChar+0,
                  [ignoreRule rule] = strtok( rule, [gSFprintRuleChar, gSFvalueRuleChar] ); 
               	if ~isempty( ignoreRule )
                  	ignoreRule(1) = [];
               	end
               end
            end
            
				temp_cell{i} = {sysName, printName, j, ...
							[x, y], valueRule, printRule, widthPercent, boldVal, important, ignoreRule, underline, rightJustify};
            str = read_line( layoutFile );
            [sysName str] = strtok( str );
            i = i + 1; 
         end
         str = read_line( layoutFile );
			j = j + 1;
			if ~strcmp( strtok( str ), 'table' ) break; end
      end % while
      objDefStruct.layout = temp_cell;
		objDefStruct.image = [];
      objDefStruct.sharePage = 1;  % default
      objDefStruct.avoidTwoPageObj = 0;  % default
		objDefStruct.pointToIt = 0;  % default
      objDefStruct.picMinChildren = -1;  % default
		objDefStruct.putInTable = 0;  % default
		objDefStruct.repMinChildren = -1;  % default
		objDefStruct.spaceLeftToNewPage = 60;  % default
		objDefStruct.ignore = 0;  % default
		objDefStruct.dynamicSize = 1;  % default
		objDefStruct.border = 1;  % default
		% check for any other variable definitions
		if ~strcmp( str, 'define' )
			error( 'keyword "define" expected in the layout file' );
		end
		str = read_line( layoutFile );
		[varName varDef] = strtok( str );
		while ~strcmp( varName, 'end' )
			% define the corresponding field in the structure
			switch varName,
			case 'image',
				% there has to be <width> <height> <format> on this string
				[w rest] = strtok( varDef );  w = str2num( w);
				[h rest] = strtok( rest );  h = str2num( h );
				f = strtok( rest );
				objDefStruct.image = {w, h, f};
			case 'sharePage',
				% the next token is either 1 or 0
				sp = str2num( strtok( varDef ) );
				objDefStruct.sharePage = sp;
			case 'pointToIt',
				pti = str2num( strtok( varDef ) );
				objDefStruct.pointToIt = pti;
			case 'avoidTwoPageObj',
				tfop = str2num( strtok( varDef ) );
				objDefStruct.avoidTwoPageObj = tfop;
			case 'picMinChildren',
				pmc = str2num( strtok( varDef ) );
				objDefStruct.picMinChildren = pmc;
			case 'putInTable',
				pit = str2num( strtok( varDef ) );
				objDefStruct.putInTable = pit;
			case 'repMinChildren',
				rmc = str2num( strtok( varDef ) );
				objDefStruct.repMinChildren = rmc;
			case 'spaceLeftToNewPage',
				sltnp = str2num( strtok( varDef ) );
				objDefStruct.spaceLeftToNewPage = sltnp;
			case 'border',
				bor = str2num( strtok( varDef ) );
				objDefStruct.border = bor;
			case 'ignore',
				ign = str2num( strtok( varDef ) );
				objDefStruct.ignore = ign;
			otherwise,
				error( [ 'Layout file: unknown property: ' varName ]);
			end
			str = read_line( layoutFile );
			[varName varDef] = strtok( str );
		end
		% now read in and discard the next line (it should be the end, terminating
		% object definition
		str = read_line( layoutFile );
		if ~strcmp(strtok( str ), 'end' )
			error( 'No closing "end"' );
		end

   end   
   res{typeN+1} = objDefStruct;
   str = read_line( layoutFile );     
end

% we are done. clean up
fclose( layoutFile );




function res =  read_line( fid )
% reads the next meaningful line (non-empty and non-commented)
res = '';
while ((length( res ) == 0) | (res(1) == '#')) & (feof(fid)==0)
   res = fgetl( fid );
end



function res = type2num( type )
global gSFtypeTable;
for i = 1:length(gSFtypeTable)
   if strcmp( type, gSFtypeTable{i} )
      res = i-1;
      return;
   end
end
error( ['type2num: unknown type: ' type] );




function res = whoami( id )
% the function returns numeric value of the type of the
% object which id was passed
%
if id == 0
   res = 0;
   return;
end

res = sf( 'get', id, '.isa' );
if res ~= type2num('state')
   return;
else
   type = sf( 'get', id, '.type' );
   global gSfGroupStateType;
   global gSfFunctionStateType;
   if type == gSfGroupStateType
      res = type2num( 'group' );
   else if type == gSfFunctionStateType
         res = type2num('function');
      else % has be a normal state 
         res = type2num('state');
      end
   end
end



function res = num2type( num )
global gSFtypeTable;
if num < 0 | num > length(gSFtypeTable) - 1;
   error( 'num2type: number is too large' );
end
res = gSFtypeTable{ num + 1};

function res = get_states( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
global gSfORStateType;
global gSfANDStateType;
res = sf( 'find', states, '.type', gSfORStateType);
res = [res sf( 'find', states, '.type', gSfANDStateType)];


function res = get_functions( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
global gSfFunctionStateType;
res = sf( 'find', states, '.type', gSfFunctionStateType);



function res = get_groups( ids )
%  return the ids of 'real' states (not functions or groups)
states = sf( 'get', ids, 'state.id' );
global gSfGroupStateType;
res = sf( 'find', states, '.type', gSfGroupStateType);

% this function returns the string that best describes the transition's
% source/destination (chooses between tag for junction or name for state)
function res = get_trans_src_or_dest( id )
type = whoami( id );
if isempty( type )
   res = [];
   return;
end

if type == type2num('junction'),
   res = sf('get', id, '.rgTag');
else 
   res = sf('get', id, '.name');
end


function str = get_sf_obj_name( id )
myType = whoami( id );
if myType == type2num( 'transition' )
	str = ['{T} ' sf( 'get', id, '.rgTag' )];
	return;
end
if myType == type2num( 'junction' )
	str = ['{J} ' sf( 'get', id, '.rgTag' )];
	return;
end
if myType == type2num( 'note' )
	str = 'Index';
	return;
end
str = sf( 'get', id, '.name' );
global gSFobjAbbr;
myAbbr = eval( ['gSFobjAbbr.' num2type(myType)], '' );
str = ['{' myAbbr '} ' str];



function ids = sort_by_name( ids )
% this function will sort the list of id's of SF objects by name and return the 
% resulting vector of sorted ids.  Requirement: each object in the list has to
% have '.name' property 
names = sf( 'get', ids, '.name' );
[sortedNames index] = sortrows( upper(names) );
ids = ids( index );

function res = get_data_type( id )
res = sf( 'get', id, '.dataType' );
if isempty( res )
	res = 'Real(double)';
end

function res = rg_num2str( num )
res = '';
if ~isempty( num )
	if ceil( num ) ~= num
		res = sprintf( '%.3f ', num );
	else
		res = sprintf( '%d', num );
	end
end

function res = rg_num2str14( num )
res = sprintf( '%.14f ', num );


function [token, remainder] = strtok(str, delimiters),

if nargin<1, error('Not enough input arguments.'); end

token = []; 
remainder = [];

len = length(str);
if len == 0,
    return;
end


switch nargin,
   case 1, delimiters = [9:13 32]; % White space characters
   case 2, 
      if isempty(delimiters), return; end;     
end

 lenDel = length(delimiters);

strMat = str(ones(1, lenDel), :);
delMat = delimiters(ones(1, len), :)';

M = strMat == delMat;
if size(M, 1) > 1,
   M = sum(M);
   M = M > 0; % zeros indicate the token matches.
end;

ind = find(M==0);

if ~isempty(ind),
   start = ind(1);
	remM = M(start:end);
	lenToken = find(remM~=0);
	if ~isempty(lenToken),
		finish = start + lenToken(1) - 2;
	else,
		finish = len;
	end;
	token = str(start:finish);

   if (nargout == 2),
      remainder = str((finish + 1):len);
   end
end;

function res = tableCellEmpty( i, j )
global SFCellEmpty;
res = SFCellEmpty( i + 1, j + 1 );


function res = isLabelLegible( id )
global gSFdrawInfo;
global gSFlegibleSize;

d  = gSFdrawInfo.data{ gSFdrawInfo.map( id ) };
scale = d{2};
SFFontSize = d{7};
res = scale * SFFontSize >= gSFlegibleSize - 0.05;

function res = get_data_scope( id )
global gSFdataScopeTable;
if isempty( gSFdataScopeTable )
	% construct the table
	[prop,scopes]=sf('subproperty','data.scope');
	for i=1:length(scopes{1})
		pos = find( scopes{1}{i} == '_' );
		scopes{1}{i} = scopes{1}{i}(1:pos(1)-1);
	end
	gSFdataScopeTable = scopes{1};
end
res = gSFdataScopeTable{ sf( 'get', id, '.scope' ) + 1 };

function res = get_event_scope( id )
global gSFeventScopeTable;
if isempty( gSFeventScopeTable )
	% construct the table
	[prop,scopes]=sf('subproperty','event.scope');
	for i=1:length(scopes{1})
		pos = find( scopes{1}{i} == '_' );
		scopes{1}{i} = scopes{1}{i}(1:pos(1)-1);
	end
	gSFeventScopeTable = scopes{1};
end
res = gSFeventScopeTable{ sf( 'get', id, '.scope' ) + 1 };



function clear_all_global
% clears all the global variables used in the program
  clear global gSFdataList;
  clear global gSFdataScopeTable;
  clear global gSFdocument;
  clear global gSFdrawInfo;
  clear global gSFeventList;
  clear global gSFeventScopeTable;
  clear global gSFignoreRuleChar;
  clear global gSFimageDirName;
  clear global gSFinitDirName;
  clear global gSFlayoutTable;
  clear global gSFlegibleSize;
  clear global gSFmaxDepth;
  clear global gSFobjAbbr;
  clear global gSFobjCount;
  clear global gSFoutFileName;
  clear global gSFpagesOfTContents;
  clear global gSFprintRuleChar;
  clear global gSFreportList;
  clear global gSfANDStateType;
  clear global gSfFunctionStateType;
  clear global gSfGroupStateType;
  clear global gSfORStateType;
  clear global gSFtContents;
  clear global gSFtypeTable;
  clear global gSFvalueRuleChar;
  clear global gSFpageWidth;
  clear global gSFpsLeftMargin;
  clear global gSFpageWidth;
  clear global gSFpsRightMargin;
  clear global gSFpdfOffset;
  clear global gSFCancelFlag;
  clear global gSFFullOutFileName;
  clear global SFCellEmpty;
  clear global gSFpsJapaneseFontName;
  clear global gSFisJapanese;
  %close( findobj( allchild(0), 'flat', 'Tag', 'TMWWaitbar' ) );


function init_pdfOffset
global gSFpdfOffset;

% gSFpdfOffset is a structure
%	.offset(i) is the offset of pdf object i from the beginning of the pdf file	
%	.sf2pdf	is the mapping between SF objects and pdf objects
%	.pg2pdf

gSFpdfOffset.offset = [ 0 0 0 0 ];  % reserve first five objects for certain objects
%gSFpdfOffset.offset = zeros(1,4000);  % reserve first five objects for certain objects
% 1: catalog
% 2: pages
% 3: resources
gSFpdfOffset.sf2pdf = sparse( 100000000, 1 );
gSFpdfOffset.pdf2sf = [];
gSFpdfOffset.pg2pdf = [];
gSFpdfOffset.fontNames = [];
gSFpdfOffset.numPages = 0;
gSFpdfOffset.xobjects = [];
gSFpdfOffset.annots = [];
gSFpdfOffset.objectsOnPage = {};
gSFpdfOffset.sfObjectDesc = {};
gSFpdfOffset.sfObjectMap = sparse( 100000000, 1 );
gSFpdfOffset.numPagesHere = 0;
gSFpdfOffset.currentPagesObj = 0;
gSFpdfOffset.kidsObj = '';
gSFpdfOffset.pagesTreeWidth = 10;
gSFpdfOffset.pagesObjects = [];






function nextObjNum = write_pdf_object( fid, str, objType, id, arg5, arg6)
% this function will ease the maintenance of the pdf objects

% possible object types:
% sf: stateflow object
% pg: page object
% fn: font name object
% rs: object with a reserved id
% xo: XObject (also updates sf2pdf and pdf2sf )
global gSFpdfOffset;
nextObjNum = length( gSFpdfOffset.offset ) + 1;

if strcmp( objType, 'rs' )
	nextObjNum = id;
else
	nextObjNum = nextObjNum + 1;
end


gSFpdfOffset.offset( nextObjNum ) = 0; % allocate this entry
	
pos = ftell( fid );

if strcmp( objType, 'st' ) % stream
	stream = 1;
else
	stream = 0;
end



prefix = [ num2str(nextObjNum) ' 0 obj <<\n' ];
postfix = '\n>>\nendobj\n\n';

generic = 1;
if stream
	if ~isempty( str )
		str( str == 10 ) = [];
	end
	prefix = [prefix ' /Length ' rg_num2str( length( str ) +1 ) '\n>>\nstream\n' ];
	postfix = '\nendstream\nendobj\n\n';
	fprintf( fid, prefix );
	fprintf( fid, '%s\n', str );
	fprintf( fid, postfix );
	generic = 0;
end

% XObjects are not used . Comment out, but leave in file
%if strcmp( objType, 'xo' ) 
%	% XObject. Str is a cell array of two strings

%	prefix = [ num2str(nextObjNum) ' 0 obj\n<<\n' ];
%	fprintf( fid, [ prefix, str{1} ] );
%	stream = str{2};
%	if ~isempty( stream )
%		stream( stream == 10 ) = [];
%	end
	
%	prefix = [ '/Length ' rg_num2str( length( stream ) + 1 ) '\n>>\nstream\n'];
%	postfix = 'endstream\nendobj\n\n' ;
%	fprintf( fid, prefix );
%	fprintf( fid, '%s\n', stream );
%	fprintf( fid, postfix );
%	gSFpdfOffset.xobjects = [ gSFpdfOffset.xobjects nextObjNum ];
%	generic = 0;
%end

if strcmp( objType, 'pg') 
	lastPage = arg6;


	numPagesHere = gSFpdfOffset.numPagesHere;
	currentPagesObj = gSFpdfOffset.currentPagesObj;


	if numPagesHere == gSFpdfOffset.pagesTreeWidth | lastPage
		% write the allocated kids and count objects
		if lastPage 
			gSFpdfOffset.kidsObj = [ gSFpdfOffset.kidsObj, rg_num2str( nextObjNum ) ' 0 R ' ];
			numPagesHere = numPagesHere + 1;
		end
		if currentPagesObj ~= 0 % make sure it is not happening first time
			%write_pdf_object( fid, [ kidsObj ']' ], 'rs', currentPagesObj+1 );
			%write_pdf_object( fid, rg_num2str( numPagesHere+1 ), 'rs', currentPagesObj+2 );
			objectsStr = [ '\n' rg_num2str( currentPagesObj+1 ) ' 0 obj\n' ...
							'[' gSFpdfOffset.kidsObj ']\nendobj\n'];
			gSFpdfOffset.offset( currentPagesObj + 1 ) = ftell( fid ); 
			fprintf( fid, objectsStr ); % kidsObj done
			objectsStr = [ '\n' rg_num2str( currentPagesObj+2 ) ' 0 obj\n' ...
							rg_num2str( numPagesHere ) '\nendobj\n'];
			gSFpdfOffset.offset( currentPagesObj + 2 ) = ftell( fid ); 
			fprintf( fid, objectsStr ); % countObj done

		end
		numPagesHere = 0;
	end
	if numPagesHere == 0 & ~lastPage
		%write the next pages object and allocate objects to store children and count
		pagesObjNum = length(gSFpdfOffset.offset)+1;
		kidsObjNum = pagesObjNum+1;
		countObjNum = kidsObjNum+1;
		pagesObj = [ '/Type /Pages /Resources 3 0 R /MediaBox[ 0 0 612 792 ] /Kids ' ...
						rg_num2str( kidsObjNum ), ' 0 R /Count ' rg_num2str( countObjNum ) ' 0 R /Parent 2 0 R\n'];
		thisId = write_pdf_object( fid, pagesObj, 'rs', pagesObjNum );
		gSFpdfOffset.pagesObjects = [gSFpdfOffset.pagesObjects, thisId];
		gSFpdfOffset.currentPagesObj = thisId;
		gSFpdfOffset.offset( [kidsObjNum, countObjNum] ) = 0;% allocate object space
		gSFpdfOffset.kidsObj = '';
		numPagesHere = 0;		
	end
	gSFpdfOffset.kidsObj = [ gSFpdfOffset.kidsObj, rg_num2str( nextObjNum ) ' 0 R ' ];
	kidsObj = gSFpdfOffset.kidsObj;

	numPagesHere = numPagesHere+1;
	gSFpdfOffset.numPagesHere = numPagesHere;
	pos = ftell( fid ); %we probably wrote smth to the file. update the 'pos'
	% add /Parent to the page obj
	str = [ str, '\n/Parent ' rg_num2str( gSFpdfOffset.currentPagesObj ) ' 0 R ' ];
	% add /Annots to the page object
	str = [ str, ' /Annots [' ];
	for i = 1:length( gSFpdfOffset.annots )
		str = [ str, rg_num2str( gSFpdfOffset.annots( i ) ) ' 0 R ' ];
	end
	str = [ str, '] '];
	gSFpdfOffset.annots = [];

end


if generic
	fprintf( fid, [prefix str postfix] );
end
gSFpdfOffset.offset(nextObjNum) = pos;
if strcmp( objType, 'sf' ) | strcmp( objType, 'xo' )
	gSFpdfOffset.sf2pdf(id) = nextObjNum;
	gSFpdfOffset.pdf2sf(nextObjNum) = id;
end
if strcmp( objType, 'pg' )
	id = gSFpdfOffset.numPages + 1;
	gSFpdfOffset.pg2pdf(id) = nextObjNum;
	gSFpdfOffset.numPages = gSFpdfOffset.numPages + 1;
	gSFpdfOffset.objectsOnPage{id} = arg5;
end
if strcmp( objType, 'fn' )
	gSFpdfOffset.fontNames = [gSFpdfOffset.fontNames nextObjNum];
end



function write_pdf_header( outFile )
fprintf( outFile, '%s\n', '%PDF-1.2' );
fprintf( outFile, '%s\n', '%‚„œ”' );  % several non-ascii chars to let know that the file is binary   


function write_pdf_trailer( fid, psFontName, psBoldFontName, psItalicFontName, reportStructList )
 
global gSFpdfOffset;

%first, generate the outline
outlineObjNum = pdf_generate_outline( fid, reportStructList );

%write the info dictionary
c = clock;
year = sprintf( '%04d', c(1) );
month = sprintf( '%02d', c(2) );
day = sprintf( '%02d', c(3) );
hour = sprintf( '%02d', c(4) );
minute = sprintf( '%02d', c(5) );
second = sprintf( '%02d', floor(c(6)) );
pdfDate = [year month day hour minute second];

infoObj = ['/Creator (Stateflow ' sf( 'Version' ) ' )' ...
			'\n/CreationDate (D:' pdfDate ')'...
			'\n/Producer (Stateflow ' sf( 'Version' ) ' )' ...
			'\n/Keywords (Stateflow)\n'...
];
infoObjNum = write_pdf_object( fid, infoObj, '', 0 );

% object no 1 is the catalog
catalogObj = ['/Type /Catalog /Pages 2 0 R' ...
	'\n/Dests << '];
for i = 1:gSFpdfOffset.numPages
	dests = gSFpdfOffset.objectsOnPage{i};
	pageObj = gSFpdfOffset.pg2pdf(i);
	for j = 1:length( dests )	
		% here pageObj is the page object num where the SF obj is represented
		catalogObj = [ catalogObj, ...
					'/SFD' rg_num2str(dests(j)) ' [' rg_num2str( pageObj ) ' 0 R /XYZ null null null]\n'...
		];
	end
	% add more destinations: title page and table of contents
	catalogObj = [ catalogObj, ...
				'/SFDTitlePage [' rg_num2str( gSFpdfOffset.pg2pdf(1)) ' 0 R /XYZ null null null]\n'...
				'/SFDTOC [' rg_num2str( gSFpdfOffset.pg2pdf(2)) ' 0 R /XYZ null null null]\n'...
	];
				
end
catalogObj = [ catalogObj '>>\n' ...
				'/Outlines ' rg_num2str( outlineObjNum ) ' 0 R /PageMode /UseOutlines ' ...
];
write_pdf_object( fid, catalogObj, 'rs', 1 );



normalFontDefObj = [ ...
      '/Type /Font\n' , ...
      '/Subtype /Type1\n', ...
      '/Name /NFt\n', ...
      '/BaseFont /' psFontName '\n', ...
   ];
nfObjNum = write_pdf_object( fid, normalFontDefObj, 'fn', 0 );

boldFontDefObj = [ ...
      '/Type /Font\n' , ...
      '/Subtype /Type1\n', ...
      '/Name /BFt\n', ...
      '/BaseFont /' psBoldFontName '\n', ...
   ];
bfObjNum = write_pdf_object( fid, boldFontDefObj, 'fn', 0 );

italicFontDefObj = [ ...
      '/Type /Font\n' , ...
      '/Subtype /Type1\n', ...
      '/Name /IFt\n', ...
      '/BaseFont /' psItalicFontName '\n', ...
   ];
ifObjNum = write_pdf_object( fid, italicFontDefObj, 'fn', 0 );

japaneseFontResourceString = [];
global gSFisJapanese;
if gSFisJapanese
   global gSFpsJapaneseFontName;
   jFontDescriptor = [ ...
      '/Type /FontDescriptor\n', ...
      '/Ascent 723\n', ...
      '/CapHeight 709\n', ...
      '/Descent -241\n', ...
      '/Flags 6\n', ...
      '/FontBBox [-123 -257 1001 910]\n', ...
      '/FontName /' gSFpsJapaneseFontName, '\n', ...
      '/ItalicAngle 0\n', ...
      '/StemV 69\n', ...
      '/XHeight 450\n', ...
      '/Style << /Panose <010502020400000000000000> >>\n', ...
   ];
   jfdObjNum = write_pdf_object( fid, jFontDescriptor, 'fn', 0 );
   
   CIDFont = [ ...
      '/Type /Font\n', ...
      '/Subtype /CIDFontType0\n', ...
      '/CIDSystemInfo << /Registry (Adobe) /Ordering (Japan1) /Supplement 1 >>\n', ...
      '/DW 1000\n', ...
      '/W [\n', ...
      '   1 128 620\n', ...
      ']\n', ...
      '/BaseFont /' gSFpsJapaneseFontName, '\n', ...
      '/FontDescriptor ' rg_num2str(jfdObjNum) ' 0 R\n', ...
   ];
   cidfObjNum = write_pdf_object( fid, CIDFont, 'fn', 0 );
  
   japaneseFontDefObj = [ ...
         '/Type /Font\n' , ...
         '/Subtype /Type0\n', ...
         '/Name /JFt\n', ...
         '/BaseFont /' gSFpsJapaneseFontName '\n', ...
         '/Encoding /90pv-RKSJ-H\n', ... 
			'/DescendantFonts [' rg_num2str(cidfObjNum) ' 0 R]\n', ...
      ];
   jfObjNum = write_pdf_object( fid, japaneseFontDefObj, 'fn', 0 );
   japaneseFontResourceString = [ '/JFt ' rg_num2str( jfObjNum ) ' 0 R\n' ]; 
   nfObjNum = jfObjNum;
end


% object no 3 is the resourses
% rg currently only supports kanji for normal font.  Everything printed
% in bold or italic must be english, or it is garbage.  Currently (R12)
% kanji is not allowed anywhere but comments and text fields of stateflow
% which guarantees that rg will not attempt to print it in italic or bold.
% Should this change, /BFt and /IFt below here should point to japanese
% font objects (similar to /NFt)
%
resObj = ['/ProcSet [/PDF /Text ] \n '...
			'/Font << \n' ...
			'/NFt ' rg_num2str( nfObjNum ) ' 0 R\n' ...
			'/BFt ' rg_num2str( bfObjNum ) ' 0 R\n' ...
         '/IFt ' rg_num2str( ifObjNum ) ' 0 R\n' ...
         japaneseFontResourceString ...
			'>>\n' ...
			'/XObject << \n' ...
];
global gSFreportList;
for i = 1:length( gSFpdfOffset.xobjects )
	resObj = [ resObj, '/SF' rg_num2str( gSFpdfOffset.pdf2sf( gSFpdfOffset.xobjects(i) ) ) ...
				' ' rg_num2str( gSFpdfOffset.xobjects(i) ) ' 0 R\n'];
end
resObj = [ resObj ' >>\n' ];
write_pdf_object( fid, resObj, 'rs', 3 );



pagesObj = ['/Type /Pages /Resources 3 0 R /Count ' rg_num2str( gSFpdfOffset.numPages ) ' /MediaBox[ 0 0 612 792 ] /Kids[ ' ];
for i = 1:length( gSFpdfOffset.pagesObjects )
	pagesObj = [ pagesObj, rg_num2str( gSFpdfOffset.pagesObjects(i) ) ' 0 R ' ];
end
pagesObj = [ pagesObj, '] '];
write_pdf_object( fid, pagesObj, 'rs', 2 );


% object no 4 is the default resources
resObj = ['/ProcSet [/PDF /Text ] \n '...
			'/Font << \n' ...
			'/NFt ' rg_num2str( nfObjNum ) ' 0 R\n' ...
			'/BFt ' rg_num2str( bfObjNum ) ' 0 R\n' ...
         '/IFt ' rg_num2str( ifObjNum ) ' 0 R\n' ...
         japaneseFontResourceString ...
			'>>\n' ...
];

write_pdf_object( fid, resObj, 'rs', 4 );


% allrigth, now do the xref
startxref = ftell( fid );
%xref = [ '\nxref\n' ...
%			'0 ' rg_num2str( length(gSFpdfOffset.offset) + 1 ) '\n' ...
%			'0000000000 65535 f\n'
%		];
% now add all our objects to the trailer
%for i = 1:length( gSFpdfOffset.offset )
%	xref = [ xref sprintf( '%010d', gSFpdfOffset.offset(i) ) ' 00000 n\n' ];
%end
%fprintf( fid, xref );

% now trailer
trailer = [ ...
			'trailer\n' ...	
			'<< /Size ' rg_num2str( length(gSFpdfOffset.offset) + 1 ) '\n' ...
			'/Info ' rg_num2str( infoObjNum ) ' 0 R\n' ...
			'/Root 1 0 R >>\n' ...
			'startxref\n'...
			rg_num2str( startxref ) '\n' ...
			'%%EOF'...
];
fprintf( fid, trailer );
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to draw graphic primitives in PDF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stream = pdf_draw_text( pos, fs, t )

% create the stream
stream = [ ' BT /NFt ' rg_num2str( fs ) ' Tf ' rg_num2str(pos(1)) ' ' rg_num2str(pos(2)) ' Td '];
for j = 1:length(t)
   stream = [ stream ' 0 ' rg_num2str(-fs*1.2*(j>1)) ' Td ' ...
   '(' ps_string(t{j}) ') Tj ' ];
end
stream = [ stream ' ET ' ];



function pdf_add_link( fid, rect, dest )
%return;
% fid: id of the pdf file
% rect: rect on the page
% dest: SF id number (assumed that this obj is reported)

stream = [...
			' /Type /Annot /Subtype /Link ' ...
			'/Rect [' rg_num2str( floor(rect(1)) ) ' ' rg_num2str( floor(rect(2)) ) ' ' ...
			rg_num2str( ceil(rect(3)) ) ' ' rg_num2str( ceil(rect(4)) ) '] ' ...
			'/Border [0 0 0] /H /O /Dest /SFD' rg_num2str( dest ) ' '...
]; 

annNum = write_pdf_object( fid, stream, 'ln', 0 );

%now register this annotation with the current page
global gSFpdfOffset;
gSFpdfOffset.annots = [ gSFpdfOffset.annots annNum ];

%
%  this function is never called
%  comment out, but leave in file
%
%function pdf_add_pic_link( fid, rect, dest, cmstr )
% fid: id of the pdf file
% rect: rect on the page
% dest: SF id number (assumed that this obj is reported)
%global gSFpdfOffset;
%stream = [...
%			' /Type /Annot /Subtype /Link ' ...
%			'/Rect [' rg_num2str( floor(rect(1)) ) ' ' rg_num2str( floor(rect(2)) ) ' ' ...
%			rg_num2str( ceil(rect(3)) ) ' ' rg_num2str( ceil(rect(4)) ) '] ' ...
%			'/Border [0 1 1] /Dest /SFD' rg_num2str( dest ) ' '...
%]; 
%appStr = ['' cmstr ' cm /SF' rg_num2str(dest) ' Do\n'];
%%stream = [ stream ...
%%				'/AP << /R << /Length ' rg_num2str( length( appStr ) ) ' <<\n'...
%%				appStr '\n>> >> >>\n' ...
%%			];
%stream = [ stream ...
%				'/AP << /R ' rg_num2str( gSFpdfOffset.sf2pdf(dest) ) ' 0 R >>' ...
%			];

%annNum = write_pdf_object( fid, stream, 'ln', 0 );

%now register this annotation with the current page
%global gSFpdfOffset;
%gSFpdfOffset.annots = [ gSFpdfOffset.annots annNum ];



function objNum = pdf_generate_outline( fid, list )

global gSFpdfOffset;
% we don't want transitions in the outline. Go through
% the list and remove them
transType = type2num( 'transition' );
toRemove = [];
for i = 1: length( list )
	if transType == whoami( list( i,1) )
		%it is a transition
		toRemove = [ toRemove, i ];
	end
end	
list( toRemove, : ) = [];

prevLevel = 0;
len = length( list( :,1) );
%reserve a number of objects numbers for the outline
begNum = length(gSFpdfOffset.offset)+1;
gSFpdfOffset.offset( begNum:begNum+len ) = 0;

rootNum = begNum;
nextId = 1; % the entry in the list
% add (0,0) to the end of the list to mean the end
list( length(list(:,1))+1,: ) = [ -1, -1 ];
% add the title page and the table of contents
titlePageNoteId = sf( 'new', 'note' );
sf('set', titlePageNoteId, '.labelString', '_sfRG:pdf outline object:Title Page:SFDTitlePage');
tocNoteId = sf( 'new', 'note' );
sf('set', tocNoteId, '.labelString', '_sfRG:pdf outline object:Table of Contents:SFDTOC' );
list = [ [titlePageNoteId, 0];[tocNoteId, 0]; list ];

[lastChild veryLastChild] = traverse_outline( fid, nextId, begNum, list, 0 ); 	

%free the possibly allocated object numbers
gSFpdfOffset.offset( begNum+veryLastChild:end ) = [];
%write the outlines object
len = length( list( :,1) );
% OK, only entries with depth 0 will be visible
outlineCount = sum( list( :,2) == 0 );
stream = [ '/Count ' rg_num2str(outlineCount) ... % we added [-1,-1] to mean the end of the thing to the end
			'\n/First ' rg_num2str( begNum + nextId ) ' 0 R'...
			'\n/Last ' rg_num2str( begNum + lastChild ) ' 0 R\n'
];
objNum = write_pdf_object( fid, stream, 'rs', begNum );


function [myI, i, numImmediateChildren] = traverse_outline ( fid, nextId, begNum, list, prevDepth )  %recursive
%result returned is [ last node of the same level, farthest node ]

i = nextId;
prev = 0;
% special case for i == 1 (set prev to the TOC)
if i == 1
	prev = i - 1;
end
returnNext = 0;
numImmediateChildren = 0;
while i < length( list(:,1) )
	numImmediateChildren = numImmediateChildren +1;
	stream = '';
	depth = list( i, 2 );
	id = list( i, 1 );
	myI = i;
	nextDepth = list( (i+1), 2 );
	if depth < nextDepth %next object is my child
		[sameLevelEndI endI numChildren] = traverse_outline( fid, i+1, begNum, list, depth ); % outline him and children
		% report this object (all of the children are reported
		stream = ['/Count -' rg_num2str( numChildren )...rg_num2str( endI - myI )...
					' /First ' rg_num2str( i+1 + begNum ) ' 0 R' ...
					'\n/Last ' rg_num2str( sameLevelEndI + begNum ) ' 0 R\n' ...
		];
		i = endI;
		% update the nextDepth info
		if i < length( list(:,1) )
			nextDepth = list( (i+1), 2 );
		else
			nextDepth = 0;
			returnNext = 1;
		end
	end
	%add common fields
	parentStr = [ '/Parent ' rg_num2str( begNum+nextId-1 ) ' 0 R' ];
	% do special case for title page and table of contents note objects
	pdfTitleStr = '';
	pdfDestStr = '';
	myType = whoami( id );
	if myType == type2num( 'note' ) 
		label = sf( 'get', id, '.labelString' );
		if length( label ) >= 5 & strcmp( label(1:5),'_sfRG' )
			%OK, its special
			sepChar = label(6);
			label = label( 7:end );
			columnPos = findstr( label, sepChar );
			labelType = label( 1: columnPos(1)-1 );
			if strcmp( labelType, 'pdf outline object' )
				pdfTitleStr = ['\n/Title (' label(columnPos(1)+1:columnPos(2)-1) ')' ];
				pdfDestStr = [ '\n/Dest /' label(columnPos(2)+1:end) ];
			end
		end
	end
	if isempty(pdfTitleStr) & isempty(pdfDestStr) 
		pdfDestStr = [ '\n/Dest /SFD' rg_num2str( id ) ];
		pdfTitleStr = [	'\n/Title (' get_sf_obj_name(id) ') ' ];
	end

	stream = [ stream parentStr pdfTitleStr pdfDestStr ];
	parentStr = ''; pdfTitleStr = ''; pdfDestStr = '';
	if prev 
		stream = [ stream '\n/Prev ' rg_num2str( begNum+prev ) ' 0 R ' ];
	end
	if depth == nextDepth | nextDepth > prevDepth % next one is my sibling
		stream = [ stream '\n/Next ' rg_num2str( begNum+i+1 ) ' 0 R ' ];
		prev = myI;
	end

	
	write_pdf_object( fid, stream, 'rs', begNum + myI );

	if depth>nextDepth & nextDepth <= prevDepth
		return;	
	elseif i < length( list( :,1) )
		i = i + 1; %  go to the next obj in the next while loop iteration
	end
	
end


function pdf_rec_obj( id, stream )
global gSFpdfOffset;
nextId = length( gSFpdfOffset.sfObjectDesc )+1;
gSFpdfOffset.sfObjectDesc{ nextId } = stream;
gSFpdfOffset.sfObjectMap( id ) = nextId;


function stream = pdf_get_obj( id )
global gSFpdfOffset;
stream = gSFpdfOffset.sfObjectDesc{ gSFpdfOffset.sfObjectMap(id) };


function res = rg_handle_link_block(action, ID)
persistent BLOCK_ID;
persistent CHART_ID;

res = [];
switch action
case 'get',
   if isempty( CHART_ID )
      error( 'CHART_ID not initialized');
   end
   if isequal( ID, CHART_ID(1)  )
      res = BLOCK_ID(1);
      BLOCK_ID(1) = [];
      CHART_ID(1) = [];
   else
      error( 'Getting wrong block id');
   end
case 'set',
   % remember ids and return chart_ids as the result
   count = 1;
   BLOCK_ID = [];
   CHART_ID = [];
   for id = ID
      BLOCK_ID(count) = id;
      ref = get_param(id, 'ReferenceBlock');
      refH = get_param(ref, 'handle');
      
      instanceId = sf('find','all','instance.simulinkBlock',refH);
      if ~isempty( instanceId )
         CHART_ID(count) = sf('get', instanceId, 'instance.chart' );
      else
         % the instance is not in memory, so there will be no link to it
         % to do that,we have to put a valid stateflow id here, which will
         % not be reported.
         % we can use the id of the state that is always in memory (5)
         CHART_ID(count) = 5;   %
      end
      count = count+1;
   end   
   res = CHART_ID;
otherwise
   error (['Unexpected action:', action]);
end

function p = get_full_path_of_block(blk)

parent = get_param( blk, 'Parent' );
p = get_param( blk, 'Name' );
if ~isempty( parent )
   p = [ parent '/' p ];
end





