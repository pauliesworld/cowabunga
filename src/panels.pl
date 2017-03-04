#!/usr/local/bin/perl

# COWAbunga -
# File: panels.pl
# Conference on World Affairs Scheduler
#   This file contains the edit library functions to change
#   existing panels in the text database.
#   Status: STABLE

sub editPanelPage()
{
    # UI Module that creates and displays the schedule creation routine
    # We will refer to the 'Panel Page' and 'Schedule Page' uniformily.
    # This system requires all the primary class db tables along with part/ven 
    # avail.  Availability for participants and venues is calculated here to 
    # avoid unnecessary conflicts, but in either case conflicts.pl takes care
    # of the unobvious problems.  Each element on this schedule is a form, and 
    # any change requires a direct edit that deletes the current panel and
    # updates the newest change.  As a result, conflict detection is run on each
    # one of these types of accesses and does hinder performance.  Nevertheless,
    # the benefits of doing it this way vs. pencil & paper make this a MUCH more
    # efficient approach.  And it's cool too.

    ($sid,$panelid,$panelfile,$moderfile,$partifile,$venuefile,$produfile,
	$pavailfile,$vavailfile,$confile,$condisfile,$year,$userfile,
	$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login?msg=2&sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"PANID${panelid}DINAP",/ } @paneltable;

    if (!$exists)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys?sid=$sid&pid=paneditor&y=$year\">";
        exit 1;
    }

    $entry = join('',@sentry);
    chomp($entry);

    $panel=$altmod=$producer=$moderator=$venue=$participants=$sessinum=
	$notes=$ftime=$stime=$day=$entry;
    $panel =~ s/"PANEL//;
    $panel =~ s/LENAP".*//;
    $moderator =~ s/.*,"MODID//;
    $moderator =~ s/DIDOM".*//;
    $moderatorid = $moderator;
    @smodentry = grep { /MODID${moderator}DIDOM/ } @modertable;
    $modentry = join('',@smodentry);
    $lmodentry=$fmodentry=$modentry;
    $lmodentry =~ s/"LNAME//;
    $lmodentry =~ s/EMANL",.*//;
    $fmodentry =~ s/.*,"FNAME//;
    $fmodentry =~ s/EMANF",.*//;
    $moderator = "$fmodentry $lmodentry";
    $producer =~ s/.*,"PRODID//;
    $producer =~ s/DIDORP".*//;
    $producerid = $producer;
    @sprodentry = grep { /PRODID${producer}DIDORP/ } @produtable;
    $prodentry = join('',@sprodentry);
    $lprodentry=$fprodentry=$prodentry;
    $lprodentry =~ s/"LNAME//;
    $lprodentry =~ s/EMANL",.*//;
    $fprodentry =~ s/.*,"FNAME//;
    $fprodentry =~ s/EMANF",.*//;
    $producer = "$fprodentry $lprodentry";
    $venue =~ s/.*,"VENID//;
    $venue =~ s/DINEV",.*//;
    $venueid = $venue;
    @svenentry = grep { /VENID${venue}DINEV/ } @venuetable;
    $venentry = join('',@svenentry);
    $venentry =~ s/"VENLOC//;
    $venentry =~ s/COLNEV",.*//;
    $venue = $venentry;
    $day =~ s/.*,"DAY//;
    $day =~ s/YAD",.*//;
    $sessinum =~ s/.*,"SESID//;
    $sessinum =~ s/DISES",.*//;
    $altmod =~ s/.*DISES"//;
    $altmod =~ s/DIPTLA","NOTES.*//;

    if($day =~ m/Monday/) { $mon = "selected"; }
    if($day =~ m/Tuesday/) { $tue = "selected"; }
    if($day =~ m/Wednesday/) { $wed = "selected"; }
    if($day =~ m/Thursday/) { $thur = "selected"; }
    if($day =~ m/Friday/) { $fri = "selected"; }

    $stime =~ s/.*,"STIME//;
    $stime =~ s/EMITS",.*//;
    $ftime =~ s/.*,"FTIME//;
    $ftime =~ s/EMITF",.*//;

    $notes =~ s/.*,"NOTES//;
    $notes =~ s/SETON".*//;
    $notes =~ s/\\n/\n/g;
    $panel=addRegExp($panel);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;

    $participants =~ s/SETON","/SETON""/;
    $participants =~ s/.*SETON"//; 
    $participants =~ s/"PARTID//g;
    $participants =~ s/(DITRAP",)|(DITRAP")/\ /g;

    @ptable = split("\ ",$participants);
    @pidtable=@ptable;
    @allparti=@partitable;

    $altmod =~ s/,"ALTPID//;
    @altptable = split('DIPTLA","ALTPID',$altmod);

    foreach $entry (@pidtable)
    {
	@sentry = grep { /PARTID${entry}DITRAP/ } @partitable;
	$entry = join('',@sentry);
	chomp($entry);
    }

    foreach $entry (@altptable)
    {
        @pentry = grep { /PARTID${entry}DITRAP/ } @partitable;
        $entry = join('',@pentry);
        chomp($entry);
    }

    foreach $entry (@ptable)
    {
	@sparentry = grep { /PARTID${entry}DITRAP/ } @partitable;
	$parentry = join('',@sparentry);
	$entry = $parentry;
	$lname=$fname=$entry;
	$lname =~ s/"LNAME//;
	$lname =~ s/EMANL",.*//;
	$lname = addRegExp($lname);
	$fname =~ s/.*,"FNAME//;
	$fname =~ s/EMANF",.*//;
	$fname = addRegExp($fname);
	$entry = "$fname $lname";
    }

    $panel=addRegExp($panel);
    $notes=addRegExp($notes);
    $moderator=addRegExp($moderator);
    $producer=addRegExp($producer);
    $day=addRegExp($day);
    $stime=addRegExp($stime);
    $ftime=addRegExp($ftime);
    $sessinum=addRegExp($sessinum);

    @usertimetable=("None","8:00 am","8:30 am","9:00 am","9:30 am","10:00 am",
		"10:30 am","11:00 am","11:30 am","12:00 pm","12:30 pm",
		"1:00 pm","1:30 pm","2:00 pm","2:30 pm","3:00 pm","3:30 pm",
		"4:00 pm","4:30 pm","5:00 pm","5:30 pm","6:00 pm","6:30 pm",
		"7:00 pm","7:30 pm","8:00 pm","8:30 pm","9:00 pm","9:30 pm",
		"10:00 pm");

    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
		"1130","1200","1230","1300","1330","1400","1430","1500",
		"1530","1600","1630","1700","1730","1800","1830","1900",
		"1930","2000","2030","2100","2130","2200");

    $count=0;

    foreach $entry (@dbtimetable)
    {
	if ($entry =~ m/$stime/)
	{
	    $stimemarker = $count;
	}

        elsif ($entry =~ m/$ftime/)
        {
	    $ftimemarker = $count;
        }

	$count++;
    }

    ######## Participant Availability ########

    $not_count=0;
    $avail_count=0;

    $pavailfile = "${pavailfile}${day}.db";
    open(IN,"<",$pavailfile);
    @pavailtable = <IN>;
    close(IN);

    foreach $entry (@partitable)
    {
	#get user id
	#grep userid+day in avail tables
	#for given time slot see if time point is present
	#if none, user is available, else not available

        $userid = $entry;
	$userid =~ s/.*,"PARTID//;
	$userid =~ s/DITRAP",.*//;
	chomp($userid);

        @sfound = grep { /USERID${userid}DIRESU.*DAY${day}YAD/ } @pavailtable;
	$foundtime=$found=join('',@sfound);
	$foundtime =~ s/.*,"TIME//;
	$foundtime =~ s/EMIT".*//;
	chomp($foundtime);

	$local_count=$stimemarker;
	$local_count=$local_count+2;
	$notavailable=0;

	# For each participant in the conference year, check to see if they
        # are allowed to be in this panel by looking at the start and finish
  	# times.  On the boundaries are allowed now for back to back panels.

	while (($local_count >= $stimemarker) && ($local_count <= $ftimemarker))
	{
	    if ($foundtime =~ m/$dbtimetable[$local_count]/)
	    {
		$notavailable = 1;
	    }
	    $local_count++;
	}

	if ($notavailable == 1)
	{
	    $grepfound = grep { /,"PARTID${userid}DITRAP",/ } @pidtable;
	    if(!$grepfound)
	    {
	    	$parnotavailtable[$not_count]=$entry;	
	        $not_count++;
	    }
	}

        else
	{
	    $paravailtable[$avail_count]=$entry;
	    $avail_count++;
	}
	@sfound = ();
    }

    ######## Venue Availability ########

    $not_count=0;
    $avail_count=0;

    $vavailfile = "${vavailfile}${day}.db";
    open(IN,"<",$vavailfile);
    @vavailtable = <IN>;
    close(IN);

    foreach $entry (@venuetable)
    {
        #get venue id
        #grep venid+day in avail tables
        #for given time slot see if time point is present
        #if none, venue is available, else not available

        $userid = $entry;
        $userid =~ s/.*,"VENID//;
        $userid =~ s/DINEV",.*//;
        chomp($userid);

        @sfound = grep { /USERID${userid}DIRESU.*DAY${day}YAD/ } @vavailtable;
        $foundtime=$found=join('',@sfound);
        $foundtime =~ s/.*,"TIME//;
        $foundtime =~ s/EMIT".*//;
        chomp($foundtime);

        $local_count=$stimemarker;
	$local_count=$local_count+2;
        $notavailable=0;

        # For each venue in the conference year, check to see if it 
        # is allowed to be in this panel by looking at the start and finish
        # times.  On the boundaries are allowed now for back to back panels.

        while (($local_count >= ($stimemarker)) 
		&& ($local_count <= ($ftimemarker)))
        {
            if ($foundtime =~ m/$dbtimetable[$local_count]/)
            {
                $notavailable = 1;
            }
            $local_count++;
        }

        if ($notavailable == 1)
        {
            if($entry !~ m/VENID${venueid}DINEV/)
            {
                $vennotavailtable[$not_count]=$entry;
                $not_count++;
            }
        }

        else
        {
            $venavailtable[$avail_count]=$entry;
            $avail_count++;
        }
	@sfound = ();
    }

    # Calculate the suggested session number

    {
 	    use integer;
	    $panelNum = 1;
	    if($day =~ m/Monday/) { $panelNum = $panelNum + 1000; }
	    if($day =~ m/Tuesday/) { $panelNum = $panelNum + 2000; }
	    if($day =~ m/Wednesday/) { $panelNum = $panelNum + 3000; }
	    if($day =~ m/Thursday/) { $panelNum = $panelNum + 4000; }
	    if($day =~ m/Friday/) { $panelNum = $panelNum + 5000; }

	    if ($stimemarker < 19) { $panelNum = $panelNum + 
		((($stimemarker-1)/2)*100); }
	    else { $panelNum = $panelNum + 900; }
	    if((($stimemarker-1)%2) == 1) { $panelNum = $panelNum + 50; }

	    $timeDiff = $ftimemarker - $stimemarker;
	    if($timeDiff == 3) { $panelNum = $panelNum + 10; }
	    if($timeDiff == 4) { $panelNum = $panelNum + 30; }
	    if($timeDiff > 4) { $panelNum = $panelNum + 40; }

	    $numMatch = grep { /SESID${panelNum}DISES/ } @paneltable;
	    while ($numMatch > 0){
		  $panelNum++;
		  $numMatch = grep { /SESID${panelNum}DISES/ } @paneltable;
	    }

	    if($stimemarker == 0) { $panelNum = 0; }	    
    }

