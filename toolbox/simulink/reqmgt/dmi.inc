// $Revision: 1.1.6.2 $
// dmi.inc
//
// Version 2.4
//
// Copyright (c) 1998 Quality Systems & Software, Inc.

/*
DOORS/MATLAB interface functions

Contains function definitions for all services provided by DOORS/MATLAB
interface.
*/

/* Version History:

Version		Date		Who		Comments
-------		----		---		--------
1.0		27 July 98	GEP		First draft.
1.1		28 July 98	GEP		Revised skip list handling.
1.2		6  Aug	98	GEP		Implemented persistent skip list.
1.3		21 Aug	98	GEP		Added link indicator to return on dmiSendObject_
1.4		21 Aug	98	GEP		Added dmiSelectBlock_ (DOORS->MATLAB)
1.4.1		14 Sep	98 	MAG		Change quotes to "MATLAB quotes" (apostrophes) in 
						dmiSelectBlock_.  Change all MatLabs to MATLABs.  
Changed
						file addins.idx to MATLAB/Simulink from MatLab.
1.5		23 Sep 98	GEP		Added persistence to DOORS->MATLAB session
						and added handling of double slashes in names.
1.5.1		23 Sep 98	GEP		Changed double slashes to single in block name.
1.5.2		24 Sep 98	GEP		Changed dmiSelectBlock_ to pass block path name.
1.5.3		24 Sep 98 	GEP 		Added command to make MATLAB visible.
1.5.4		25 Sep 98	GEP		Fixed peristence problem of DOORS/MATLAB session.
						Removed command to make MATLAB visible.
1.5.5		29 Sep 98	GEP		Correct attr check in dmiSelectBlock_.
1.5.6		28 Oct 98	GEP		Switched from identifier to absolute number.
  						Added skip list clear function.
						Added debug option.
1.6		29 Oct 98	GEP		Conditionally loads DMI view to preserve size/pos.
						Connects/disconnects to Matlab on select block to 
						avoid potentially stale handles.
1.7		4 Nov 98	GEP		Maintains open connection to Matlab to avoid
						shutdown of Matlab.
1.8		17 Feb 98	GEP		Added connection retry if Matlab handle is stale.
						Prevent select block operation if block deleted.
2.0		13 Aug 99	MAG		Add itemName parameter to dmiSendObject_.
						Make dmiGetBlockName_ obsolete.
2.1		19 Aug 99	GEP		Added dmiRunSimulation_ functionality.
						Added last modified date param to dmiSendObjectEnd_.
2.2		23 Aug 99	MAG		Minor changes to get last changes working.
2.3		 8 Sep 99	MAG		Add support for replacing linefeeds with spaces 
						in dmiEscapeQuotes_.  Some restructuring by John Norris.  Remove
						obsolete code.
2.4		 8 Sep 99	MAG		Display results of running a simulation.
*/

Module dmiSurrogateM_ = null
Skip   dmiSurrogateS_ = createString
Object dmiPrevObjPtr_ = null
OleAutoObj dmiMatlab_ = null
string dmiResult_     = null
DB dmiSimulationDB_   = null
DBE dmiScriptDBE_     = null
DBE dmiResultsDBE_    = null

const string DMI_BLOCK_NAME_ATTR_ = "Object Heading"
const string DMI_BLOCK_PATHNAME_ATTR_ = "Block Name"
const string DMI_BLOCK_NAME_TITLE_ = "Block Name"
const string DMI_BLOCK_TYPE_ATTR_ = "Block Type"
const string DMI_BLOCK_DELETED_ATTR_ = "Block Deleted?"
const string DMI_VIEW_ = "DOORS MATLAB Interface"
const string DMI_SIMULATION_SCRIPT_ATTR_ = "Simulation Script"
const string DMI_SIMULATION_RESULTS_ATTR_ = "Simulation Results"
const string DMI_LAST_SYNC_DATE_ = "Last Synchronization Date"
const bool DMI_DEBUG_ = false


void debug(string msg) {
  if (DMI_DEBUG_) {
    print msg
  }
}

/************** MATLAB Services **************/

