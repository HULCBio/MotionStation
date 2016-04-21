                                README

           Java(TM) 2 Runtime Environment, Standard Edition
                            Version 1.4.2
                          

The Java(TM) 2 Runtime Environment is intended for software developers 
and vendors to redistribute with their applications.

The Java 2 Runtime Environment contains the Java virtual machine, 
runtime class libraries, and Java application launcher that are 
necessary to run programs written in the Java programming language. 
It is not a development environment and does not contain development 
tools such as compilers or debuggers.  For development tools, see the 
Java 2 SDK, Standard Edition.


=======================================================================
     Deploying Applications with the Java 2 Runtime Environment
=======================================================================

When you deploy an application written in the Java programming 
language, your software bundle will probably consist of the following 
parts: 

            Your own class, resource, and data files. 
            A runtime environment. 
            An installation procedure or program. 

You already have the first part, of course. The remainder of this
document covers the other two parts. See also the Notes for Developers 
page on the Java Software website:

     http://java.sun.com/j2se/1.4.2/runtime.html

-----------------------------------------------------------------------
Runtime Environment
-----------------------------------------------------------------------

To run your application, a user needs the Java 2 Runtime Environment, 
which is freely available from Sun for application developers to 
redistribute.

The final step in the deployment process occurs when the software is 
installed on individual user system. Installation consists of copying 
software onto the user's system, then configuring the user's system 
to support that software.  You should ensure that your installation 
procedure does not overwrite existing JRE installations, as they may 
be required by other applications.


=======================================================================
         Redistribution of the Java 2 Runtime Environment
=======================================================================

The term "vendors" used here refers to licensees, developers, and 
independent software vendors (ISVs) who license and distribute the 
Java 2 Runtime Environment with their programs.

Vendors must follow the terms of the Java 2 Runtime Environment Binary 
Code License agreement.

-----------------------------------------------------------------------
Required vs. Optional Files
-----------------------------------------------------------------------  
The files that make up the Java 2 Runtime Environment are divided into 
two categories: required and optional.  Optional files may be excluded 
from redistributions of the Java 2 Runtime Environment at the 
licensee's discretion.  

The following section contains a list of the files and directories that 
may optionally be omitted from redistributions with the Java 2 Runtime 
Environment.  All files not in these lists of optional files must be 
included in redistributions of the runtime environment.


-----------------------------------------------------------------------
Optional Files and Directories
-----------------------------------------------------------------------
The following files may be optionally excluded from redistributions:

lib/charsets.jar                  
   Character conversion classes
jre/lib/ext/ 
   sunjce_provider.jar - the SunJCE provider for Java 
     Cryptography APIs
   localedata.jar - contains many of the resources 
     needed for non US English locales
   ldapsec.jar - contains security features supported 
     by the LDAP service provider
   dnsns.jar - for the InetAddress wrapper of JNDI DNS provider
bin/rmid
   Java RMI Activation System Daemon
bin/rmiregistry
   Java Remote Object Registry
bin/tnameserv
   Java IDL Name Server
bin/keytool
   Key and Certificate Management Tool
bin/kinit and jre/bin/kinit
   Used to obtain and cache Kerberos ticket-granting tickets
bin/klist and jre/bin/klist
   Kerberos display entries in credentials cache and keytab
bin/ktab and jre/bin/ktab
   Kerberos key table manager
bin/policytool
   Policy File Creation and Management Tool
bin/orbd
   Object Request Broker Daemon
bin/servertool
   Java IDL Server Tool

In addition, the Java Web Start product may be excluded from 
redistributions.  The Java Web Start product is contained in 
a file named javaws-1_2-solaris-sparc-i.zip, 
javaws-1_2-solaris-i586-i.zip, javaws-1_2-linux-i586-i.zip, 
or javaws-1_2-windows-i586-i.exe, depending on the platform.

