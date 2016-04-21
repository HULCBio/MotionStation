# Resource.pm - Use Win32::API to retrieve popular 
# 		resources from Kernel32.dll and others
#
# Created by Brad Turner
#            bsturner@sprintparanet.com
#            Friday, April 09, 1999
#
# Updated on Friday, May 07, 1999
#
# All functions verfied on Win95a and WinNT 4.0
# (see the notes on GetDiskFreeSpace and GetDiskFreeSpaceEx)
###############################################
package Win32API::Resources;

use Win32;
use Win32::API;
$Win32API::Resources::VERSION = '0.04';

#*********************************************************
#*  IsEXE16 wrapper around GetBinaryType API - based on code by Aldo Calpini
#*********************************************************
sub IsEXE16
	{
	# Simple file test - returns 1 if file is 16-bit, 0 if file is 32 bit
	# SHGetFileInfo will work on both WinNT and Win95a systems

	my $SHGFI = new Win32::API("shell32", "SHGetFileInfo", [qw(P L P I I)], 'L');
	my($file) = @_;
	my $result; 
	my $type = undef;

	if($SHGFI)
		{
		$result = $SHGFI->Call($file, 0, 0, 0, 0x2000);
		if($result)
			{
			$type .= ", " if $type;

			my $hi = $result >> 16;
			my $lo = $result & 0x0000FFFF;
			$lo = sprintf("%c%c", $lo & 0x00FF, $lo >> 8);
        
			if($hi)
				{
				$hi = sprintf("%d.%02d", $hi >> 8, $hi & 0x00FF);
				}
			if (($lo eq "NE") and ($hi ge "3.0"))
				{
				$type = 1;
				}
			elsif (($lo eq "PE") and ($hi ge "3.0"))
				{
				$type = 0;
				}
			elsif (($lo eq "PE") and ($hi eq NULL))
				{
				$type = 0;
				}
			elsif (($lo eq "MZ") and ($hi eq NULL))
				{
				$type = 1;
				}
			}
		}
	return $type;
	}
#*********************************************************
#*  IsEXE32 wrapper around GetBinaryType API - based on code by Aldo Calpini
#*********************************************************
sub IsEXE32
	{
	# Simple file test - returns 1 if file is 32-bit, 0 if file is 16 bit
	# SHGetFileInfo will work on both WinNT and Win95a systems

	my $SHGFI = new Win32::API("shell32", "SHGetFileInfo", [qw(P L P I I)], 'L');
	my($file) = @_;
	my $result; 
	my $type = undef;

	if($SHGFI)
		{
		$result = $SHGFI->Call($file, 0, 0, 0, 0x2000);
		if($result)
			{
			$type .= ", " if $type;

			my $hi = $result >> 16;
			my $lo = $result & 0x0000FFFF;
			$lo = sprintf("%c%c", $lo & 0x00FF, $lo >> 8);
        
			if($hi)
				{
				$hi = sprintf("%d.%02d", $hi >> 8, $hi & 0x00FF);
				}
			if (($lo eq "NE") and ($hi ge "3.0"))
				{
				$type = 0;
				}
			elsif (($lo eq "PE") and ($hi ge "3.0"))
				{
				$type = 1;
				}
			elsif (($lo eq "PE") and ($hi eq NULL))
				{
				$type = 1;
				}
			elsif (($lo eq "MZ") and ($hi eq NULL))
				{
				$type = 0;
				}
			}
		}
	return $type;
	}
#*********************************************************
#*  GetBinaryType API direct - by Aldo Calpini
#*********************************************************
sub GetBinaryType
	{
	# GetBinaryType has the advantage of detecting POSIX and OS/2 based applications
	# however it cannot differentiate between 32-bit apps that are console or window based

	# BOOL GetBinaryType (
	# LPCTSTR lpApplicationName,  // pointer to fully qualified path of file to test
	# LPDWORD lpBinaryType        // pointer to variable to receive binary type information);

	my $GBT = new Win32::API("kernel32", "GetBinaryType", [qw(P P)], 'N');
	my($file) = @_;
	my $result; 
	my $type = undef;
	if(Win32::IsWinNT)
		{
		my @typename = (
		"Win32 based application",
		"MS-DOS based application",
		"16-bit Windows based application",
		"PIF file that executes an MS-DOS based application",
		"POSIX based application",
		"16-bit OS/2 based application");

	        my $typeindex = pack("L", 0);
		$result = $GBT->Call($file, $typeindex);
		$type = $typename[unpack("L", $typeindex)] if $result;
		}
	else	{
		print "Win32API::Resources::GetBinaryType only works in WinNT\n";
		return 0;
		}
	return $type;
	}