print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Panel: $panel</h2>
<hr size="1" noshade>
HTML
listAllConflicts($panelid,$confile,$condisfile);
print(STDOUT <<HTML);
<div class="listItems">
<br>
<table width="400">
<tr>

<td>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="panel">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<div style="float:left;">Panel<br> <input size="40" name="panel" value="$panel"> <br>
<input type="submit" value="Update">&nbsp;&nbsp;</div>
</form>
</td>

<SCRIPT TYPE="text/javascript"> 
<!-- 
function SuggestNum() 
{ 
	document.getElementById("sesnum").value = $panelNum;
} 
//--> 
</SCRIPT>

<td>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="sesnum">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
Session Number<br> <input name="sesnum" id="sesnum" value="$sessinum"> <br>
<input type="button" value="Suggest" onClick="SuggestNum()">
<input type="submit" value="Update">
</form>
</td>
</tr>
</table><br>

<table width = "450">
<tr>

<td>
Day&nbsp;&nbsp;
</td>
<td width=120>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="day">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<select name="day" id="day" onChange="submit();">
    <option value="Monday" $mon>Monday</option>
    <option value="Tuesday" $tue>Tuesday</option>
    <option value="Wednesday" $wed>Wednesday</option>
    <option value="Thursday" $thur>Thursday</option>
    <option value="Friday" $fri>Friday</option>
