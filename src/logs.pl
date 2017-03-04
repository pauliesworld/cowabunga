#!/usr/local/bin/perl

# COWAbunga -
# File: logs.pl
# Conference on World Affairs Scheduler
#   This file contains the logging library that keeps track
#   of all database commits
#   Status: STABLE

sub logViewerPage()
{
    # Create the log viewing page.  We also need to examine each log to get rid
    # of old logs that may slow down the system.  This is specified in CONFIGURE

    ($logfile,$LOGREMOVAL,$keyword,$sid,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login?msg=2&
	sid=$sid\">";
        exit 1;
    }

    open(IN,"<",$logfile);
    @logtable=<IN>;
    close(IN);

    purgeOldLogs(\@logtable,$LOGREMOVAL);
    @logtable = reverse sort @logtable;

    # If someone used the search field, grep the logtable for it
    if ($keyword)
    {
        $keyword =~ s/\*/\\*/g;
    	$keyword =~ s/\+/\\+/g;
    	$keyword =~ s/\./\\./g;
    	$keyword =~ s/\?/\\?/g;
    	$keyword =~ s/\[/\\[/g;
    	$keyword =~ s/\]/\\]/g;
        $keyword =~ s/\^/\\^/g;
        @logtable = grep { /$keyword/i } @logtable;
	$keywordmsg = "You searched for $keyword";
    }

    print( STDOUT <<HTML );

<div id="content">
<h2>Log Viewer</h2>
<hr size="1" noshade>
$keywordmsg
<div class="listItems">
<form action=cwasys method=GET>
<input type=hidden name=sid value=$sid>
<input type=hidden name=pid value=logviewer>
<input type=hidden name=y value=$year>
<input class=textfield class=textfield class=textfield type=text name=keyword>
<input type=submit value="Search Logs">
</form>
<table cellpadding=0 class=bettyTable width="700">
<th> Date/Time </th> <th> IP Address </th> <th> Username </th> <th> Table/File </th> <th> Change Message </th>
HTML

    foreach $log (@logtable)
    {
	$date=$ipaddy=$username=$table=$msg=$log;
	$date =~ s/"DATE//;
	$date =~ s/ETAD",.*//;
	$ipaddy =~ s/.*,"IP//;
	$ipaddy =~ s/PI",.*//;
	$username =~ s/.*,"UNAME//;
	$username =~ s/EMANU",.*//;
	$table =~ s/.*,"TBL//;
	$table =~ s/LBT",.*//;
	$msg =~ s/.*,"MSG//;
	$msg =~ s/GSM".*//;
	$msg = addRegExp($msg);
	print "<tr><td>$date</td><td>$ipaddy</td><td>$username</td>";
	print "<td>$table</td><td>$msg</td></tr>";
    }

    print (STDOUT <<HTML);
</table>
</div>
</div>
HTML
}

sub addLogMessage()
{
    # Given a log message, grab the user's ip address and username along with
    # a timestamp to create a message.  Logs are tracked with epoch seconds so 
    # that they are exactly displayed and removed correctly.

    ($table,$msg,$logfile,$sid,$userfile,$sessifile)=@_;
    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login?msg=2&
	sid=$sid\">";
        exit 1;
    }
  
    $ipaddy="$ENV{'REMOTE_ADDR'}";
    $date=`${DATE} '+%Y-%m-%d-%H:%M'`;
    chomp($date);
    $username = getUserName($sid,$userfile,$sessifile);
    chomp($username);
    $epoch = getEpochSeconds();
    chomp($epoch);

    $thislog = "
	\"DATE${date}ETAD\",
	\"IP${ipaddy}PI\",
	\"UNAME${username}EMANU\",
	\"TBL${table}LBT\",
	\"MSG${msg}GSM\",
	\"EPOCH${epoch}HCOPE\"
	";
    $thislog =~ s/\t|\n//g;
    addTableObject($thislog,$logfile);
}

sub purgeOldLogs()
{
    # LOGREMOVAL variable is specified in CONFIGURE in days.  Usually set to
    # 1 day to keep the log file size down to a minimum.

    ($log,$LOGREMOVAL)=@_;

    @logtable = @$log;

    $datenow=getEpochSeconds();
    chomp($datenow);
    $datenow+=0;

    foreach $entry (@logtable)
    {
        $dateold=$entry;

	# Isolate just the epoch timestamp
        $dateold =~ s/.*"EPOCH//;
        $dateold =~ s/HCOPE".*//;
        $dateold+=0;

	# 86400 seconds in a day times log removal = days to keep logs
        if(($datenow-$dateold) > (${LOGREMOVAL}*86400))
        {
	    delete $logtable[$logcount];
        }
	
	$logcount++;
    }

    deleteTableObject(\@logtable,$logfile);
}

1;
