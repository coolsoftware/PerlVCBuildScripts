##########################################################################################
#
# Copyright 2013 Coolsoftware. http://blog.coolsoftware.ru/
#
# Protect/Make build information
#
# Example of usage in Visual Studio 2010 IDE
#   Configuration Properties->Build Events->Post-Build Event->Command Line:
#
#   perl $(ProjectDir)..\makebuildinfo.pl $(TargetPath) $(ProjectDir)..\$(TargetName).aspr
#
# Example of build info file (myapp-build.txt):
#
# 1.1.0.0
# http://127.0.0.1/myapp.exe
# myapp.exe
# b9f2c07999dcafe9fe544a00521829c1
#
##########################################################################################

use Digest::MD5 qw(md5_hex);

$exepath=shift;
$asprpath=shift;
$quiet=shift;

if (-e $exepath)
{
  if ($exepath=~/(.+)\.(exe|dll)/)
  {
    $exetype=$2;
	
	if (length($asprpath) > 0)
	{
	  if (!$quiet) { print "asprotect -process $asprpath\n" } 
	  $output = `asprotect -process $asprpath`;
	  print $output;
	}
	
    open EXEFILE, $exepath;
    binmode EXEFILE;
    $md5_hash = Digest::MD5->new;

#    
#    $md5_salt = "mysalt";
#    $md5_hash->add($md5_salt);
#    
    
    while (<EXEFILE>) {
        $md5_hash->add($_);
    }
    close(EXEFILE);

    $md5 = $md5_hash->hexdigest;

    if (length($md5) > 0)
    {
      if (!$quiet) { print "$exetype: $exepath ($md5)\n" }

      $buildpath=$1."-build.txt";

      if (-e $buildpath)
      {
        if (!$quiet) { print "Processing $buildpath...\n" } 

        @buildfile=`type $buildpath`;        

        $line=0; 

        map
        {
          if (++$line == 4)
          {
            $thisline=$_;
            if (!$quiet)
            {
              print "Replace md5\n"; 
              print "   $thisline"; 
              print "with\n"; 
              print "   $md5\n"; 
            }
            $_=$md5."\n";
          }
        } @ buildfile; 

        if ($line >= 4)
        {
          open OFH,">$buildpath";
          print OFH @buildfile;
          close OFH; 
        }
      }
    }
  }
}