</select>
</form>
</td>

<td>
Time&nbsp;&nbsp;
</td>
<td width=95>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="stime">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML

    $count=0;

    print "<select name=stime id=\"stime\" onChange=\"submit();\">\n";
    foreach $entry (@usertimetable)
    {
  	if ($entry !~ /10:00\ pm/)
	{
	    if ($count == $stimemarker)
	    {
	    	print "<option value=\"$dbtimetable[$count]\" selected>
		$entry</option><br>\n";
	    }

	    else
	    {
	        print "<option value=\"$dbtimetable[$count]\">
		$entry</option><br>\n";
	    }
	}
	$count++;
    }
    print "</select>\n";
print(STDOUT <<HTML);
</form>
</td>

<td>
To&nbsp;&nbsp;
</td>

<td width=95>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="ftime">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
    $count=0;

    print "<select name=ftime id=\"ftime\" onChange=\"submit();\">\n";
    foreach $entry (@usertimetable)
    {
	if ($count > $stimemarker)
	{
 	    if ($count == $ftimemarker)
	    {
		print "<option value=\"$dbtimetable[$count]\" selected>
		$entry</option><br>\n";
	    }

	    else
	    {
	        print "<option value=\"$dbtimetable[$count]\">
		$entry</option><br>\n";
	    }
	}
	$count++;
    }
    print "</select>\n<br>\n";
