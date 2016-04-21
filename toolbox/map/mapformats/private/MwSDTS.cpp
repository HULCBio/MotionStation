
#include "MwSDTS.h"
#include <builder/sb_Iden.h>


MwSDTS::MwSDTS():
  _isOpen(false)
{}


MwSDTS::MwSDTS(const string &filename):
  _catdFilename(filename)
{
  _isOpen = open(_catdFilename);
}

MwSDTS::~MwSDTS()
{
  delete moduleFiles;
}

bool MwSDTS::open(const string &filename)
{
  if (_isOpen)
    return true;

  _catdFilename=filename;
  moduleFiles = new sb_Accessor;
  _isOpen = moduleFiles->readCatd(_catdFilename);
  
  if (!_isOpen)
    _errMsgTxt = "Could not read Module files.";

  return  _isOpen;
}


bool MwSDTS::loadInfo()
{
  sb_Iden idenMod;

  if (!moduleFiles->get(idenMod)) {
    _errMsgTxt = "Cannot access Identification Module!";
    return false;
  }

  idenMod.getTitle(_title);
  idenMod.getProfileIdentification(_profileID);
  idenMod.getProfileVersion(_profileVer);
  idenMod.getMapDate(_mapDate);
  idenMod.getDataSetCreationDate(_creationDate);

  return true;
}

string const& MwSDTS::getErrMsgTxt() const
{
  return _errMsgTxt;
}
