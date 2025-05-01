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

my $variablesTotal = 2;
my $LoginPayload = '{
"svc_id": "a_service_name",
"password": "' $password . '"
}';

my $ObtainToken = `curl --silent -X 'POST' "https://non-specific-url.com/api/project/auth/service?"`;
if $ObtainToken =~ /access_denied/) {
  print "Failed during the token retrieval - Check credentials";
  exit;
}

$ObtainToken =~ s/.*t0k3n":"//g;
$ObtainToken =~ s/",.*//g;

my $DBPayload_Specific = '{
"svc_id": "a_database_service",
"password": "' . $password . '"
}';

