		Property Saver v 1.3.1 for LabVIEW 7.1
		August 12, 2004


Property Saver is free software. It is made in the hope it will be useful for
LabVIEW community. You can use, modify and redistribute it free of charge
providing that the original copyright notices are kept. NO WARRANTIES of any kind
are expressed or implied. The developer will not be liable for data loss, damages,
loss of profits or any other kind of loss while using or misusing this software.


=== What's new in the version 1.3.1 (LV 7.1) ===

- Fixes a problem of Caption property that caused by changed behavior in LV 7.1.
- Supports new RadioButtonsControl class.


=== What's new in the version 1.2.3b (LV 7.0) ===

- Works faster on properties of graph classes.
- Extended syntax to specify denied (-) and additional (+) properties to read/write.
(not documented yet)


=== What's new in the version 1.2.2 (LV 7.0) ===

- Independently treats properties of Plot and Cursor classes
- Allows to deny undesired properties to read and write.
- Supports non-consequent values for Ring control class.
- Supports DSCTag class
- fixes bugs in treatment of WaveformGraph, GraphChart and ListBox classes.
- etc.


=== What's new in the version 1.2.1 (LV 7.0) ===

- Supports new control classes provided in LabVIEW 7.0
- Supports recursive treatment of element's properties in clusters and arrays.
- Supports an extended set of control properties.
- Uses new method to specify default properties for control classes.
- Provides more convenient way to review syntax of supported property specifiers.
- Provides more informative error messaging.
- Contains new and updated examples.
- Contains new utility VIs.
- Does not treat ActiveXContainer class' specific properties in order to simplify
  adaptation for non-Windows platforms.
- etc.


=== Installation ===

1) Copy "PropSaver" folder to "<LabVIEW>\user.lib" directory.
2) Copy "errors\PropSaver-errors.txt" file to "<LabVIEW>\user.lib\errors" directory.


=== Examples ===

You can find examples of using Property Saver in "PropSaver\Examples.llb"


=== Documentation ===

See VI's descriptions in order to get information on use. No another kind of
documentation is provided in the current release.



Copyright 2003,2004 Konstantin Shifershteyn

Web:	www.kshif.com
E-mail:	kostya@kshif.com
