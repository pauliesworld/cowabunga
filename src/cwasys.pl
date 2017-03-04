#!/usr/local/bin/perl

# COWAbunga -
# File: cwasys
# Conference on World Affairs Scheduler
#   This file contains the main page that communicates
#   with the library to display results

require "../CONFIGURE";

my $conference="${DBDIRECTORY}conference.db";
my $confcount="${DBDIRECTORY}conference.count";
my $yearname=getYearName($DBDIRECTORY,$conference);
my $year=getYearID($DBDIRECTORY,$conference);
my $userfile="${DBDIRECTORY}users.db";
my $logfile="${DBDIRECTORY}logs.db";
my $moderfile="${DBDIRECTORY}moderators$year.db";
my $venuefile="${DBDIRECTORY}venues$year.db";
my $partifile="${DBDIRECTORY}participants$year.db";
my $produfile="${DBDIRECTORY}producers$year.db";
my $panelfile="${DBDIRECTORY}panels$year.db";
my $tagsfile="${DBDIRECTORY}tags$year.db";
my $sessifile="${DBDIRECTORY}sessions.db";
my $pavailfile="${DBDIRECTORY}partavail${year}";
my $vavailfile="${DBDIRECTORY}venavail${year}";
my $moderidfile="${DBDIRECTORY}moderators$year.count";
my $venueidfile="${DBDIRECTORY}venues$year.count";
my $partiidfile="${DBDIRECTORY}participants$year.count";
my $produidfile="${DBDIRECTORY}producers$year.count";
my $panelidfile="${DBDIRECTORY}panels$year.count";
my $tagsidfile="${DBDIRECTORY}tags$year.count";
my $useridfile="${DBDIRECTORY}users.count";
my $confile="${DBDIRECTORY}conflicts$year.db";
my $condisfile="${DBDIRECTORY}conflictsquiet$year.db";
my $dbdir="/htdocs/cwa/data/";

# File handler dumps all the tables into arrays and returns a reference for each
($moderz,$partiz,$venuez,$panelz,$produz,$tagz,$sessi,$usert) = 
fileHandler($HOME,$DBDIRECTORY,$moderfile,$partifile,$venuefile,$panelfile,
$produfile,$tagsfile,$sessifile,$userfile);

my @partitable=@$partiz;
my @venuetable=@$venuez;
my @modertable=@$moderz;
my @produtable=@$produz;
my @paneltable=@$panelz;
my @tagtable=@$tagz;
my @sessitable=@$sessi;
my @usertable=@$usert;
@pantable=@paneltable;

mainHandler();