#*********************************************************
#*  ExeType Wrapper around SHGetFileInfo API - by Aldo Calpini
#*********************************************************
sub ExeType
	{
	# GetBinaryType has the advantage of detecting POSIX and OS/2 based applications
	# however it cannot differentiate between 32-bit apps that are console or window based
	#
	# SHGetFileInfo will work on both WinNT and Win95a systems

	# WINSHELLAPI DWORD WINAPI SHGetFileInfo(
	# LPCTSTR pszPath,
	# DWORD dwFileAttributes,
	# SHFILEINFO FAR *psfi,
	# UINT cbFileInfo,
	# UINT uFlags);

	my $SHGFI = new Win32::API("shell32", "SHGetFileInfo", [qw(P L P I I)], 'L');
	my($file) = @_;
	my $result; 
	my $type = undef;

	if($SHGFI)
		{
		$result = $SHGFI->Call($file, 0, 0, 0, 0x2000);
		if($result)
			{
			$type .= ", " if $type;

			my $hi = $result >> 16;
			my $lo = $result & 0x0000FFFF;
			$lo = sprintf("%c%c", $lo & 0x00FF, $lo >> 8);
        
			if($hi)
				{
				$hi = sprintf("%d.%02d", $hi >> 8, $hi & 0x00FF);
				}
			if (($lo eq "NE") and ($hi ge "3.0"))
				{
				$type = "16-bit Windows based application, $lo $hi";
				}
			elsif (($lo eq "PE") and ($hi ge "3.0"))
				{
				$type = "32-bit Windows based application, $lo $hi";
				}
			elsif (($lo eq "PE") and ($hi eq NULL))
				{
				$type = "32-bit Win32 console based application, $lo $hi";
				}
			elsif (($lo eq "MZ") and ($hi eq NULL))
				{
				$type = "MS-DOS based application, $lo $hi";
				}
			else	{
				$type = "Unknown, $lo $hi";
				}
			}
		}
	return $type;
	}
#*********************************************************
#*  GetDriveSpace API sub - this calls the right API depending on the OS Version
#*********************************************************
sub GetDriveSpace
	{
	# Frontend to GetDiskFreeSpace and GetDiskFreeSpaceEx -
	# Call the correct function depending on which version of the OS you have
	my $drive = $_[0];
	my (%DSpace);

	if (Win32::IsWinNT)
		{
		my $OS = "Windows NT";

		# We're on NT so we can call the good function
	print "WinNT!\n";
		%DSpace = Win32API::Resources::GetDiskFreeSpaceEx($drive) or return 0;
		}
	elsif (Win32::IsWin95)
		{
		my $OS = "Windows 95";
		my ($servicepack, $major, $minor, $buildnum, $platformid, $l, $m);

		# We're on 95 so we first need check if we're OSR2
		($servicepack, $major, $minor, $buildnum, $platformid) = Win32::GetOSVersion;
		$l = $buildnum & 0xFFFF; #get only the least significant 16
		$m = $buildnum >> 16;    #get only the most significant 16
		if (($major, $minor, $l, $m) gt ("4", "0", "950", "1024"))
			{
			# We're OSR2 - Calling GetDiskFreeSpaceEx
			%DSpace = Win32API::Resources::GetDiskFreeSpaceEx($drive) or return 0;
			}
		elsif (($major, $minor, $l, $m) le ("4", "0", "950", "1024"))
			{
			# We're OSR1 - Calling GetDiskFreeSpace
			%DSpace = Win32API::Resources::GetDiskFreeSpace($drive) or return 0;
			}
		else	{
			# Not sure what it is - call the safe one
			%DSpace = Win32API::Resources::GetDiskFreeSpace($drive) or return 0;
			}
		}
	return %DSpace;
	}
