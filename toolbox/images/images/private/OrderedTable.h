//
// Copyright 1993-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/01/26 05:57:37 $
//

#ifndef ORDERED_TABLE_H
#define ORDERED_TABLE_H

class OrderedTable
{
  public:
    OrderedTable(const double *newTable, int newTableLength);

    int findPosition(double value);

  private:
    const double *fTable;
    int           fTableLength;
    int           fLastPosition;

    void          setTable(const double *newTable);
    void          setTableLength(int newTableLength);
    void          setLastPosition(int newLastPosition);

    inline int           getLastPosition(void);
    inline const double *getTable(void);
    inline int           getTableLength(void);

    inline void   huntUp(const double * table, int tableLength, double value, int * low, int * high);
    inline void   huntDown(const double * table, int tableLength, double value, int * low, int * high);
    inline int    bisectionSearch(const double * table, int tableLength, double value, int low, int high);

};

#endif // ORDERED_TABLE_H
