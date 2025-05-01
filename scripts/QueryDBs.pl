#!/usr/bin/perl
# Who has done this before ? Running a perl script from an ADO Pipeline !!!
# Sure there is someone else that also does this crazy ideas :)
#
my $DEBUGFLAG = 1;
my ($key, $password, $queryFile, $databaseType, $batchSize, $startAtClientId) = @ARGS;
# The ADO virutal Machines do have a space limit, and some queries can be a problem
# because they use too much of it.  This is a problem that still needs to be resolved but
# it is rare so its priority is not high.
my $DISKSPACE_STOP = 1000000;

if (($key eq "") || ($password eq "")) {
  print "key and/or password are empty";
  exit;
}

print "DEBUG: SQL File: $queryFile\n" if ($DEBUGFLAG);
print "DEBUG: Database Type: $databaseType\n" if ($DEBUGFLAG);
print "DEBUG: Batch Size: $batchSize\n" if ($DEBUGFLAG);
print "DEBUG: OUTPUT: " . $ENV{BUILD_ARTIFACTSTAGINGDIRECTORY} . "\n" if ($DEBUGFLAG);
