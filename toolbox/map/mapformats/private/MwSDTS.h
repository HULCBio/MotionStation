#ifndef MwSDTS_H
#define MwSDTS_H

#include <string>
#include <builder/sb_Accessor.h>

using namespace std;

// This class is implemented as a base class for acessing
// SDTS data sets. 
// The member data are information about the data set that 
// are obtained from the "Identification module and are hence
// information that are independent of the actual SDTS profile.  
// 
class MwSDTS
{

 public:

  MwSDTS();
  MwSDTS(const string &filename);
  ~MwSDTS();

  // Opens the catalog file for the dataset.
  bool open(const string &filename);

  // Reads information from the Identification module.
  bool loadInfo();
 
  // Accesses the error message when a failure occurs.
  string const& getErrMsgTxt() const;
  
 protected:

  sb_Accessor  *moduleFiles;

  string _catdFilename;

  string _title;
  string _profileID;
  string _profileVer;
  string _mapDate;
  string _creationDate;

  string _errMsgTxt;
  bool   _isOpen;
};
#endif //MwSDTS_H

