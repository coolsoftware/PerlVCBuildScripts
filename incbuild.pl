##########################################################################################
#
# Copyright 2013 Coolsoftware. http://blog.coolsoftware.ru/
#
# Increment Build Number
#
# Example of usage in Visual Studio 2010 IDE
#   Configuration Properties->Build Events->Pre-Build Event->Command Line:
#
#   perl $(ProjectDir)..\incbuild.pl $(ProjectDir) $(Configuration)
#
# Example of build info file (myapp-build.txt):
#
# 1.1.0.0
# http://127.0.0.1/myapp.exe
# myapp.exe
# b9f2c07999dcafe9fe544a00521829c1
#
##########################################################################################

$path=shift; 
$config=shift;
$quiet=shift;

@out=`dir $path\\*.rc* /b`; 
chomp @out;

foreach $thisfile (@out) 
{ 
  $updated=0; 
  $filepath=$path."\\".$thisfile; 
  if (!$quiet) { print "Processing $filepath...\n" } 
  @file=`type $filepath`;

  $buildver="";

  map
  { 
    $thisline=$_;

    # FILEVERSION 
    #  FILEVERSION 1,0,0,0 
    if ($thisline=~/(.+)FILEVERSION (\d+),(\d+),(\d+),(\d+)/) 
    {       
      $buildver="$2.$3.$4.".($5+1);
      $newline=$1."FILEVERSION $2,$3,$4,".($5+1)."\n"; 
      if (!$quiet) 
      { 
        print "Replace\n"; 
        print "   $thisline"; 
        print "with\n"; 
        print "   $newline"; 
      } 
      $updated=1; 
      $_=$newline; 
    }    

    # FileVersion 
    #              VALUE "FileVersion", "1.0.0.0" 
    if ($thisline=~/(.+)VALUE \"FileVersion\", \"(\d+).(\d+).(\d+).(\d+)\"/) 
    { 
      $newline=$1."VALUE \"FileVersion\", \"$2.$3.$4.".($5+1)."\"\n"; 
      if (!$quiet) 
      { 
        print "Replace\n"; 
        print "   $thisline"; 
        print "with\n"; 
        print "   $newline\n"; 
      } 
      $updated=1; 
      $_=$newline; 
    }    
              
  } @file;
                                     
  if ($updated) 
  { 
    open OFH,">$filepath"; 
    print OFH @file; 
    close OFH; 
  }

  if (length($buildver) > 0 &&
	  length($config) > 0)
  {
    if ($thisfile=~/(.+)\.rc/)
    {
	  $buildfile=$1."-build.txt";
	  $buildpath=$path."\\..\\".$config."\\".$buildfile;
	  if (-e $buildpath) 
	  {
		if (!$quiet) { print "Updating build information file $buildpath...\n" } 

		@buildfile=`type $buildpath`;        

		$line=0; 

		map
		{
		  if (++$line == 1)
		  {
			$thisline=$_;
			if (!$quiet)
			{
			  print "Replace build\n"; 
			  print "   $thisline"; 
			  print "with\n"; 
			  print "   $buildver\n"; 
			}
			$_=$buildver."\n";
		  }
		} @ buildfile; 

		if ($line > 0)
		{
		  open OFH,">$buildpath";
		  print OFH @buildfile;
		  close OFH; 
		}                   
	  }
    }
  }
}