#*********************************************************
#*  GetDiskFreeSpace API sub
#*********************************************************
sub GetDiskFreeSpace
	{
	# The GetDiskFreeSpaceEx function lets you avoid the arithmetic required by the 
	# GetDiskFreeSpace function. However, GetDiskFreeSpaceEx will not work on Win95 OSR1

	# Windows 95: 
	# The GetDiskFreeSpace function returns incorrect values for volumes that are 
	# larger than 2 gigabytes. The function caps the values stored into *lpNumberOfFreeClusters 
	# and *lpTotalNumberOfClusters so as to never report volume sizes that are greater 
	# than 2 gigabytes. 
	# Even on volumes that are smaller than 2 gigabytes, the values stored into 
	# *lpSectorsPerCluster, *lpNumberOfFreeClusters, and *lpTotalNumberOfClusters values 
	# may be incorrect. That is because the operating system manipulates the values so that 
	# computations with them yield the correct volume size. 

	# Windows 95 OSR2 and later: 
	# The GetDiskFreeSpaceEx function is available on Windows 95 systems beginning with OEM 
	# Service Release 2 (OSR2). The GetDiskFreeSpaceEx function returns correct values for 
	# all volumes, including those that are greater than 2 gigabytes. 

	# BOOL GetDiskFreeSpace(  
	# LPCTSTR lpRootPathName,    		// pointer to root path
	# LPDWORD lpSectorsPerCluster,  	// pointer to sectors per cluster
	# LPDWORD lpBytesPerSector,  		// pointer to bytes per sector
	# LPDWORD lpNumberOfFreeClusters,	// pointer to number of free clusters
	# LPDWORD lpTotalNumberOfClusters	// pointer to total number of clusters);

	my $lpRootPathName = $_[0];
	# Windows 95: The initial release of Windows 95 does not support UNC paths for 
	# the lpRootPathName parameter. To query the free disk space using a UNC path, 
	# temporarily map the UNC path to a drive letter, query the free disk space on 
	# the drive, then remove the temporary mapping. 
	# Windows 95 OSR2 and later: UNC paths are supported. 

	my $lpSectorsPerCluster = "\0" x 32;
	my $lpBytesPerSector = "\0" x 32;
	my $lpNumberOfFreeClusters = "\0" x 32;
	my $lpTotalNumberOfClusters = "\0" x 32;

	# GetDiskFreeSpace API direct
	my $GetDiskFreeSpace = new Win32::API("kernel32", "GetDiskFreeSpaceA", [qw(P P P P P)], 'N') or return 0;
	$GetDiskFreeSpace->Call($lpRootPathName, $lpSectorsPerCluster, $lpBytesPerSector, $lpNumberOfFreeClusters, $lpTotalNumberOfClusters) or return 0;
	$lpSectorsPerCluster = unpack("L*", $lpSectorsPerCluster);
	$lpBytesPerSector = unpack("L*", $lpBytesPerSector);
	$lpNumberOfFreeClusters = unpack("L*", $lpNumberOfFreeClusters);
	$lpTotalNumberOfClusters = unpack("L*", $lpTotalNumberOfClusters);
	my $DriveSpaceTotal = $lpTotalNumberOfClusters * $lpSectorsPerCluster * $lpBytesPerSector;
	my $DriveSpaceFree = $lpNumberOfFreeClusters * $lpSectorsPerCluster * $lpBytesPerSector;
 
	my %DSpace = (	SectorsPerCluster 	=> $lpSectorsPerCluster,
			BytesPerSector 		=> $lpBytesPerSector,
			NumberOfFreeClusters 	=> $lpNumberOfFreeClusters,
			TotalNumberOfClusters 	=> $lpTotalNumberOfClusters,
			DriveSpaceTotal		=> $DriveSpaceTotal,
			DriveSpaceFree	 	=> $DriveSpaceFree);
	return %DSpace;
	}
#*********************************************************
#*  GetDiskFreeSpaceEx API sub
#*********************************************************
sub GetDiskFreeSpaceEx
	{
	# Windows 95 OSR2: The GetDiskFreeSpaceEx function is available on Windows 95 
	# systems beginning with OEM Service Release 2 (OSR2). 

	# BOOL GetDiskFreeSpaceEx(
	# LPCTSTR lpDirectoryName,                 	// pointer to the directory name
	# PULARGE_INTEGER lpFreeBytesAvailableToCaller, // receives the number of bytes on disk available to the caller
	# PULARGE_INTEGER lpTotalNumberOfBytes,    	// receives the number of bytes on disk
	# PULARGE_INTEGER lpTotalNumberOfFreeBytes 	// receives the free bytes on disk);

	my $lpDirectoryName = $_[0];
	my $lpFreeBytesAvailableToCaller = "\0" x 32;
	my $lpTotalNumberOfBytes = "\0" x 32;
	my $lpTotalNumberOfFreeBytes = "\0" x 32;

	# GetDiskFreeSpace API direct
	my $GetDiskFreeSpaceEx = new Win32::API("kernel32", "GetDiskFreeSpaceExA", [qw(P P P P)], 'N') or return 0;
	$GetDiskFreeSpaceEx->Call($lpDirectoryName, $lpFreeBytesAvailableToCaller, $lpTotalNumberOfBytes, $lpTotalNumberOfFreeBytes) or return 0;
	$lpFreeBytesAvailableToCaller = unpack("L*", $lpFreeBytesAvailableToCaller);
	$lpTotalNumberOfBytes = unpack("L*", $lpTotalNumberOfBytes);
	$lpTotalNumberOfFreeBytes = unpack("L*", $lpTotalNumberOfFreeBytes);
 
	my %DSpace = (	DriveSpaceQuotaFree 	=> $lpFreeBytesAvailableToCaller,
			DriveSpaceTotal		=> $lpTotalNumberOfBytes,
			DriveSpaceFree	 	=> $lpTotalNumberOfFreeBytes);
	return %DSpace;
	}