void dmiCreateSurrogate_(string modelName) {

  debug "\nCreating surrogate module..."

  // Create surrogate module

  dmiSurrogateM_ = create(modelName, modelName, "", 1)

  // Create required attributes

  current = dmiSurrogateM_ 

  if (! exists attribute DMI_BLOCK_NAME_ATTR_) {
    create object type "string" attribute DMI_BLOCK_NAME_ATTR_
  }
  if (! exists attribute DMI_BLOCK_PATHNAME_ATTR_) {
    create object type "text" attribute DMI_BLOCK_PATHNAME_ATTR_
  }
  if (! exists attribute DMI_BLOCK_TYPE_ATTR_) {
    create object type "string" attribute DMI_BLOCK_TYPE_ATTR_
  }
  if (! exists attribute DMI_BLOCK_DELETED_ATTR_) {
    create object type "boolean" attribute DMI_BLOCK_DELETED_ATTR_
  }
  if (! exists attribute DMI_SIMULATION_SCRIPT_ATTR_) {
    create module type "text" attribute DMI_SIMULATION_SCRIPT_ATTR_
  }
  if (! exists attribute DMI_SIMULATION_RESULTS_ATTR_) {
    create module type "text" attribute DMI_SIMULATION_RESULTS_ATTR_
  }
  if (! exists attribute DMI_LAST_SYNC_DATE_) {
    create module type "string" attribute DMI_LAST_SYNC_DATE_
  }

  // Save attribute definitions
  
  save dmiSurrogateM_

  // Create DMI view

  width(column 0,100)
  justify(column 0,right)
   
  title(column 1,DMI_BLOCK_NAME_TITLE_)
  width(column 1,300)
  justify(column 1,left)
    
  attribute(insert column 2,DMI_BLOCK_TYPE_ATTR_)
  width(column 2,100)
  justify(column 2,left)

  attribute(insert column 3,DMI_BLOCK_DELETED_ATTR_)
  width(column 3,100)
  justify(column 3,center)

  save view DMI_VIEW_

  debug "done."

}

Object dmiCreateObject_(Module m, int lvl, Object prevObj) {

  debug "\nCreating object..."

  current = m
  if (null prevObj) return create m
  if (lvl > level prevObj) return create below prevObj
  // Level new object <= level of previous object
  while (lvl != level prevObj) {
    prevObj = parent prevObj
  }
  return create after prevObj

  debug "done."
}

void dmiUpdateHierarchy_(Object curObj, int newLevel, Object prevObj) {
  
  debug "\nUpdating hieararchy..."

  current = module curObj
  if (null prevObj && curObj != first current Module) {
    move(curObj,after first current Module)	// Move curObj to level 1	
    move(first current Module, after curObj)	// Move curObj to first level 1.
  } else if (level curObj != newLevel || previous curObj != prevObj) {
    if (newLevel > level prevObj) move(curObj,below prevObj)
    else {
      while (newLevel != level prevObj) {
        prevObj = parent prevObj
      }
      move(curObj,after prevObj)
    }
  }

  debug "done."

}

void clear(Skip s) {
  Object value
  for value in s do {
    delete(s,(string key s))
  }
}

void dmiInitSurrogateS_(){

  debug "\nInitializing surrogate list..."

  // Clear surrogate list
  clear dmiSurrogateS_

  current = dmiSurrogateM_

  // Initialize surrogate list
  filtering off; outlining off; level 0
  Object o
  for o in dmiSurrogateM_ do {
    string id = o."Absolute Number"
    Buffer b = create
    b += id
    put(dmiSurrogateS_,stringOf(b),o)
  }

  debug "done."

}

