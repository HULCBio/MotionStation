package analyzeOctaveSource;

use File::Find;

sub new {
 my $Objekt = shift;
 my $Referenz = {};
 bless($Referenz,$Objekt);
 return($Referenz);
}

sub readDirTree{
	my $Objekt = shift;
	my $Dir = shift;
	my $fileExt = shift;
	my $File;
	# read directory
	my @dirArray = ();

	find sub { push @dirArray, $File::Find::name }, $Dir;

	# remove all files except with file ending $fileExt
	@DirArray = grep /.+\.$fileExt/ , @DirArray;
	my $nFiles = @dirArray;
	if ($nFiles==0){
		print "No Octave files found.\n";
		print "Octave files must end with *.m\n";
		die " ==========================\n";
	}
	return @dirArray;
}

sub searchFilesContainTestLines{
	my $Objekt = shift;
	my @dirArray = shift;

	#
	my $fileName = "";
	my @fileContent = ();
	my @fileArray = ();
	my @temp = ();
	my $nTemp = "";

	foreach (@dirArray){
	  # open file and search for lines beginning with
	  # !%
	  if (-d $_){
        # if directory, do nothing
      }else{
	    open(FILE,$_) or die "File $_ not found!\n";
	    @fileContent = <FILE>;
	    close FILE;
        @temp = grep /^!%/, @fileContent;
        $nTemp = @temp;
        if ($nTemp>0){
          @fileArray = $_
        }
	  }
	}

	return @fileArray;
}


1;