sub mainHandler()
{
    print "Content-type: text/html\r\n\r\n";
    $numconflicts=getNumberofConflicts($confile);
    ########## Passed browser URL variables ##########

    $sid = param('sid');
    sessionCheck(\@sessitable,$sid,$sessifile);
    $pid = param('pid');
    displayLeftFrame($sid);
    $search = param('search');
    $add = param('add');
    $edit = param('edit');
    $delete = param('delete');
    $newyearname = param('newyearname');
    $schedule = param('schedule');
    $tableid = param('tableid');
    $fname = param('fname');
    $lname = param('lname');
    $notes = param('notes');
    $loc = param('loc');
    $space = param('space');
    $panel = param('panel');
    $tagname = param('tagname');
    $day = param('day');
    $stime = param('stime');
    $ftime = param('ftime');
    $mpbox = param('mpbox');
    $ppbox = param('ppbox');
    $pubox = param('pubox');
    $vpbox = param('vpbox');
    $upbox = param('upbox');
    $cpbox = param('cpbox');
    $tagbox = param('tagbox');
    $delpbox = param('delpbox');
    $delvbox = param('delvbox');
    $delmbox = param('delmbox');
    $delprbox = param('delprbox');
    $panbox = param('panbox');
    $confd = param('confd');
    $moderform = param('moderform');
    $moderd = param('moderd');
    $partform = param('partform');
    $partd = param('partd');
    $prodform = param('prodform');
    $prodd = param('prodd');
    $venform = param('venform');
    $vend = param('vend');
    $panelform = param('panelform');
    $paneld = param('paneld');
    $userform = param('userform');
    $userd = param('userd');
    $tagform = param('tagform');
    $tagd = param('tagd');
    $modid = param('modid');
    $partid = param('partid');
    $prodid = param('prodid');
    $tagid = param('tagid');
    $venid = param('venid');
    $username = param('username');
    $passwd = param('passwd');
    $confirm = param('passwdconfirm');
    $email = param('email');
    $userid = param('userid');
    $level = param('level');
    $t = param('t');
    $f = param('f');
    $page = param('page');
    $scheduleedit = param('scheduleedit');
    $start = param('start');
    $max = param('max');
    $paneledit = param('paneledit');
    $panelid = param('panelid');
    $con = param('con');
    $dbyear = param('dbyear');
    $import = param('import');
    $y = param('y');
    $sesnum = param('sesnum');
    $altbox = param('altbox');
    $delabox = param('delabox');
    $object = param('object');
    $type = param('type');
    $addtag = param('addtag');
    $deltag = param('deltag');
    $msg = param('msg');
    $condisable = param('condisable');
    $conundisable = param('conundisable');
    $keyword = param('keyword');
    $snapbox = param('snapbox');
    $snapform = param('snapform');
    $snapshot = param('snapshot');
    $snaprestore = param('snaprestore');
    $confid = param('confid');
    $confyear = param('confyear');

    ####################################################

    if($search)
    {
	searchPage($sid,$search,$year);
    }

    elsif($pid =~ m/editaccount/)
    {
	if ($edit =~ m/account/)
	{
	    editUserAccount($sid,$userid,$username,$passwd,$confirm,$level,
		$email,$userfile,$logfile,$year);
	}

        else
	{
	    editUserAccountPage($sid,$msg,\@sessitable,\@usertable);
	}
    }

    elsif($add)
    {
	if($add =~ m/conference/)
	{
	    addConference($sid,$DBDIRECTORY,$conference,$confcount,$logfile,
		$newyearname,$year,$userfile,$sessifile);
	}

	elsif($add =~ m/moderator/)
	{
	    addModerators($sid,$fname,$lname,$notes,$moderfile,$moderidfile,
		$logfile,$year,$userfile,$sessifile);
        }

   	elsif($add =~ m/participant/)
	{
	    addParticipants($sid,$fname,$lname,$notes,$partifile,$partiidfile,
		$logfile,$year,$userfile,$sessifile);
	}

	elsif($add =~ m/producer/)
	{
	    addProducers($sid,$fname,$lname,$notes,$produfile,$produidfile,
		$logfile,$year,$userfile,$sessifile);
	}

        elsif($add =~ m/venue/)
        {
            addVenues($sid,$loc,$space,$notes,$venuefile,$venueidfile,$logfile,
		$year,$userfile,$sessifile);
        }

	elsif($add =~ m/panel/)
	{
	    addPanels($sid,$panel,$panelfile,$panelidfile,$confile,$condisfile,
		$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile,
		$day,$f,\@partitable);
	}

	elsif($add =~ m/user/)
	{
	    addUsers($sid,$username,$passwd,$confirm,$email,$level,$useridfile,
		$logfile,$year,$userfile,$sessifile);
	}

	elsif($add =~ m/tag/)
	{
	    addTags($sid,$tagname,$tagsfile,$tagsidfile,$logfile,$year,
		$userfile,$sessifile);
	}
	
	elsif($add =~ m/snapshot/)
	{
	    createSnapshot($DBDIRECTORY,$year,$sid,$userfile,$sessifile);
	}
    }

    elsif($delete)
    {
	if ($delete =~ m/conference/)
	{
	    if ($confd !~ /Delete/)
	    {
		editConferencePage($conference,$cpbox,$year,$userfile,
		$sessifile);
	    }

	    else
	    {
	    	deleteConference($sid,$cpbox,$conference,$logfile,$year,
		$DBDIRECTORY,$userfile,$sessifile);
	    }
	}

	elsif ($delete =~ m/moderator/)
	{
	    if ($moderd !~ /Delete/)
	    {
	        editModeratorPage($sid,$mpbox,$moderfile,$year,$userfile,
		$sessifile);
	    }

	    else
	    {
		deleteModerators($sid,$mpbox,$moderfile,$confile,$condisfile,
		$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile);
	    }
	}
	
	elsif ($delete =~ m/participant/)
	{
	    if ($partd !~ /Delete/)
	    {
		editParticipantPage($sid,$ppbox,$partifile,$year,$userfile,
		$sessifile);
	    }
	
	    else
	    {
	        deleteParticipants($sid,$ppbox,$partifile,$confile,$condisfile,
		$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile);
            }
	}
	
        elsif($delete =~ m/venue/)
        {
            if ($vend !~ /Delete/)
            {
                editVenuePage($sid,$vpbox,$venuefile,$year,$userfile,
		$sessifile);
            }  
            
	    else
            {
		deleteVenues($sid,$vpbox,$venuefile,$confile,$condisfile,
		$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile);
	    }
	}
        
       	elsif ($delete =~ m/producer/)
       	{
            if ($prodd !~ /Delete/)
            {
               	editProducerPage($sid,$pubox,$produfile,$year,$userfile,
		$sessifile);
            }
            
       	    else
            {
                deleteProducers($sid,$pubox,$produfile,$confile,$condisfile,
		$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile);
            }
        }

        elsif($delete =~ m/panel/)
        {
            if ($paneld =~ /Delete/)
            {
                deletePanels($sid,$panbox,$panelfile,$confile,$condisfile,
                $pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile);
            }
	
	    else
            {
                editPanelPage($sid,$panbox,$panelfile,$moderfile,$partifile,
		$venuefile,$produfile,$pavailfile,$vavailfile,$confile,
		$condisfile,$year,$userfile,$sessifile);
            }
        }

	elsif($delete =~ m/user/)
	{
	    if ($userd !~ /Delete/)
	    {
	        editAdminUserPage($sid,$upbox,$msg,$year,$userfile,$sessifile);
	    }

	    else
       	    {
	        deleteUsers($sid,$upbox,$logfile,$year,$userfile,$sessifile);
	    }
	}
        
        elsif($delete =~ m/tag/)
        {
            if ($tagd !~ /Delete/)
            {
                editTagPage($sid,$tagbox,$tagsfile,$year,$userfile,$sessifile);
            }

            else
            {
                deleteTags($sid,$tagbox,$tagsfile,$confile,$condisfile,$logfile,
		$year,$userfile,$sessifile);
            }
        }

	elsif($delete =~ m/snapshot/)
	{
	    if ($snaprestore =~ m/Restore/)
	    {
		restoreSnapshot($DBDIRECTORY,$snapshot,$year,$sid,$userfile,
		$sessifile);
	    }

	    else
	    {
		deleteSnapshot($DBDIRECTORY,$snapshot,$year,$sid,$userfile,
		$sessifile);
	    }
	}
    }

    elsif($edit)
    {
	if ($edit =~ m/conference/)
	{
	    editConference($confid,$confyear,$conference,$logfile,$year,
		$userfile,$sessifile);
	}

	if ($edit =~ m/moderator/)
	{
	    editModerators($sid,$modid,$fname,$lname,$notes,$moderfile,$logfile,
		$year,$userfile,$sessifile);
	}

	elsif ($edit =~ m/participant/)
	{
	    editParticipants($sid,$partid,$fname,$lname,$notes,$partifile,
		$logfile,$year,$userfile,$sessifile);	
	}
	
 	elsif ($edit =~ m/venue/)
	{
  	    editVenues($sid,$venid,$loc,$space,$notes,$venuefile,$logfile,
		$year,$userfile,$sessifile);
	}
        
        elsif ($edit =~ m/producer/)
        {
             editProducers($sid,$prodid,$fname,$lname,$notes,$produfile,
		$logfile,$year,$userfile,$sessifile);
        }

	elsif ($edit =~ m/user/)
    	{
            editAdminUsers($sid,$userid,$username,$passwd,$confirm,$email,
		$level,$logfile,$year,$userfile,$sessifile);
    	}

	elsif ($edit =~ m/tag/)
	{
	    editTags($sid,$tagid,$tagname,$tagsfile,$logfile,$year,$userfile,
		$sessifile);
	}
    }

    elsif($paneledit)
    {
	if($ppbox)
	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$ppbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
	}

        elsif($vpbox)
        {
	    editPanels($sid,$panelfile,$paneledit,$panelid,$vpbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }
	
  	elsif($mpbox)
	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$mpbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);	
	}
       
        elsif($pubox)
        {
            editPanels($sid,$panelfile,$paneledit,$panelid,$pubox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

	elsif($panel)
	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$panel,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

        elsif($day)
    	{
            editPanels($sid,$panelfile,$paneledit,$panelid,$day,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

    	elsif($stime)
    	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$stime,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

	elsif($ftime)
	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$ftime,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);	
        }

	elsif($sesnum)
	{
	    editPanels($sid,$panelfile,$paneledit,$panelid,$sesnum,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);	
        }
	
	elsif($altbox)
        {
            editPanels($sid,$panelfile,$paneledit,$panelid,$altbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
	}

        elsif($delabox)
        {
	    editPanels($sid,$panelfile,$paneledit,$panelid,$delabox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);	
        }

        elsif($notes)
        {
            editPanels($sid,$panelfile,$paneledit,$panelid,$notes,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

        elsif($delpbox)
        {
	    editPanels($sid,$panelfile,$paneledit,$panelid,$delpbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

        elsif($delvbox)
    	{
       	    editPanels($sid,$panelfile,$paneledit,$panelid,$delvbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
     	}

	elsif($delmbox)
   	{
            editPanels($sid,$panelfile,$paneledit,$panelid,$delmbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);	
       	}

    	elsif($delprbox)
    	{
       	    editPanels($sid,$panelfile,$paneledit,$panelid,$delprbox,$confile,
		$condisfile,$pavailfile,$vavailfile,$logfile,$year,$userfile,
		$sessifile);
        }

	else
	{
    	    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?delete
		=panel&panbox=$panelid&sid=$sid&panelform=Edit&y=$year\">";
	}	
    }

    elsif($scheduleedit)
    {
	if ($scheduleedit =~ m/participant/)
	{
	    addParticipantAvailability($pavailfile,$partifile,$year,$day,$start,
		$max,$page);
	}

	elsif ($scheduleedit =~ m/venue/)
	{
	    addVenueAvailability($vavailfile,$venuefile,$year,$day,$start,$max,
		$page);
	}
    }

    elsif($condisable)
    {
	conflictDisable($confile,$condisfile,$condisable,$page);
    }
	elsif($conundisable)
	{
	    conflictUnDisable($confile,$condisfile,$conundisable,$page);
	}

    elsif($addtag || $deltag)
    {
	addelTagToTableObject($addtag,$deltag,$tagbox,$object,$year,$userfile,
		$sessifile,$confile,$condisfile);
    }

    elsif($import)
    {
	importCWAParticipants($sid,$fname,$lname,$dbdir,$dbyear,$partifile,
		$partiidfile,$logfile,$year,$userfile,$sessifile);
    }

    ########## Planner ###########
    elsif($pid =~ m/schedule/)
    {
    	schedulePage($sid,$moderz,$partiz,$venuez,$panelz,$page,$t,$year,$day);
    }
	elsif($pid =~ m/moderators/)
	{
	    moderatorPage($sid,$moderfile,$page,$t,$year);
	} 

	elsif($pid =~ m/participants/)
	{
	    participantPage($sid,$partifile,$page,$t,$year);
	}

	elsif($pid =~ m/producer/)
	{
	    producerPage($sid,$produfile,$page,$t,$year);
	}

	elsif($pid =~ m/venues/)
	{
	    venuePage($sid,$venuefile,$page,$t,$year);
	}

    	elsif($pid =~ m/readonly/)
    	{
	    userPlannerPage($sid,$object,$panelid,$partid,$prodid,$modid,$venid,
		$year);
	}

    ########## Conference Editor ###########
    elsif($pid =~ m/ceditor/)
    {
        addConferencePage($sid,\@paneltable,$DBDIRECTORY,$conference,$year,
		$userfile,$sessifile);
    }
        elsif($pid =~ m/meditor/)
        {
            addModeratorPage($sid,\@modertable,$userfile,$sessifile);
    	}

        elsif($pid =~ m/peditor/)
        {
            addParticipantPage($sid,\@partitable,$dbdir,$userfile,$sessifile);
        }

        elsif($pid =~ m/proeditor/)
        {
            addProducerPage($sid,\@produtable,$userfile,$sessifile);
        }

        elsif($pid =~ m/veditor/)
        {
            addVenuePage($sid,\@venuetable,$userfile,$sessifile);
        }

	elsif($pid =~ m/paneditor/)
	{
	    addPanelPage($sid,\@paneltable,$year,$userfile,$sessifile);
	}

        elsif($pid =~ m/pseditor/)
        {
            editSchedulePage($sid,"Participant",\@partitable,$year,$day,
		$pavailfile,$page,$t,$f);
        }

        elsif($pid =~ m/vseditor/)
        {
            editSchedulePage($sid,"Venue",\@venuetable,$year,$day,$vavailfile,
		$page,$t);
        }

	elsif($pid =~ m/conflicts/)
	{
	    conflictPage($sid,$confile,$condisfile,$panelfile,$type,$con,$year,
		$userfile,$sessifile);
	}

	elsif($pid =~ m/othercon/)
	{
	    noVenueOrModeratorPage($sid,$type,$confile,$year,$userfile,$sessifile);
	}

    ########## System Editor ###########
    elsif($pid =~ m/ucpanel/)
    {   
	adminUserPage($sid,\@usertable,$msg,$userfile,$sessifile);
    }
  	elsif($pid =~ m/teditor/)
	{
	    addTagsPage($sid,\@tagtable,$userfile,$sessifile);
        }

	elsif($pid =~ m/logviewer/)
	{
	    logViewerPage($logfile,$LOGREMOVAL,$keyword,$sid,$userfile,
		$sessifile);
	}

	elsif($pid =~ m/snapshots/)
	{
	    snapshotPage($DBDIRECTORY,$year,$sid,$userfile,$sessifile);
	}

    else
    {   	
        mainPage();
    }

    footer();

    exit 0;
}

sub displayLeftFrame()
{
    ($sid)=@_;
    $name=getUserName($sid,$userfile,$sessifile);
    $level=getAccessLevel($sid,$userfile,$sessifile);
    $date = `${DATE} +'%B %e, %Y'`;

        print( STDOUT <<HTML );
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Conference on World Affairs Scheduler</title>
<link href="${URLCSS}COWA.css" rel="stylesheet" type="text/css">
<link href="${URLCSS}print.css" rel="stylesheet" media="print" type="text/css">
</head>
<body bgcolor="#ffffff" onLoad="focus();search.search.focus()">
<div id="wrapper">
<div id="header">
<div id="headerleft">
COWAbunga Scheduling System
</div>
<div id="headerright">
$date &nbsp&nbsp&nbsp
</div>
</div>
<div id="navbar">
<center><a href="cwasys.pl?sid=$sid&y=$year"><img alt="logo" src="${URLIMG}cwa_logo.gif" border="0"></a></center>
<form name="search" action="cwasys.pl" method="GET">
<font color="#ffffff" face="verdana" size="1"><b>Logged in as $name</b></font><br>
<a href="cwasys.pl?sid=$sid&pid=editaccount&y=$year"><font color="#ffffff" face="verdana" size="1">[ Edit Account ]</font></a>
<a href="login.pl?msg=3&sid=$sid"><font color="#ffffff" face="verdana" size="1">[ Logout ]</font></a><br><br>
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="text" name="search" value="" size="20">
<input type="submit" value="Search">
</form>

<script type="text/javascript">
<!--
    function changeYear(selection)
    {
        window.location = "cwasys.pl?sid=$sid&pid=$pid&y="+selection;
    }

//-->
</script>

<form name="year" action="">
Year:
<select onChange="changeYear(this.options[this.selectedIndex].value)">
HTML

    ($yearnam,$yearid)=getAllYears($DBDIRECTORY,$conference);
    @yearnam = @$yearnam;
    @yearid = @$yearid;
    chomp($yearname);

    $tempyearname = $yearname;
    $tempyearname = removeRegExp($tempyearname);

    foreach $entry (@yearnam)
    {
	if ($entry =~ m/$tempyearname/)
        {
	    $sel="selected";
   	}
	$entry = addRegExp($entry);
        print "<option value=\"$yearid[$yearcount]\" $sel>$entry</option>";
	$sel="";
	$yearcount++;
    }

    print(STDOUT <<HTML );
</select>
</form>

<ul class="viewlink">
<li><font color="#ffffff" face="verdana" size=1><b>Planner View</b></font></li>
<hr size="1" color="#ffffff" align="left" width="195" noshade>
<li><a href="cwasys.pl?sid=$sid&pid=schedule&y=$year">Schedule</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=participants&y=$year">Participants</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=producers&y=$year">Producers</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=moderators&y=$year">Moderators</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=venues&y=$year">Venues</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=conflicts&y=$year">
HTML
    if($numconflicts == 0)
    {
        print "<font color=\#dfffff>0 Conflicts</font></a></li>";
    }

    else
    {
        print "<font color=red>$numconflicts Conflicts</font></a></li>";
    }
print (STDOUT <<HTML);
</ul>
HTML

    if($level =~ m/coord|admin/)
    {
	print( STDOUT <<HTML );
<ul class="editlink">
<li><font color="#ffffff" face="verdana" size=1><b>Coordinator View</b></font></li>
<hr size="1" color="#ffffff" align="left" width="195" noshade>
<li><a href="cwasys.pl?sid=$sid&pid=ceditor&y=$year">Edit Conference</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=peditor&y=$year">Edit Participants</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=proeditor&y=$year">Edit Producers</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=meditor&y=$year">Edit Moderators</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=veditor&y=$year">Edit Venues</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=paneditor&y=$year">Edit Panels</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=pseditor&y=$year">Edit Availability</a></li>
</ul>
HTML
    }

    if($level =~ m/admin/)
    {
	print( STDOUT <<HTML );
<ul class="userlink">
<li><font color="#ffffff" face="verdana" size=1><b>Administrator View</b></font></li>
<hr size="1" color="#ffffff" align="left" width="195" noshade>
<li><a href="cwasys.pl?sid=$sid&pid=ucpanel&y=$year">User Control Panel</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=teditor&y=$year">Tag Editor</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=logviewer&y=$year">Log Viewer</a></li>
<li><a href="cwasys.pl?sid=$sid&pid=snapshots&y=$year">Snapshots</a></li>
</ul>
HTML
    }
print( STDOUT <<HTML );
</div>
HTML
}

sub mainPage()
{
    print (STDOUT <<HTML);
<div id="content">
<h2>CWA Scheduler</h2>
<hr size="1" noshade>
    <table class=bettyTable cellpadding=0 cellspacing=0 width="700">
	<tr>
	    <th>
		Project Description
	    </th>
	</tr>
	<tr>
	    <td>
		<p>COWAbunga is a scheduling system for the <a href="http://www.colorado.edu/cwa">Conference on World Affairs</a>.  It is designed to help the organizers plan out an entire conference week by joining participants, producers, venues, and moderators into panels and raising conflicts anytime a problem occurs.</p>
		<p>The sponsors for this project are Fred Ris and Malinda Painter, two volunteers for CWA.</p>
	    </td>
	</tr>
    </table>
<br><br>
</div>
HTML
}

sub footer()
{
    $ipaddy = $ENV{'REMOTE_ADDR'};
    $linecount = `${CAT} ${SRCDIR}* ${HOME}css/* | ${WC}`;
    print(STDOUT <<HTML);
    <div id="footer">
        $ipaddy &#151; Linecount $linecount &#151; Built for the Conference on World Affairs
    </div>
</body>
</html>
HTML
}