print(STDOUT <<HTML);
</form>
</td>
</tr>
</table>
<hr align="right" width="100%">
<br/>
<table cellspacing=0 width=600 border=5><tr>
<td bgcolor="#AAAAAA"><u>Participants:</u><br>
HTML
foreach $entry (@pidtable)
{
	$fname=$lname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
	$fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
	print "$lname, $fname<br>";
}
print(STDOUT <<HTML);
<br><input type="button" id="showparbutton" value="Edit" onClick="showParticipants();"></td>
<td bgcolor="#AAAAAA"><u>Producer:</u><br>
$producer<br>
<input type="button" id="showprobutton" value="Edit" onClick="showProducers();"></td>
<td bgcolor="#AAAAAA"><u>Alternates:</u><br>
HTML
foreach $entry (@altptable)
{
	$fname=$lname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
	$fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
	print "$lname, $fname<br>";
}
print(STDOUT <<HTML);
<br><input type="button" id="showaltbutton" value="Edit" onClick="showAlternates();"></td>
<td bgcolor="#AAAAAA"><u>Moderator:</u><br>
$moderator<br>
<input type="button" id="showmodbutton" value="Edit" onClick="showModerators();"></td>
<td bgcolor="#AAAAAA"><u>Venue:</u><br>
$venue<br>
<input type="button" id="showvenbutton" value="Edit" onClick="showVenues();"></td>
<td bgcolor="#AAAAAA"><u>Notes:</u><br>
Click Edit to See<br>
<input type="button" id="shownotbutton" value="Edit" onClick="showNotes();"></td>
</tr></table>

   <script type="text/javascript" language="javascript">
	function showParticipants() {
		document.getElementById('showparbutton').style.display='none';
		document.getElementById('showprobutton').style.display='';
		document.getElementById('showaltbutton').style.display='';
		document.getElementById('showmodbutton').style.display='';
		document.getElementById('showvenbutton').style.display='';
		document.getElementById('shownotbutton').style.display='';

		document.getElementById('Participants').style.display='';
                document.getElementById('Moderators').style.display='none';
                document.getElementById('Alternates').style.display='none';
                document.getElementById('Producers').style.display='none';
                document.getElementById('Venues').style.display='none';
                document.getElementById('Notes').style.display='none';
	}
        function showProducers() {
		document.getElementById('showparbutton').style.display='';
		document.getElementById('showprobutton').style.display='none';
		document.getElementById('showaltbutton').style.display='';
		document.getElementById('showmodbutton').style.display='';
		document.getElementById('showvenbutton').style.display='';
		document.getElementById('shownotbutton').style.display='';

                document.getElementById('Participants').style.display='none';
                document.getElementById('Moderators').style.display='none';
                document.getElementById('Alternates').style.display='none';
                document.getElementById('Producers').style.display='';
                document.getElementById('Venues').style.display='none';
                document.getElementById('Notes').style.display='none';
        }
        function showAlternates() {
		document.getElementById('showparbutton').style.display='';
		document.getElementById('showprobutton').style.display='';
		document.getElementById('showaltbutton').style.display='none';
		document.getElementById('showmodbutton').style.display='';
		document.getElementById('showvenbutton').style.display='';
		document.getElementById('shownotbutton').style.display='';

                document.getElementById('Participants').style.display='none';
                document.getElementById('Moderators').style.display='none';
                document.getElementById('Alternates').style.display='';
                document.getElementById('Producers').style.display='none';
                document.getElementById('Venues').style.display='none';
                document.getElementById('Notes').style.display='none';
        }
        function showModerators() {
		document.getElementById('showparbutton').style.display='';
		document.getElementById('showprobutton').style.display='';
		document.getElementById('showaltbutton').style.display='';
		document.getElementById('showmodbutton').style.display='none';
		document.getElementById('showvenbutton').style.display='';
		document.getElementById('shownotbutton').style.display='';

                document.getElementById('Participants').style.display='none';
                document.getElementById('Moderators').style.display='';
                document.getElementById('Alternates').style.display='none';
                document.getElementById('Producers').style.display='none';
                document.getElementById('Venues').style.display='none';
                document.getElementById('Notes').style.display='none';
        }
        function showVenues() {
		document.getElementById('showparbutton').style.display='';
		document.getElementById('showprobutton').style.display='';
		document.getElementById('showaltbutton').style.display='';
		document.getElementById('showmodbutton').style.display='';
		document.getElementById('showvenbutton').style.display='none';
		document.getElementById('shownotbutton').style.display='';

                document.getElementById('Participants').style.display='none';
                document.getElementById('Moderators').style.display='none';
                document.getElementById('Alternates').style.display='none';
                document.getElementById('Producers').style.display='none';
                document.getElementById('Venues').style.display='';
                document.getElementById('Notes').style.display='none';
        }
        function showNotes() {
		document.getElementById('showparbutton').style.display='';
		document.getElementById('showprobutton').style.display='';
		document.getElementById('showaltbutton').style.display='';
		document.getElementById('showmodbutton').style.display='';
		document.getElementById('showvenbutton').style.display='';
		document.getElementById('shownotbutton').style.display='none';

                document.getElementById('Participants').style.display='none';
                document.getElementById('Moderators').style.display='none';
                document.getElementById('Alternates').style.display='none';
                document.getElementById('Producers').style.display='none';
                document.getElementById('Venues').style.display='none';
                document.getElementById('Notes').style.display='';
        }
    </script>