#*********************************************************
#*  GlobalMemoryStatus API sub
#*********************************************************
sub GlobalMemoryStatus
	{
	# VOID GlobalMemoryStatus(
	# LPMEMORYSTATUS lpBuffer   // pointer to the memory status structure);

	my $GMSBuffer = "\0" x 32;
	my %GMStatus;

	# GlobalMemoryStatus API direct
	my $GlobalMemoryStatus = new Win32::API("kernel32", "GlobalMemoryStatus", [qw(P)], 'N') or return 0;
	$GlobalMemoryStatus->Call($GMSBuffer) or return 0;
	my @GMSBuffer= unpack("L*", $GMSBuffer);

	# MEMORYSTATUS structure - tip o' the hat to Win32::AdminMisc
	%GMStatus = (	Load 		=> $GMSBuffer[1],
			RAMTotal 	=> $GMSBuffer[2],
			RAMAvail 	=> $GMSBuffer[3],
			PageTotal 	=> $GMSBuffer[4],
			PageAvail 	=> $GMSBuffer[5],
			VirtTotal 	=> $GMSBuffer[6],
			VirtAvail 	=> $GMSBuffer[7]);

	return %GMStatus;
	}
#*********************************************************
#*  LoadString API sub
#*********************************************************
sub LoadString
	{
	# int LoadString(
	# HINSTANCE hInstance,  // handle to module containing string resource
	# UINT uID,             // resource identifier
	# LPTSTR lpBuffer,      // pointer to buffer for resource
	# int nBufferMax        // size of buffer);

	my $file = $_[0];					# The file passed from main (DLL/EXE)
	my $uID = $_[1];					# The resource identifier
	my $LLHandle = "\0" x 32;
	my $lpBuffer = "\0" x 64;
	my ($LSBuffer);

	# Win32::LoadLibrary method - requires use Win32
	$LLHandle = Win32::LoadLibrary($file);			# Map the DLL into memory

	# LoadString API direct
	my $LoadString = new Win32::API("user32", "LoadStringA", [qw(N I P I)], 'I') or return 0;
	$LSBuffer = $LoadString->Call($LLHandle, $uID, $lpBuffer, 64) or return 0;
	$lpBuffer = ((split(/\0/, $lpBuffer))[0]);		# Strip out the excess buffer

	return $lpBuffer;
	}
#*********************************************************
#*  EnumString API wrapper around LoadString to Enumerate table
#*********************************************************
sub EnumString
	{
	# Place a wrapper around LoadString to Enumerate all entries

	# int LoadString(
	# HINSTANCE hInstance,  // handle to module containing string resource
	# UINT uID,             // resource identifier
	# LPTSTR lpBuffer,      // pointer to buffer for resource
	# int nBufferMax        // size of buffer);

	my $file = $_[0];					# The file passed from main (DLL/EXE)
	my $uID = 1;						# The resource identifier
	my $L = 1;
	my $LLHandle = "\0" x 32;
	my $lpBuffer = "\0" x 64;
	my (@lpBuffer, $LSBuffer);

	# Win32::LoadLibrary method - requires use Win32
	$LLHandle = Win32::LoadLibrary($file);			# Map the DLL into memory

	# LoadString API direct
	my $LoadString = new Win32::API("user32", "LoadStringA", [qw(N I P I)], 'I') or return 0;

	while ($L)
		{
		$LSBuffer = $LoadString->Call($LLHandle, $uID, $lpBuffer, 64) or $L = undef;
		push(@lpBuffer, ((split(/\0/, $lpBuffer))[0]));	# Strip out the excess buffer and place it in the list
		$uID++;
		}		

	return @lpBuffer;
	}