-----------------------------------------------------------------------
Redistribution of Java 2 SDK Files
-----------------------------------------------------------------------
The limited set of files from the SDK listed below may be included in 
vendor redistributions of the Java 2 Runtime Environment.  All paths 
are relative to the top-level directory of the SDK.

 - jre/lib/cmm/PYCC.pf
      Color profile.  This file is required only if one wishes to 
      convert between the PYCC color space and another color space.

 - All .ttf font files in the jre/lib/fonts directory. Note that the 
   LucidaSansRegular.ttf font is already contained in the Java 2 
   Runtime Environment, so there is no need to bring that file over 
   from the SDK. 

 - jre/lib/audio/soundbank.gm
      This MIDI soundbank is present in the Java 2 SDK, but it has 
      been removed from the Java 2 Runtime Environment in order to 
      reduce the size of the Runtime Environment's download bundle. 
      However, a soundbank file is necessary for MIDI playback, and 
      therefore the SDK's soundbank.gm file may be included in 
      redistributions of the Runtime Environment at the vendor's 
      discretion. Several versions of enhanced MIDI soundbanks are 
      available from the Java Sound web site: 
      http://java.sun.com/products/java-media/sound/
      These alternative soundbanks may be included in redistributions 
      of the Java 2 Runtime Environment.

  - The javac bytecode compiler, consisting of the following files:
        bin/javac           [Solaris(TM) Operating Environment 
                             and Linux]
        bin/sparcv9/javac   [Solaris Operating Environment 
                             (SPARC(TM) Platform Edition)]
        bin/javac.exe       [Microsoft Windows]
        lib/tools.jar       [All platforms] 

  - jre\bin\server\
       On Microsoft Windows platforms, the Java 2 SDK includes both 
       the Java HotSpot Server VM and Java HotSpot Client VM.  However, 
       the Java 2 Runtime Environment for Microsoft Windows platforms 
       includes only the Java HotSpot Client VM. Those wishing to use 
       the Java HotSpot Server VM with the Java 2 Runtime Environment 
       may copy the SDK's jre\bin\server folder to a bin\server 
       directory in the Java Runtime Environment. Software vendors may 
       redistribute the Java HotSpot Server VM with their 
       redistributions of the Java Runtime Environment.  


-----------------------------------------------------------------------
Unlimited Strength Java Cryptography Extension
-----------------------------------------------------------------------
Due to import control restrictions for some countries, the Java 
Cryptography Extension (JCE) policy files shipped with the Java 2 SDK, 
Standard Edition and the Java 2 Runtime Environment allow strong but 
limited cryptography to be used.  These files are located at

     <java-home>/lib/security/local_policy.jar
     <java-home>lib/security/US_export_policy.jar

where <java-home> is the jre directory of the Java 2 SDK or the 
top-level directory of the Java 2 Runtime Environment.

An unlimited strength version of these files indicating no restrictions 
on cryptographic strengths is available on the Java 2 SDK web site for 
those living in eligible countries.  Those living in eligible countries 
may download the unlimited strength version and replace the strong 
cryptography jar files with the unlimited strength files.
      

-----------------------------------------------------------------------
Endorsed Standards Override Mechanism
-----------------------------------------------------------------------
An endorsed standard is a Java API defined through a standards
process other than the Java Community Process(SM) (JCP(SM)). Because
endorsed standards are defined outside the JCP, it is anticipated that
such standards will be revised between releases of the Java 2 
Platform.  In order to take advantage of new revisions to endorsed 
standards, developers and software vendors may use the Endorsed 
Standards Override Mechanism to provide newer versions of an endorsed 
standard than those included in the Java 2 Platform as released by Sun
Microsystems.

For more information on the Endorsed Standards Override Mechanism, 
including the list of platform packages that it may be used to 
override, see

   http://java.sun.com/j2se/1.4.2/docs/guide/standards/

Classes in the packages listed on that web page may be replaced only 
by classes implementing a more recent version of the API as defined 
by the appropriate standards body.

In addition to the packages listed in the document at the above 
URL, which are part of the Java 2 Platform, Standard Edition 
(J2SE(TM)) specification, redistributors of Sun's J2SE 
Reference Implementation are allowed to override classes whose 
sole purpose is to implement the functionality provided by 
public APIs defined in these Endorsed Standards packages.  
Redistributors may also override classes in the org.w3c.dom.* 
packages, or other classes whose sole purpose is to implement 
these APIs.

-----------------------------------------------------------------------
Copyright 2003 Sun Microsystems, Inc., 4150 Network Circle, 
Santa Clara, California 95054, U.S.A.  All rights reserved.

