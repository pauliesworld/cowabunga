#!/usr/local/bin/perl

# COWAbunga -
# File: import.pl
# Conference on World Affairs Scheduler
#   Import entries already located in the main CWA website database
# Status: STABLE

sub importCWAParticipants()
{ 
    # There is a directory located in /htdocs/cwa/data/YEAR/db.flat that
    # contains participants from previous years including this one.  We convert
    # from their tab delimited format and add each into our own CSV database.

    ($sid,$fname,$lname,$dbdir,$dbyear,$file,$idfile,$logfile,
	$year,$userfile,$sessifile)=@_;

    $y=param('y');

    chomp($dbdir); chomp($dbyear);
    open(IN,"<","${dbdir}${dbyear}/db.flat");
    @cwaparttable = <IN>;
    close(IN);

    @cwaparttable = grep /\S/, @cwaparttable;
    foreach $entry (@cwaparttable) 
    { 
	chomp($entry);
	$entry =~ s/(.)/checkForNonASCII($1)/eg;
	$fname=$lname=$entry;
	$lname=~s/\t.*//;
	$fname=~s/$lname\t//;
	$fname=~s/\t.*//;
	addParticipants($sid,$fname,$lname,$notes,$file,$idfile,$logfile,
	$year,$userfile,$sessifile,1);
	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	sid=$sid&pid=peditor&y=$y\">";
    }
}

sub checkForNonASCII()
{
    # Eliminates foreign letters, character by character
    # Yeah it's slow, but this function should only be called once a year
    # so it's worth it

    if (ord($_[0]) < 128)
    { # ASCII
	return $_[0];
    }
    
    else
    { # Non-ASCII
    	return sprintf('&#x%04X;', ord($_[0]));
    }
}

1;
