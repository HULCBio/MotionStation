<script>
<!--
// set focus to first text element of first form in the page
function sf(){
var i; //must declare local loop counter to avoid default global declaration
var elementsArray = document.forms[0].elements;
for(i=0; i < elementsArray.length; i++) {
  if ((elementsArray[i].type == "text") && ((elementsArray[i].name != "Model"))) {
    elementsArray[i].focus();
    break;    
  }
 }
}

//set initial state for each selection element in the page
function initiateState() {
var i;
var elementsArray = document.forms[0].elements;
for (i=0; i< elementsArray.length; i++) {
  if ((elementsArray[i].type == "select-one") ) {
    elementsArray[i].click();
  }
}  
}

//translate special characters into escape sequence
function subEncode(srcString) {
  var srcList = new Array('z', '(', ')', '?', '&', '$', '|', '^', '{' , '}','\'','\"','\\', '[', ']', '/', '#', '<', '>', '.', '+', '=', '~', '@', '%', '`', ',');
  var dstList = new Array('z0','z1','z2','z3','z4','z5','z6','z7','z8','z9','za','zb','zc','zd','ze','zf','zg','zh','zi','zj','zk','zl','zm','zn','zo','zp','zq');
  var dstString;
  var i; //must declare local loop counter to avoid default global declaration
  dstString = '';
  for (i=0; i < srcString.length; i++) {
   c = srcString.charAt(i);
   newc = c;
   for (j=0; j < srcList.length; j++) {
     if (c==srcList[j]) {
       newc = dstList[j];
       }
     }
   dstString+= newc;
   }
  return dstString;
}
  
// encode each "text" field of the form
function htmlEncode(form) {
var elementsArray = form.elements;
var i; //must declare loop counter to avoid default global declaration
for(i=0; i < elementsArray.length; i++) {
  if ((elementsArray[i].type == "text") || (elementsArray[i].type == "select") || (elementsArray[i].type == "submit")) {
    elementsArray[i].value=subEncode(elementsArray[i].value);
  }
}
//  form.MatchCase.click();
}

// make sure only one parameter is checked on update paramater page
function uncheckOthers(form, thischeckbox) {
var elementsArray = form.elements;
var i; //must declare loop counter to avoid default global declaration
if (thischeckbox.checked) {
  for(i=0; i < elementsArray.length; i++) {
    if (elementsArray[i].type == "checkbox") 
      if ((elementsArray[i].checked) && (elementsArray[i].name.substring(0,12)=="paramChecked") && (elementsArray[i].name != thischeckbox.name)) {
        elementsArray[i].checked=false;
      }
    }
  }
}

// select/unselect all found objects in the table
function selectAll(form, select) {
var elementsArray = form.elements;
var i; //must declare loop counter to avoid default global declaration
for(i=0; i < elementsArray.length; i++) {
  if (elementsArray[i].type == "checkbox")  {
    if (select)
      elementsArray[i].checked=true
    else
      elementsArray[i].checked=false
  }
}
}

// -->
</script>