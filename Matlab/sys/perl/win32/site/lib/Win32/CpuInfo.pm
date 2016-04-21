################################################
#   Package: CpuInfo.pm                           
#   Author : Amine Moulay Ramdane                
#   Company: Cyber-NT Communications           
#     Phone: (514)485-6659                    
#     Email: aminer@generation.net              
#      Date: March 13,1998                      
#   version: 1.01         
#
# Copyright © 1998 Amine Moulay Ramdane.All rights reserved
#
# you can get the module at:
# http://www.generation.net/~cybersky/Perl/perlmod.htm or
# http://www.generation.net/~cybersky/Perl/camels.shtml
# but if you have any problem to connect,just contact me 
# at my email above.                   
################################################

package Win32::CpuInfo;
use Win32::API; 
use Carp;
$VERSION = "1.01";
require Exporter;
@ISA = qw(Exporter);
@EXPORT = # constants 
qw(  
);
@EXPORT_OK =
qw(
);

my($DLLPath)="cpuinfo.dll";
my($GetCpuInfo)=new Win32::API($DLLPath,"GetCpuInfo",[P,P],I);
my($GetCpuFeatures)=new Win32::API($DLLPath,"GetCpuFeatures",[P,P],I);
my($GetCpuSpeed)=new Win32::API($DLLPath,"GetCpuSpeed",[P],I);
my($ReallocMem)=new Win32::API($DLLPath,"ReallocMemory",[P,I],I);
my($FreeMem)=new Win32::API($DLLPath,"FreeMemory",[P],I);
my(@Vendor)=qw(Intel AMD Cyrix UMC IDT NexGen Unknown); 
my(@Bool)=qw(No Yes); 
   
sub new  # Constructor
{my($class)=shift;my $self={};bless $self;}

sub ReallocMem
{my($Ret)=$ReallocMem->Call($_[0],$_[1]);}

sub FreeMem
{my($Ret)=$FreeMem->Call($_[0]);}


############################################################################
# CpuInfo Interface 


sub GetCpuSpeed
{my($obj)=shift;
if(scalar(@_) != 0 )
  { croak "\n[Error] Parameters doesn't correspond in Obj->GetCpuSpeed()\n";}
my($Ptr1)=pack("L",0);
my($Ret)=$GetCpuSpeed->Call($Ptr1);
if ($Ret){return unpack("L",$Ptr1)}
else {return undef;}}

sub GetCpuInfo 
{my($obj)=shift;
 if(scalar(@_) != 1 )
  { croak "\n[Error] Parameters doesn't correspond in Obj->GetCpuInfo()\n";}
my($Ptr1)=pack("L",0);my($Ptr2)=pack("L",0);my($Cpu)=shift;my($Str1);my(@b);
my($Ret)=$GetCpuInfo->Call($Ptr1,$Ptr2);
if ($Ret)
 {$Ptr2=unpack("L",$Ptr2);$Str1=unpack(P.$Ptr2,$Ptr1);FreeMem($Ptr1);@b=split(/&/,$Str1);
 $$Cpu={
     CPUID           => {Description=>'CPUID instruction support',Value=>$Bool[$b[0]]},
     iFamily         => {Description=>'Processor family',Value=>$b[1]},
     iModel          => {Description=>'Processor model',Value=>$b[2]},
     iStepping       => {Description=>'Processor stepping level',Value=>$b[3]},
     iType           => {Description=>'Processor type',Value=>$b[4]},
     VendorId        => {Description=>'Processor vendor identification signature',Value=>$b[5]},
     NumOfProcessors => {Description=>'Number of microprocessors installed',Value=>$b[6]},
     FDivBug         => {Description=>'Pentium bug',Value=>$Bool[$b[7]]},
     Fullname        => {Description=>'Processor vendor and model',Value=>$b[8]},
     MMX             => {Description=>'MultiMedia eXtensions support',Value=>$Bool[$b[9]]},  
     CPU             => {Description=>'Processor model',Value=>$b[10]},
     Overdrive       => {Description=>'Intel OverDrive processor',Value=>$Bool[$b[11]]},
     Vendor          => {Description=>'Processor vendor',Value=>$Vendor[$b[12]]},
     VendorName      => {Description=>'Full name of Vendor',Value=>$b[13]}};
     return $Ret;}
else{return undef;}} 


sub GetCpuFeatures 
{my($obj)=shift;
 if(scalar(@_) != 1 )
  { croak "\n[Error] Parameters doesn't correspond in Obj->GetCpuFeatures()\n";}
my($Ptr1)=pack("L",0);my($Ptr2)=pack("L",0);my($Cpu)=shift;my($Str1);my($Str2);my($Str3);my(@b);
my($Ret)=$GetCpuFeatures->Call($Ptr1,$Ptr2);
if ($Ret)
 {$Ptr2=unpack("L",$Ptr2);$Str1=unpack(P.$Ptr2,$Ptr1);FreeMem($Ptr1);@b=split(/&/,$Str1);
 $$Cpu={
     FPU     => {Description=>'Floating point unit on-chip',Value=>$Bool[$b[0]]},
     VME     => {Description=>'Virtual mode extension',Value=>$Bool[$b[1]]},
     DE      => {Description=>'Debugging extension',Value=>$Bool[$b[2]]},
     PSE     => {Description=>'Page size extension',Value=>$Bool[$b[3]]},
     TSC     => {Description=>'Time stamp counter',Value=>$Bool[$b[4]]},
     MSR     => {Description=>'Machine check extension',Value=>$Bool[$b[5]]},
     PAE     => {Description=>'Physical address extension',Value=>$Bool[$b[6]]},
     MCE     => {Description=>'Machine check exception',Value=>$Bool[$b[7]]},
     CX8     => {Description=>'CMPXCHG8 instruction support',Value=>$Bool[$b[8]]},
     APIC    => {Description=>'On-chip APIC hardware support',Value=>$Bool[$b[9]]},  
     SEP     => {Description=>'Fast system call',Value=>$Bool[$b[10]]},
     MTRR    => {Description=>'Memory type range registers',Value=>$Bool[$b[11]]},
     PGE     => {Description=>'Page global enable',Value=>$Bool[$b[12]]},
     MCA     => {Description=>'Machine check architecture',Value=>$Bool[$b[13]]},
     CMOV    => {Description=>'Conditional move instruction supported',Value=>$Bool[$b[11]]}};
     return $Ret;}
else{return undef;}} 
;