#*********************************************************
#*  GetFileVersion sub
#*********************************************************
sub GetFileVersion
	{

	# GetFileVersionInfoSize is used to find the size of record to retrieve
	# DWORD GetFileVersionInfoSize(
	# LPTSTR lptstrFilename,  	// pointer to filename string
	# LPDWORD lpdwHandle      	// pointer to variable to receive zero);

	# GetFileVersionInfo is used to retrieve the record itself
	# BOOL GetFileVersionInfo(  
	# LPTSTR lptstrFilename,  	// pointer to filename string
	# DWORD dwHandle,         	// ignored
	# DWORD dwLen,			// size of buffer
	# LPVOID lpData           	// pointer to buffer to receive file-version info.);

	my $filename = $_[0];
	my $raw = $_[1];
	my ($p, @pattern, @pattern2, $line, @lines, $pattern, $word, $value, %PAT);
	my ($GetFileVersionInfoSize, $lpBufferSize, $lpHandle, $lpBuffer, $GetFileVersionInfo, $ignore);
	
	# Open file specified on command line as a binary file
	# then reverse the line order because the info is towards the
	# end of the file that is being searched - should speed searches
	
	my $GetFileVersionInfoSize = new Win32::API("version", "GetFileVersionInfoSizeA", [qw(P P)], 'N');
	$lpBufferSize = $GetFileVersionInfoSize->Call($filename, $lpHandle);
	$lpBuffer = "\0" x $lpBufferSize;

	my $GetFileVersionInfo = new Win32::API("version", "GetFileVersionInfoA", [qw(P N N P)], 'N');
	if ($GetFileVersionInfo->Call($filename, $ignore, $lpBufferSize, $lpBuffer))
		{
		if ($raw)
			{
			$PAT{RAWBuffer} = $lpBuffer;			# Returned for Debugging purposes
			}
		}
	else	{
		return %PAT = (		ProductVersion  	=> 0,
					ProductName 		=> 0,
					OriginalFilename 	=> 0,
					LegalCopyright 		=> 0,
					InternalName 		=> 0,
					FileVersion 		=> 0,
					FileDescription 	=> 0,
					CompanyName 		=> 0,
					RAWBuffer		=> 0);
		}

	# Take each pattern and null pad each entry
	# to reflect how the data appears in the fixed length buffer block
	# The Raw data is delimited by ASCII CHAR 001 while the word value
	# pairs are null padded and themselves delimited by a triple null
	# sequence
	# Null = ASCII CHAR 000 or \000 to Perl
	# (Smiley face) = ASCII CHAR 001 or \001 to Perl
	
	@pattern = qw(ProductVersion ProductName OriginalFilename LegalCopyright InternalName FileVersion FileDescription CompanyName);
	@pattern2 = qw(ProductVersion ProductName OriginalFilename LegalCopyright InternalName FileVersion FileDescription CompanyName);

	foreach $p ( @pattern )
		{
		# Since modifying $p modifies the element inside of @pattern, this speeds us up just a trifle
		# compared to push().
		$p = join("\000", split(//, $p));
		}

	# Scan the source for each occurrance.
	# The pattern is appended by a "ends in a \001" to search for the 
	# ending delimiter so we know when to stop reading
	# $& should contain the information matched between the delimiters
	# Once a match is made then split the results on the 3 null delimiter
	# which separates the word value pair and discards the left over
	# junk between the value and the end delimiter.
	# Then clear the null pads out with a substitution and provide the results

	# Parse the Variable length block for info -
	# Win95 machines seem to format the file info inconsistently - this will catch some, but not all fields
	# Some information contained in the variable length block is not in the Fixed length block!

	# We should probably use VerQueryValue, but can't get it to work yet...
#	my $VerQueryValue = new Win32::API("version", "VerQueryValueA", [qw(P N P P)], 'N');
	foreach $p (@pattern2)
		{
#		my $lplpBuffer = "\0" x 32;
#		my $puLen = "\0" x 32;

		# Call the API to interrogate the value directly
#		$tmp = "\\VarFileInfo\\$p"; 
#		my $lpSubBlock = pack("L*", $tmp);
#		print "lpSubBlock = ($lpSubBlock)\n";
#		if ($VerQueryValue->Call($lpBuffer, $lpSubBlock, $lplpBuffer, $puLen))
#			{
#			$lplpBuffer = unpack("L*", $lplpBuffer);
#			$puLen = unpack("L*", $lplpBuffer);
#			print "$p - Length = ($puLen), Value = ($lplpBuffer)\n";
#			}
#		else	{
#			print Win32::FormatMessage(Win32::GetLastError);
#			}

		# If $p's not defined, we must've matched it already, so skip it.
		if (defined($p) && $lpBuffer =~ /$p.*[^\001]/)
			{
			my $tmp = $&;
			$tmp =~ s/\000+/\=/g;			# Substitute one or more \000's with an =
			($word, $value) = split(/\=/,$tmp);
			$word =~ s/\000//g;
			$value =~ s/\000//g;
			$PAT{$word} = $value;
		
			# Hey, we found it.. so let's keep from needing to search for it again.
			$p = undef;
			}
		}
	# Parse the Fixed length block for info -
	# WinNT machines format this info consistantly and this routine will fill in the gaps
	foreach $p (@pattern)
		{
		# If $p's not defined, we must've matched it already, so skip it.
		if (defined($p) && $lpBuffer =~ /$p[^\001]*/i)
			{
			($word, $value) = split(/\000\000\000/,$&);
			$word =~ s/\000//g;
			$value =~ s/\000//g;
			$PAT{$word} = $value;
		
			# Hey, we found it.. so let's keep from needing to search for it again.
			$p = undef;
			}
		}
	return %PAT;
	}
#*********************************************************
#*  ShowKeys subroutine - list the contents of a hash with optional sorting
#*********************************************************
sub ShowKeys
	{
	# A quick and easy sub to display the contents of a Hash
	# sorted or unsorted

	my $key;
	my $title = $_[0];		# Prints the title of the Hash
	my $sort = $_[1];		# 0 = no sort, 1 = sort
	my %main = %{$_[2]};		# the reference to the Hash (\%hash)

	print "\n$title\n\n";
	if ($sort)
		{
		foreach $key (sort keys (%main))
			{
			print "$key = $main{$key}\n";
			}
		}
	else	{
		foreach $key (keys (%main))
			{
			print "$key = $main{$key}\n";
			}
		}
	}
#*********************************************************
#*  GetDrives
#*********************************************************
sub GetDrives
	{
	# In List context GetDrives returns a list of drive assignments on the local system
	# In Scalar context GetDrives returns the number of valid drive assignments
	# Passing GetDrives one of the Drive Type Constants will return:
	# 	In List context, a list of drive assignments that match the passed constant
	# 	In Scalar context, the number of valid drive assignments that match the passed constant

	# The GetLogicalDriveStrings function fills a buffer with strings that specify valid drives in the system. 

	# DWORD GetLogicalDriveStrings(
	# DWORD nBufferLength,  // size of buffer
	# LPTSTR lpBuffer       // pointer to buffer for drive strings);

	# The GetDriveType function determines whether a disk drive is a removable, fixed, CD-ROM, RAM disk, or network drive. 

	# UINT GetDriveType(
	# LPCTSTR lpRootPathName   // pointer to root path);

	# DRIVE_UNKNOWN 	The drive type cannot be determined. 
	# DRIVE_NO_ROOT_DIR 	The root directory does not exist. 
	# DRIVE_REMOVABLE 	The disk can be removed from the drive. 
	# DRIVE_FIXED 		The disk cannot be removed from the drive. 
	# DRIVE_REMOTE 		The drive is a remote (network) drive. 
	# DRIVE_CDROM 		The drive is a CD-ROM drive. 
	# DRIVE_RAMDISK 	The drive is a RAM disk. 

	my $DriveType = $_[0];				# Pass a drive type string to parse by
	my $nBufferLength = "128";
	my $lpBuffer = "\0" x 128;
	my @matchlist;
	my %DriveType = (	0x00000000 => "DRIVE_UNKNOWN",
				0x00000001 => "DRIVE_NO_ROOT_DIR",
				0x00000002 => "DRIVE_REMOVABLE",
				0x00000003 => "DRIVE_FIXED",
				0x00000004 => "DRIVE_REMOTE",
				0x00000005 => "DRIVE_CDROM",
				0x00000006 => "DRIVE_RAMDISK");

	# GetLogicalDriveStrings API direct
	my $GetLogicalDriveStrings = new Win32::API("kernel32", "GetLogicalDriveStringsA", [qw(P P)], 'N') or return 0;
	$GetLogicalDriveStrings->Call($nBufferLength, $lpBuffer) or return 0;
	my @lpBuffer = split(/\0/, $lpBuffer);		# Strip out the excess buffer and convert to list context

	# GetDriveType API direct
	my $GetDriveType = new Win32::API("kernel32", "GetDriveTypeA", [qw(P)], 'N') or return 0;
	foreach $lpRootPathName (@lpBuffer)
		{
		my $Return = $GetDriveType->Call($lpRootPathName) or return 0;
		if ($DriveType)
			{
			if ($DriveType eq $DriveType{$Return})
				{
				push (@matchlist, $lpRootPathName);
				}
			else	{
				next;
				}
			return @matchlist;
			}
		else	{
			return @lpBuffer;
			}
		}
	}
1;
__END__


=head1 NAME

Win32API::Resources - Use Win32::API to retrieve popular resources from Kernel32.dll and others

=head1 SYNOPSIS

  use Win32API::Resources;

  my $file = "c:\\winnt\\system32\\cmd.exe";
  my %DSpace = Win32API::Resources::GetDiskFreeSpace("C:\\");
  my %DRVSpace = Win32API::Resources::GetDriveSpace("C:\\");
  my %File = Win32API::Resources::GetFileVersion($file, 1);
  my %Mem = Win32API::Resources::GlobalMemoryStatus();
  my $Notes = Win32API::Resources::LoadString("c:\\notes\\nstrings.dll", 1);
  my @list = Win32API::Resources::EnumString("c:\\notes\\nstrings.dll");
  my $type = Win32API::Resources::ExeType($file);
  my @drives = Win32API::Resources::GetDrives(DRIVE_CDROM);

  if (Win32API::Resources::IsEXE16($file))
	{
	print "The file $file is 16-bit - ($type)\n";
	}
  elsif (Win32API::Resources::IsEXE32($file))
	{
	print "The file $file is 32-bit - ($type)\n";
	}
  print "The following are valid CD-Rom drives: @drives\n";
  Win32API::Resources::ShowKeys("File Information:", 1, \%File);
  Win32API::Resources::ShowKeys("Disk Space:", 0, \%DSpace);
  Win32API::Resources::ShowKeys("Drive Space:", 1, \%DRVSpace);
  Win32API::Resources::ShowKeys("Memory Stats:", 1, \%Mem);

=head1 ABSTRACT

With this module you can access a series of Win32 API's directly or via provided 
wrappers that are exported from KERNEL32.DLL, SHELL32.DLL, USER32.DLL & VERSION.DLL. 

The current version of Win32API::Resources is available at:

  http://home.earthlink.net/~bsturner/perl/index.html

=head1 CREDITS

Thanks go to Aldo Calpini for making the Win32::API module accessible as well as some 
help with GetBinaryType and ExeType functions and to Dave Roth and Jens Helberg for 
providing direction on the GetFileVersion function.

=head1 HISTORY

	0.04	Added GetDrives function
	0.03	Cleaned up some memory leaks and fixed bug with GetDiskFreeSpaceEx
	0.02	Added some new EXEType functions
	0.01	First release

=head1 INSTALLATION

This module is shipped as a basic PM file that should be installed in your
Perl\site\lib\Win32API dir.  Written and tested for the ActivePerl 509
distribution.

REQUIRES Win32::API be installed

=head1 DESCRIPTION

To use this module put the following line at the beginning of your script:

	use Win32API::Resources;

Any one of the functions can be referenced by:

	var = Win32API::Resources::function

except for Win32API::Resources::ShowKeys() which does not return a value.

=head1 RETURN VALUES

All functions return 0 if unsuccessful and non-zero data if successful.

=head1 FUNCTIONS

=item Win32API::Resources::GetDiskFreeSpace

	%Hash = Win32API::Resources::GetDiskFreeSpace($drive);

$drive must refer to the root of a target drive and be followed by \\

	$drive = "C:\\";
	$drive = "$ENV{SystemDrive}\\";

Windows 95: 
The GetDiskFreeSpace function returns incorrect values for volumes that are 
larger than 2 gigabytes. 
Even on volumes that are smaller than 2 gigabytes, the values may be incorrect. 
That is because the operating system manipulates the values so that 
computations with them yield the correct volume size. 

Windows 95 OSR2 and later: 
The GetDiskFreeSpaceEx function is available on Windows 95 systems beginning with OEM 
Service Release 2 (OSR2). The GetDiskFreeSpaceEx function returns correct values for 
all volumes, including those that are greater than 2 gigabytes. 

=item Win32API::Resources::GetDiskFreeSpaceEx

	%Hash = Win32API::Resources::GetDiskFreeSpaceEx($drive);

B<GetDiskFreeSpaceEx will not work on Win95 OSR1>.  This function is provided for direct 
access, however it is safer to use the I<Win32API::Resources::GetDriveSpace> frontend instead.

$drive must refer to the root of a target drive and be followed by \\

	$drive = "C:\\";
	$drive = "$ENV{SystemDrive}\\";

Windows 95 OSR2: The GetDiskFreeSpaceEx function is available on Windows 95 
systems beginning with OEM Service Release 2 (OSR2). 

=item Win32API::Resources::GetDriveSpace

	%Hash = Win32API::Resources::GetDriveSpace($drive);

$drive must refer to the root of a target drive and be followed by \\

	$drive = "C:\\";
	$drive = "$ENV{SystemDrive}\\";

Frontend to GetDiskFreeSpace and GetDiskFreeSpaceEx - GetDriveSpace will 
always call the correct function depending on which version of the OS you have.

=item Win32API::Resources::GetFileVersion

	%Hash = Win32API::Resources::GetFileVersion($file, $debug);

I<GetFileVersion is a work in progress> - it works but isn't I<pretty>.

Win95 systems return the file information record a bit differently and the same
logic used to parse that record for info on a WinNT system does not return 
all available keys on a Win95 system.  GetFileVersion will return all available 
information in both Win95 and WinNT.  

	$file is the full path to the EXE or DLL to be examined
	$debug is an optional boolean switch to return the raw file record or not

Returns a hash with the following keys:

	ProductVersion 
	ProductName 
	OriginalFilename 
	LegalCopyright 
	InternalName 
	FileVersion 
	FileDescription 
	CompanyName
	RAWBuffer (if optional switch is set to 1)

If the function fails the same hash is returned but the key values will be 
set to 0.

=item Win32API::Resources::GlobalMemoryStatus

	%Hash = Win32API::Resources::GlobalMemoryStatus();

Returns a hash filled with memory information from the current system.  The
structure of the hash is the same as Win32::AdminMisc::GetMemoryInfo:

	Load		Specifies a number between 0 and 100 that gives a general 
			idea of current memory utilization
	RAMTotal 	Indicates the total number of bytes of physical memory
	RAMAvail 	Indicates the number of bytes of physical memory available
	PageTotal 	Indicates the total number of bytes that can be stored in the 
			paging file. Note that this number does not represent the actual 
			physical size of the paging file on disk.
	PageAvail 	Indicates the number of bytes available in the paging file
	VirtTotal 	Indicates the total number of bytes that can be described in the 
			user mode portion of the virtual address space of the calling process
	VirtAvail 	Indicates the number of bytes of unreserved and uncommitted memory in 
			the user mode portion of the virtual address space of the calling process

=item Win32API::Resources::LoadString

	$Scalar = Win32API::Resources::LoadString($file, $rid);

	$file is full path to the EXE or DLL to examine
	$rid is the resource element to query where 1 is the first element in the table

Some EXE's and DLL's have a Resource Table that lists strings that are referenced for various
purposes.  These sometimes contain version information or error messages.  In the case of Lotus Notes
the first element of NSTRINGS.DLL contains the version of Notes installed.

By default all strings are limited to 64 character wide.

To Enumerate the table, use I<Win32API::Resources::EnumString>

=item Win32API::Resources::EnumString

	@List = Win32API::Resources::EnumString($file);

Just as I<Win32API::Resources::LoadString> will load a specific element from the resource
table of a file, EnumString uses the same method but returns an enumerated list of the contents
of the resource table.

By default all strings are limited to 64 character wide.

=item Win32API::Resources::ExeType

	$Scalar = Win32API::Resources::ExeType($file);

ExeType is a wrapper around the SHGetFileInfo API.  This will return:

	16-bit Windows based application, NE <OS Version>
	32-bit Windows based application, PE <OS Version>
	32-bit Win32 console based application, PE <NULL>
	MS-DOS based application, MZ <NULL>
	Unknown, <Type> <OS Version>

	NE designates 16 bit applications
	PE designates 32 bit applications
	MZ designates MS-DOS applications
	<OS Version> is the version of the OS it was compiled to run on (3.0, 3.1, 3.51, etc)

SHGetFileInfo will work on both WinNT and Win95a systems

I<Thanks to Aldo Calpini for the code!>

=item Win32API::Resources::IsEXE16

	Win32API::Resources::IsEXE16($file);

IsEXE16 is a wrapper around the SHGetFileInfo API.  It is provided as a simple file test 
that returns a true (1) or false (0) based on the target file.  

	$file is the full path to the EXE in question

=item Win32API::Resources::IsEXE32

	Win32API::Resources::IsEXE32($file);

IsEXE32 is a wrapper around the SHGetFileInfo API.  It is provided as a simple file test 
that returns a true (1) or false (0) based on the target file.  

	$file is the full path to the EXE in question

=item Win32API::Resources::GetBinaryType

	Win32API::Resources::GetBinaryType($title, 1, \%File);

GetBinary type B<only works in Windows NT>.  It does, however, have the added benefit over 
SHGetFileInfo in that it will also reveal EXE types based on other NT subsystems.  It will return:

	Win32 based application
	MS-DOS based application
	16-bit Windows based application
	PIF file that executes an MS-DOS based application
	POSIX based application
	16-bit OS/2 based application

I<Thanks to Aldo Calpini for the code!>

=item Win32API::Resources::GetDrives

	[$Scalar] or [@List] = Win32API::Resources::GetDrives($type);

In List context GetDrives returns a list of drive assignments on the local system
In Scalar context GetDrives returns the number of valid drive assignments
Passing GetDrives one of the Drive Type Constants will return:
In List context, a list of drive assignments that match the passed constant
In Scalar context, the number of valid drive assignments that match the passed constant

	$type is one of the following constants - optional

	DRIVE_UNKNOWN 		The drive type cannot be determined. 
	DRIVE_NO_ROOT_DIR 	The root directory does not exist. 
	DRIVE_REMOVABLE 	The disk can be removed from the drive. 
	DRIVE_FIXED 		The disk cannot be removed from the drive. 
	DRIVE_REMOTE 		The drive is a remote (network) drive. 
	DRIVE_CDROM 		The drive is a CD-ROM drive. 
	DRIVE_RAMDISK 		The drive is a RAM disk. 

=item Win32API::Resources::ShowKeys

	Win32API::Resources::ShowKeys($title, $sort, \%Hash);

ShowKeys is provided as a simple way to show the contents of a hash with optional sorting.

	$title is a printed title to the hash
	$sort is a boolean switch that will optionally sort the Keys
	\%Hash is a Hash reference that you wish to display

=back

=head1 AUTHOR

Brad Turner ( I<bsturner@sprintparanet.com> ).

=cut