void dmiInitSurrogate_(string modelName, bool createSurrogate) {

  debug "Initializing surrogate module..."

  // Check if a project is open
  if (null current Project) {
    oleSetResult("DMI Error: You must first open a DOORS project!")
    halt
  }
  // Check if surrogate exists
  if (! exists module modelName) {
    if (createSurrogate) {
      dmiCreateSurrogate_(modelName)
    } else {
      oleSetResult("DMI Error: Model " modelName " has not been exported to
DOORS!")
      halt
    }
  }
  dmiSurrogateM_ = edit modelName
  dmiInitSurrogateS_

  // Display DMI view
  current = dmiSurrogateM_
  if (currentView current Module != DMI_VIEW_) {
    load view DMI_VIEW_
  }
  oleSetResult("")

  debug "done."
}

bool dmiHasLinks_(Object o) {
  // Check for outgoing links
  Link l
  for l in o->"*" do return true
  // Check for incoming links
  string s
  for s in o<-"*" do return true
  return false
}

void dmiSendObjectStart_(string modelName) {
  dmiInitSurrogate_(modelName,true)
  dmiPrevObjPtr_ = null
  oleSetResult("")
}

void dmiSendObject_(string doorsId, string blockName, string blockType, int blockLevel, string itemName) {

  current = dmiSurrogateM_

  Object o
  if (null doorsId || ! find(dmiSurrogateS_,doorsId,o)) {
    o = dmiCreateObject_(dmiSurrogateM_,blockLevel,dmiPrevObjPtr_)
  } else {
    dmiUpdateHierarchy_(o,blockLevel,dmiPrevObjPtr_)
    delete(dmiSurrogateS_,doorsId)
  }
  o.DMI_BLOCK_PATHNAME_ATTR_ = blockName
  o.DMI_BLOCK_NAME_ATTR_ = itemName
  o.DMI_BLOCK_TYPE_ATTR_ = blockType
  o.DMI_BLOCK_DELETED_ATTR_ = false

  string id = o."Absolute Number"
  if (dmiHasLinks_ o) oleSetResult(id ",true")
  else oleSetResult(id ",false")
  
  dmiPrevObjPtr_ = o

}

void dmiSendObjectEnd_(string syncDate) {

  current = dmiSurrogateM_

  Object o
  for o in dmiSurrogateS_ do {
    o.DMI_BLOCK_DELETED_ATTR_ = true
  }
  
  dmiSurrogateM_.DMI_LAST_SYNC_DATE_ = syncDate
   
  refresh dmiSurrogateM_
  // Now clear surrogate list
  clear dmiSurrogateS_
  oleSetResult("")
}

void dmiSelectObjectStart_(string modelName) {

  dmiInitSurrogate_(modelName,false)
  
  // Clear display set of surrogate

  current = dmiSurrogateM_

  filtering off; outlining off; level 0
  Object o
  for o in dmiSurrogateM_ do {
    reject o
  }
  oleSetResult("")
}

void dmiSelectObject_(string doorsId) {

  current = dmiSurrogateM_

  Object o
  if (find(dmiSurrogateS_,doorsId,o)) {
    accept o
    current = o
    read(fullName(current Module), true)
  } else {
    oleSetResult("DMI Error: DOORS Id '" doorsId "' not found!")
    halt
  }
  oleSetResult("")
}

void dmiSelectObjectEnd_() {

  current = dmiSurrogateM_

  //filtering on
  refresh dmiSurrogateM_
  clear dmiSurrogateS_
  oleSetResult("")
}

void dmiGetModifiedDate_(string modelName) {
  dmiInitSurrogate_(modelName,false)
  oleSetResult(dmiSurrogateM_.DMI_LAST_SYNC_DATE_ "")
}

/************** DOORS Services **************/

void dmiMatlabConnect_() {

  if (null dmiMatlab_) {
    dmiMatlab_ = oleCreateAutoObject("Matlab.Application")
    if (null dmiMatlab_) {
      ack "DMI Error: Can't connect to MATLAB"
      halt
    }
  }
  // Check if connection is live; if not, retry connect
  string msg = oleMethod(dmiMatlab_,"Execute")
  if (! null msg) {
    if (! confirm("DMI Error: Failed to connect to Matlab.\nWould you like
to try again?")) halt
    dmiMatlab_ = null
    dmiMatlabConnect_()
  }
  return
}

void dmiMatlabExecute_(OleAutoObj mObj, string function) {
  //print function

  OleAutoArgs arglist = create
  string msg = null
  dmiResult_ = null
  put(arglist,function)
  msg = oleMethod(mObj,"Execute",arglist,dmiResult_)
  delete arglist
  if (! null msg) {
    ack "DMI Error: " msg
    halt
  }
  if (! null dmiResult_) {
    if (matches("^DMI Error:",dmiResult_)) {
      ack dmiResult_
      halt
    }
  }

  return
}


string dmiEscapeDoubleQuotes_(string s) {
  string new = ""

  while (matches("\"",s)) {
    new = new s[0:start(0)-1] "\\\""
    s = s[start(0)+1:]
  }
  new = new s

  return new
}


string dmiCRLF2space_(string s) {
  string new = ""
  while (matches("\n",s)) {
    new = new s[0:start(0)-1]" "
    s = s[start(0)+1:]
  }
  new = new s
  return new
}

void dmiSelectBlock_(Object o) {

  if (! exists attribute DMI_BLOCK_PATHNAME_ATTR_) {
    ack "DMI Error: This function may only be used from within a MATLAB
module"
    halt
  }

  
  if (null o) {
    ack "DMI Error: No object is selected in module '" (module o)."Name" "'"
    halt
  }

  
  if (o.DMI_BLOCK_DELETED_ATTR_ "" == "True") {
    ack "DMI Error: Block '" o.DMI_BLOCK_NAME_ATTR_ "' has been deleted
from MATLAB model"
    halt
  }

string AbsNum = o."Absolute Number"
string BlockPath = o.DMI_BLOCK_PATHNAME_ATTR_
string command = "dmiSelectBlock_('"
command = command AbsNum
command = command "','"
command = command BlockPath
command = command "')"
command = (dmiEscapeDoubleQuotes_(command))
command = (dmiCRLF2space_(command))
command = "dmiMatlabConnect_(); dmiMatlabExecute_(dmiMatlab_,\"" command "\")"
evalTop_ command

//  evalTop_ "dmiMatlabConnect_();
//            dmiMatlabExecute_(dmiMatlab_,\"dmiSelectBlockStart_('" (module o)."Name" "')\");
//            dmiMatlabExecute_(dmiMatlab_,\"dmiSelectBlock_('" o."Absolute Number" "','" o.DMI_BLOCK_PATHNAME_ATTR_ "')\");
//            dmiMatlabExecute_(dmiMatlab_,\"dmiSelectBlockEnd_\")"
}

string dmiEscapeQuotes_(string s) {
  // Quote apostrophes with an apostrophes.
  string new = ""
  while (matches("'",s)) {
    new = new s[0:start(0)] "'"
    s = s[start(0)+1:]
  }
  new = new s

  // Replace linefeeds with spaces.
  s = new
  new = ""
  while (matches("\n",s)) {
    new = new s[0:start(0)-1]" "
    s = s[start(0)+1:]
  }
  new = new s

  return new
}

void dmiRun_(DB dmiDB_) {
   string script = get dmiScriptDBE_
   if (null script) {
     ack ("DMI Error: You must provide a simulation script")
     return
   }
          
    // Save simulation script 
    (current Module).DMI_SIMULATION_SCRIPT_ATTR_ = script
    
    // Run simulation
    string command = "dmiRun_('" (current Module)."Name" "','" (dmiEscapeQuotes_(script)) "');"
    dmiMatlabExecute_(dmiMatlab_, command)

    // Save simulation results
////    (current Module).DMI_SIMULATION_RESULTS_ATTR_ = dmiResult_ 
////    set (dmiResultsDBE_ , dmiResult_)

 	 if(! null dmiResult_) {
      // Error
      (current Module).DMI_SIMULATION_RESULTS_ATTR_ = dmiResult_ 
      set (dmiResultsDBE_ , dmiResult_)
    }
    else {
      // Success
      (current Module).DMI_SIMULATION_RESULTS_ATTR_ = oleGetResult 
      set (dmiResultsDBE_ , oleGetResult)
    }
}    


   void dmiRunSimTop_ () {

        current = dmiSurrogateM_  //set current module
        
  if (! exists attribute DMI_BLOCK_PATHNAME_ATTR_) {
    ack "DMI Error: This function may only be used from within a MATLAB module"
    halt
  }

 //clear previous run

 (current Module).DMI_SIMULATION_RESULTS_ATTR_ = ""

  //connect to matlab - evalTop needed to keep active connection

 if (null dmiMatlab_) {
    dmiMatlabConnect_()
 }
 
  dmiSimulationDB_ = create "Run MATLAB Simulation"
  dmiScriptDBE_ = text(dmiSimulationDB_,"Simulation script:",(current Module).DMI_SIMULATION_SCRIPT_ATTR_ "",500,150,false)
  dmiResultsDBE_ = text(dmiSimulationDB_,"Simulation results:",(current Module).DMI_SIMULATION_RESULTS_ATTR_ "",500,150,true)
  
  apply(dmiSimulationDB_,"Run",dmiRun_)
  show dmiSimulationDB_
}
  
   void dmiRunSimulation_() {
      dmiSurrogateM_ = current Module
      evalTop_ "dmiRunSimTop_ ()"

   }//end dmiRunSimulation

