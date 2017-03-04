#!/usr/local/bin/perl

# COWAbunga -
# File: time.pl
# Conference on World Affairs Scheduler
#   This file contains the time library functions to control session
#   expiration and conference years
#   Status: STABLE

sub getEpochSeconds()
{
    return(time);
}

sub getYearName()
{
    # Get the year if not specified by parameter, biggest year wins
    # Default case is examined first

    ($DBDIRECTORY,$conference)=@_;

    $paramofy = param('y');
    open(IN,$conference);
    @year=<IN>;
    close IN;

    if($paramofy)
    {
	foreach $entry (@year)
	{
	    if ($entry =~ m/$paramofy/)
	    {
		$yearname = $entry;
	 	$yearname =~ s/.*,"YNAME//;
		$yearname =~ s/EMANY".*//;
		chomp($yearname);
		$yearname = addRegExp($yearname);
		return($yearname);
	    }
	}
    }

    else
    {
	@year = sort yearSort (@year);
	@year = reverse(@year);
        $size=@year;

	$thisyearname = $year[$size-1];
	$thisyearname =~ s/.*"YNAME//;
	$thisyearname =~ s/EMANY".*//;
	chomp($thisyearname);
	$thisyearname = addRegExp($thisyearname);
        return($thisyearname);
    }
}

sub getYearID()
{
    # Get the year if not specified by parameter, biggest year wins
    # Default case is examined first

    ($DBDIRECTORY,$conference)=@_;
    if(param('y'))
    {
	return(param('y'));
    }

    else
    {
    	open(IN,$conference);
    	@year=<IN>;
    	close IN;

	@year = sort yearSort (@year);
	@year = reverse(@year);
        $size=@year;

	$thisyearid = $year[$size-1];
   	$thisyearid =~ s/.*"YID//;
	$thisyearid =~ s/DIY".*//;
	chomp($thisyearid);
        return($thisyearid);
    }
}

sub getAllYears()
{
    # Used by conference box to propogate available years in the database.
    # Builds an array based off a listing of panel tables with years

    ($DBDIRECTORY,$conference)=@_;

    open(IN,$conference);
    @yearname=@yearid=<IN>;
    close IN;

    @yearname=sort yearSort (@yearname);
    @yearid=sort yearSort (@yearid);

    foreach $entry (@yearname)
    {
        $entry =~ s/.*"YNAME//;
        $entry =~ s/EMANY".*//;
        chomp($entry);
	$entry = addRegExp($entry);
    }

    foreach $entry (@yearid)
    {
	$entry =~ s/.*"YID//;
	$entry =~ s/DIY".*//;
	chomp($entry);
    }

    return(\@yearname,\@yearid);
}

sub yearSort
{
    ($field1a,$field2a)=split(/"YNAME/, $a);
    ($field1b,$field2b)=split(/"YNAME/, $b);

    $field2b cmp $field2a;
}

sub convertDaytoDate()
{
    # Used to determine conference day of week without need
    # of unnecessary db storage.

    ($day,$year)=@_;

    # Isolate April using UNIX cal
    $cal=`${CAL} 4 $yearname`;
    @cal = split("\n",$cal);

    # Grab the 2nd week of April
    $interest = $cal[3];
    $interest =~ s/(^....)//;
    $interest =~ s/\ \ /\ /g;
    @days = split("\ ",$interest);

    if ($day =~ /Monday/) { $DD = $days[0]; }
    if ($day =~ /Tuesday/) { $DD = $days[1]; }
    if ($day =~ /Wednesday/) { $DD = $days[2]; }
    if ($day =~ /Thursday/) { $DD = $days[3]; }
    if ($day =~ /Friday/) { $DD = $days[4]; }

    return("April $DD, $yearname");
}

sub roundUp()
{
    # Calculates number of pages needed when a decimal place screws things up

    ($n)=@_;
    return(($n == int($n)) ? $n : int($n + 1))
}

1;