<table cellspacing="20" width=700>
<form action="cwasys" method="GET" name="addAvailParticipant">
<tbody id="Participants" style="display: none">
<tr>
<td>
Available Participants<br>
<input type="hidden" name="paneledit" value="ppbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createParticipantPopupBox(\@paravailtable,9,addAvailParticipant);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
<form action=cwasys method=GET name="delPanelParticipant">
<input type="hidden" name="paneledit" value="delpbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="&lt;&lt; Remove">
</td>

<td rowspan="2" >
Panel Participants<br>
HTML
createParticipantPopupBox(\@pidtable,20,delPanelParticipant);
print(STDOUT <<HTML);
</form>
</td>
</tr>

<form action="cwasys" method="GET" name="addNotAvailParticipant">
<tr>
<td> 
Unavailable Participants<br>
<input type="hidden" name="paneledit" value="ppbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createParticipantPopupBox(\@parnotavailtable,9,addNotAvailParticipant);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
</td>
</tr>
</tbody>
<tbody id="Producers" style="display: none">
<tr>
<td width=325>
Producers<br>
<form action=cwasys method=GET name="addProducer">
<input type="hidden" name="paneledit" value="pubox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createProducerPopupBox(\@produtable,9,addProducer);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
<form action=cwasys method=GET>
<input type="hidden" name="paneledit" value="delprbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="hidden" name="pubox" value="$producerid">
<input type="submit" value="&lt;&lt; Remove">
</td>

HTML
if (!$producer) { $producer = "None"; }
print(STDOUT <<HTML);
<td width=325>
$producer<br>
HTML
print(STDOUT <<HTML);
</form>
</td>
</tr>
</tbody>
<tbody id="Alternates" style="display: none"> 
<tr>

<td>
Add Alternate Participants<br>
<form action=cwasys method="GET" name="addAlternate">
<input type="hidden" name="paneledit" value="altbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createParticipantPopupBox(\@allparti,9,addAlternate);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
<form action=cwasys method=GET name="delAlternate">
<input type="hidden" name="paneledit" value="delabox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="&lt;&lt; Remove">
</td>

<td>
Alternate Participants<br>
HTML
createParticipantPopupBox(\@altptable,9,delAlternate);
print(STDOUT <<HTML);
</form>
</td>
</tr>
</tbody>
<tbody id="Moderators" style="display: none">
<tr>
<td>
Moderators<br>
<form action=cwasys method=GET name=editModerator>
<input type="hidden" name="paneledit" value="mpbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createModeratorPopupBox(\@modertable,9,editModerator);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
<form action=cwasys method=GET name=hiya>
<input type="hidden" name="paneledit" value="delmbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="hidden" name="mpbox" value="$moderatorid">
<input type="submit" value="&lt;&lt; Remove">
</td>

HTML
if (!$moderator) { $moderator = "None"; }
print(STDOUT <<HTML);
<td width=325>
$moderator<br>
HTML
print(STDOUT <<HTML);
</form>
</td>
</tr>
</tbody>
<tbody id="Venues" style="display: none">
<tr>
<td>
Available Venues<br>
<form action=cwasys method=GET name="addAvailVenue">
<input type="hidden" name="paneledit" value="vpbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createVenuePopupBox(\@venavailtable,9,addAvailVenue);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
<form action=cwasys method=GET name="delVenue">
<input type="hidden" name="paneledit" value="delvbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="hidden" name="vpbox" value="$venueid">
<input type="submit" value="&lt;&lt; Remove">
</td>

HTML
if (!$venentry) { $venentry = "None"; }
print(STDOUT <<HTML);
<td rowspan="2" width=325>
$venentry<br>
HTML
print(STDOUT <<HTML);
</form>
</td>
</tr>

<form action="cwasys" method="GET" name="addNotAvailVenue" >
<tr>
<td>
Unavailable Venues<br>
<input type="hidden" name="paneledit" value="vpbox">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createVenuePopupBox(\@vennotavailtable,9,addNotAvailVenue);
print(STDOUT <<HTML);
</td>

<td align="middle" width=100>
<input type="submit" value="Add &gt;&gt;"> <br>
</form>
</td>
</tr>
</tbody>
<tbody id="Notes" style="display: none">
<form action=cwasys method=GET>
<tr>
<td>
Notes<br>
<input type="hidden" name="paneledit" value="notes">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<textarea rows=10 cols=50 name=notes>$notes</textarea>
<input type=submit value="Update Notes">
</form>
</td>
</tr>
</table>
</tbody>
</div>
</div>
HTML
}

sub editPanels()
{
    # Accepts in the current $panelid and removes the existing entry in the 
    # panel table after a successful lock.  Formulates a new panel which
    # original primary key and appends to the end of the database with a lock.  
    # Rather than breaking on a bad lock, it will while() try until a lock can 
    # be made or else the panel gets deleted forever (BAD BAD NEWS).

    ($sid,$panelfile,$paneledit,$panelid,$this,$confile,$condisfile,
	$pavailfile,$vavailfile,$logfile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/(planner)/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login?msg=2&
	sid=$sid\">";
        exit 1;
    }

    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
                "1130","1200","1230","1300","1330","1400","1430","1500",
                "1530","1600","1630","1700","1730","1800","1830","1900",
                "1930","2000","2030","2100","2130","2200");

    $panelname = getPanelNamefromID($panelid);

    @olds = grep { /PANID${panelid}DINAP/ } @paneltable;
    $old = join('',@olds);
    chomp($old);

    $thisday = $old;
    $thisday =~ s/.*,"DAY|YAD",.*//g;
    $temppavailfile = $pavailfile;
    $tempvavailfile = $vavailfile;
    $pavailfile = "${pavailfile}${thisday}.db";
    $vavailfile = "${vavailfile}${thisday}.db";

    if (!$old)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys?sid=$sid&
	pid=paneditor&y=$year\">";
        exit 1;
    }

    $this = removeRegExp($this);
    if($paneledit =~ m/ppbox/)
    { # CHANGE - Add participant
	$new = "${old},\"PARTID${this}DITRAP\"";
	$objname=getParticipantNamefromID($this);
	$msg = "Added $objname to \"$panelname\"";
    }

    elsif($paneledit =~ m/vpbox/)
    { # CHANGE - Add Venue
    	if ($old =~ m/"VENID[0-9]+DINEV"/)
    	{ # if we are replacing a venue with a new one without removing first
	  # then we need to remove the old venue's availability
	    changeAvailability($vavailfile,$panelid);
	}

	$new = $old;	 
        $new =~ s/"VENID.*DINEV"/"VENID${this}DINEV"/;
        $objname=getVenueNamefromID($this);
        $msg = "Added $objname to \"$panelname\"";
    }

    elsif($paneledit =~ m/mpbox/)
    { # CHANGE - Add moderator
	$new = $old;
        $new =~ s/"MODID.*DIDOM"/"MODID${this}DIDOM"/;
        $objname=getModeratorNamefromID($this);
        $msg = "Added $objname to \"$panelname\"";
    }

    elsif($paneledit =~ m/pubox/)
    { # CHANGE - Add producer
        $new=$old;
        $new =~ s/"PRODID.*DIDORP"/"PRODID${this}DIDORP"/;
        $objname=getProducerNamefromID($this);
        $msg = "Added $objname to \"$panelname\"";
    }

    elsif($paneledit =~ m/panel/)
    { # CHANGE - Edit panel name
       	$new = $old;
        $new =~ s/"PANEL.*LENAP",/"PANEL${this}LENAP",/;
        $objname=getPanelNamefromID($this);
        $msg = "Panel \"$panelname\" changed to \"$objname\"";
    }

    elsif($paneledit =~ /sesnum/)
    {
        $new = $old;
        $new =~ s/"SESID.*DISES",/"SESID${this}DISES",/;
        $msg = "Session ID of \"$panelname\" changed to $this";
    }

    elsif($paneledit =~ m/day/)
    { # CHANGE - Edit day of the week
      	$new = $old;
      	$new =~ s/"DAY.*YAD",/"DAY${this}YAD",/;
        $msg = "\"$panelname\" changed to $this";
	$removeoldavail = 1;
	changeAvailability($pavailfile,$panelid);
	changeAvailability($vavailfile,$panelid);
    }

    elsif($paneledit =~ m/stime/)
    { # CHANGE - Edit start time of the panel
        $new=$oldftime=$old;
	$oldftime =~ s/.*"FTIME//;
	$oldftime =~ s/EMITF".*//;
	$oldftime+=0;
	$removeoldavail = 1;
	    
	if ($oldftime <= $this)
	{ # Add 90 minutes to the end when greater
           
	    foreach $time (@dbtimetable)
            {
                if ($time =~ m/$this/)
            	{
                    $markit = $thiscount+3;
                }

                $thiscount++;
            }

	    $thisplus=$dbtimetable[$markit];
	    $new =~ s/"STIME.*EMITS","FTIME.*EMITF",/"STIME${this}EMITS","FTIME${thisplus}EMITF",/;
	}

        else
	{	
	    $new =~ s/"STIME.*EMITS",/"STIME${this}EMITS",/;
	}

        $msg = "\"$panelname\" start time changed to $this";

	changeAvailability($pavailfile,$panelid);
	changeAvailability($vavailfile,$panelid);
    }

    elsif($paneledit =~ m/ftime/)
    { # CHANGE - Edit finish time of the panel
	$new = $old;
        $new =~ s/"FTIME.*EMITF",/"FTIME${this}EMITF",/;
        $msg = "\"$panelname\" finish time changed to $this";
	$removeoldavail = 1;
	changeAvailability($pavailfile,$panelid);
	changeAvailability($vavailfile,$panelid);
    }

    elsif($paneledit =~ m/notes/)
    { # CHANGE - Edit notes
        $new = $old;
    	$this =~ s/\n/\\n/g;
			    
     	if (grep { /PARTID/ } @paneltable)
 	{
            $new =~ s/"NOTES.*SETON",/"NOTES${this}SETON",/;
	}

	else
	{
	    $new =~ s/"NOTES.*SETON"/"NOTES${this}SETON"/;
	}

        $msg = "\"$panelname\" notes updated";
    }

    elsif($paneledit =~ m/delpbox/)
    { # CHANGE - Delete a participant
	$new=$old;
	$new =~ s/,"PARTID${this}DITRAP"//;
    	# Change availability for just THIS participant, not everybody
	changeAvailability($pavailfile,$panelid,$this);
        $objname=getParticipantNamefromID($this);
        $msg = "Deleted $objname from \"$panelname\"";
    }

    elsif($paneledit =~ m/delvbox/)
    { # CHANGE - Delete a venue
       	$new=$old;
        $new =~ s/,"VENID${this}DINEV"/,"VENIDDINEV"/;
        # Change availability for this venue
        changeAvailability($vavailfile,$panelid,$this);
        $objname=getVenueNamefromID($this);
        $msg = "Deleted $objname from \"$panelname\"";
    }

    elsif($paneledit =~ m/delmbox/)
    { # CHANGE - Delete a moderator
    	$new=$old;
       	$new =~ s/,"MODID${this}DIDOM"/,"MODIDDIDOM"/;
        $objname=getModeratorNamefromID($this);
        $msg = "Deleted $objname from \"$panelname\"";
    }

    elsif($paneledit =~ m/delprbox/)
    { # CHANGE - Delete a producer
        $new=$old;
        $new =~ s/,"PRODID${this}DIDORP"/,"PRODIDDIDORP"/;
        $objname=getProducerNamefromID($this);
        $msg = "Deleted $objname from \"$panelname\"";
    }

    elsif($paneledit =~ m/altbox/)
    { # CHANGE - Add an alternate
	$altcount=0;
	$tempnew1=$new=$old;

	if ($new =~ m/,"ALTPIDDIPTLA",/)
	{
    	    $new =~ s/,"ALTPIDDIPTLA",/,"ALTPID${this}DIPTLA",/;
	}

    	else
	{
	    $tempnew1 =~ s/.*DISES"//;
	    $tempnew1 =~ s/,"NOTES.*//;
	    $new =~ s/${tempnew1}/${tempnew1},"ALTPID${this}DIPTLA"/;
	}
        $objname=getParticipantNamefromID($this);
        $msg = "Added alternate $objname to \"$panelname\"";
    }

    elsif($paneledit =~ m/delabox/)
    { # CHANGE - Delete an alternate
    	$new=$old;
   	while ($old =~ /"ALTPID/g) { $altcount++ }

	if ($altcount == 1)
	{
	    $new =~ s/,"ALTPID${this}DIPTLA",/,"ALTPIDDIPTLA",/;
	}

	else
	{
	    $new =~ s/,"ALTPID${this}DIPTLA"//;
	}
        $objname=getParticipantNamefromID($this);
        $msg = "Deleted alternate $objname from \"$panelname\"";
    }

    @contents = grep { !/${old}/ } @paneltable;

    # delete old entry
    deleteTableObject(\@contents,$panelfile);

    # append new changes
    addTableObject($new,$panelfile);
    $table = `${BASENAME} $panelfile`;
    chomp($table);
    addLogMessage($table,$msg,$logfile,$sid,$userfile,$sessifile);

    # update availability

    if($paneledit =~ m/ppbox/ || $paneledit =~ m/vpbox/ ||
	$paneledit =~ m/stime/ || $paneledit =~ m/ftime/ ||$paneledit =~ m/day/)
    {
	$daytemp=$start=$finish=$userid=$new;
	$userid =~ s/.*"USERID//;
	$userid =~ s/DIRESU".*//;
	$start =~ s/.*"STIME//;
	$start =~ s/EMITS".*//;
	$finish =~ s/.*"FTIME//;
	$finish =~ s/EMITF",.*//;
	$daytemp =~ s/.*"DAY//;
	$daytemp =~ s/YAD".*//;
	chomp($userid);
	chomp($start);
	chomp($finish);
	chomp($daytemp);
	$count=0;

    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
                "1130","1200","1230","1300","1330","1400","1430","1500",
                "1530","1600","1630","1700","1730","1800","1830","1900",
                "1930","2000","2030","2100","2130","2200");

	foreach $entry (@dbtimetable)
	{
	    if ($entry =~ m/$start/)
	    {
		$startpivot = $count;
	    }
	
	    if ($entry =~ m/$finish/)
	    {
		$finishpivot = $count;
	    }
	    $count++;
 	}
	$count = $startpivot;
	$point=0;

	while ($count <= $finishpivot)
	{
	    $timearr[$point] = $dbtimetable[$count];
	    $point++;
	    $count++;
	}

	if ($paneledit =~ m/stime/ || $paneledit =~ m/ftime/ || 
	$paneledit =~ m/day/)
	{
	    # change availability when we change day or time

	    $participant_id=$venue_id=$new;
	    $venue_id =~ s/.*,"VENID//;
	    $venue_id =~ s/DINEV",.*//;
    	    $participant_id =~ s/SETON","/SETON""/;
    	    $participant_id =~ s/.*SETON"//;
    	    $participant_id =~ s/"PARTID//g;
    	    $participant_id =~ s/(DITRAP",)|(DITRAP")/\ /g;
    	    @global_part_avail = split("\ ",$participant_id);
	    $totalcount=0;
	    $timearraysize=@timearr;

            foreach $part_id (@global_part_avail)
            {
		$particount=0;

		while ($particount < $timearraysize)
		{
		    # DISABLED
	    	    $temppartiarray[$particount]="\"USERID${part_id}DIRESU\",\"DAY${daytemp}YAD\",\"TIME${timearr[$particount]}EMIT\",\"DISABLED\",\"PANID${panelid}DINAP\"\n";
		    $particount++;
		}
		push(@tpartiarr,@temppartiarray);
	    }
	    @partiarr=@tpartiarr;
	    $venuecount=0;

	    while ($venuecount < $timearraysize)
	    {
		$venuearr[$venuecount]="\"USERID${venue_id}DIRESU\",\"DAY${daytemp}YAD\",\"TIME${timearr[$venuecount]}EMIT\",\"DISABLED\",\"PANID${panelid}DINAP\"\n";
		$venuecount++;
	    }

	}
	    else
	    {
		@partiarr=@venuearr=@timearr;
                foreach $entry (@partiarr)
                {
                    chomp($entry);
                        # DISABLED
                    $entry="\"USERID${ppbox}DIRESU\",\"DAY${daytemp}YAD\",\"TIME${entry}EMIT\",\"DISABLED\",\"PANID${panelid}DINAP\"\n";
                }

                foreach $entry (@venuearr)
                {
                    chomp($entry);
                        # DISABLED
                    $entry="\"USERID${vpbox}DIRESU\",\"DAY${daytemp}YAD\",\"TIME${entry}EMIT\",\"DISABLED\",\"PANID${panelid}DINAP\"\n";
                }
	    }
	
	$pavailfile = "${temppavailfile}${daytemp}.db";
	$vavailfile = "${tempvavailfile}${daytemp}.db";
        addTableObjects(\@partiarr,$pavailfile);
        addTableObjects(\@venuearr,$vavailfile);
    }

    # Ok, we have updated our panel information
    # We have updated availability based on panel change
    # Time to find out the problems we caused

    conflictDetect($confile,$condisfile,$new);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys?delete=panel&panbox=$panelid&sid=$sid&panelform=Edit&y=$year\">";
}

sub changeAvailability()
{
    # When there is a time/day change, we need to update the availability of the
    # participants and venues based on the given availfile.

    ($availfile,$panelid,$user_id)=@_;

    chomp($user_id);
    chomp($panelid);
    open(IN,"<",$availfile);
    @objavail=<IN>;
    close(IN);

    if($user_id)
    {
	@objavail = grep { !/USERID${user_id}.*PANID${panelid}DINAP/ } @objavail;
    }
	else
	{
	    @objavail = grep { !/PANID${panelid}DINAP/ } @objavail;
	}

    deleteTableObject(\@objavail,$availfile)
}

1;
