#!/usr/local/bin/perl

# COWAbunga -
# File: add.pl 
# Conference on World Affairs Scheduler
#   This file contains the add library functions to populate
#   the text database.

sub addConferencePage()
{
    # UI Module, creates and displays Edit Conference link

    ($sid,$parti,$DBDIRECTORY,$conference,$year,$userfile,$sessifile) = @_;
    @partitable=@$parti;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&sid=
	$sid\">";
        exit 1;
    }

    print( STDOUT <<HTML );
<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this conference?  THIS IS A BAD IDEA!!!"))
    {
	document.forms['editConference'].confd.value="Delete";
        document.forms["editConference"].submit();
    }
}
</script>
<div id="content">
<h2>Conference Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Conference Years<br>
<form name="editConference" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="conference">
HTML
createConferencePopupBox($DBDIRECTORY,$conference,"editConference");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name=confd value="">
<input type="submit" name="editconf" value="Edit">
<input type="button" name="editconf" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form action=cwasys.pl method=GET>
<input type=hidden name=add value=conference>
<p>Year: <input class=textfield class=textfield class=textfield type=text name=newyearname></p>
<input type=hidden name=sid value=$sid>
<input type=submit value="Add New Conference">
</form>
</div>
</div>

HTML
}

sub addConference()
{
    # Creates a conference by touching the participants, moderators, venues, 
    # producers, and panels table along with conflicts, availability and tags.
    # Then we echo in an initializing value into the count files so that there
    # is a concept of a primary key.  When all wrapped up, its good to chmod the
    # the directories to whatever is specified in CONFIGURE so that things are
    # NOT viewable to the public, but is available to the system.

    ($sid,$DBDIRECTORY,$conference,$idfile,$logfile,$newyearname,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&sid=
	$sid\">";
        exit 1;
    }

    $newyear=fileIDHandler($idfile);
    $newyearname=removeRegExp($newyearname);
    $entry="\
	\"YID${newyear}DIY\",\
	\"YNAME${newyearname}EMANY\"\
        ";

    $entry =~ s/\n|\t//g;

    if ($newyearname)
    { 
	addTableObject($entry,$conference);
	# Here is where we do the actual touching to create our table structure
	# by year.

    	$createTables=`${TOUCH} ${DBDIRECTORY}participants${newyear}.db \\
				${DBDIRECTORY}producers${newyear}.db \\
				${DBDIRECTORY}moderators${newyear}.db \\
				${DBDIRECTORY}venues${newyear}.db \\
				${DBDIRECTORY}panels${newyear}.db \\
				${DBDIRECTORY}conflicts${newyear}.db \\
				${DBDIRECTORY}conflictsquiet${newyear}.db \\
				${DBDIRECTORY}tags${newyear}.db`;
	$createVTable=`${TOUCH} ${DBDIRECTORY}venavail${newyear}Monday.db \\
				${DBDIRECTORY}venavail${newyear}Tuesday.db \\
				${DBDIRECTORY}venavail${newyear}Wednesday.db \\
			 	${DBDIRECTORY}venavail${newyear}Thursday.db \\
				${DBDIRECTORY}venavail${newyear}Friday.db`;
    	$createPTable=`${TOUCH} ${DBDIRECTORY}partavail${newyear}Monday.db \\
				${DBDIRECTORY}partavail${newyear}Tuesday.db \\
				${DBDIRECTORY}partavail${newyear}Wednesday.db \\
				${DBDIRECTORY}partavail${newyear}Thursday.db \\
				${DBDIRECTORY}partavail${newyear}Friday.db`;
    	$CNT=`${ECHO} 100000000 >> ${DBDIRECTORY}participants${newyear}.count \\
	&& ${ECHO} 100000000 >> ${DBDIRECTORY}producers${newyear}.count \\
	&& ${ECHO} 100000000 >> ${DBDIRECTORY}moderators${newyear}.count \\
	&& ${ECHO} 100000000 >> ${DBDIRECTORY}venues${newyear}.count \\
	&& ${ECHO} 100000000 >> ${DBDIRECTORY}panels${newyear}.count \\
	&& ${ECHO} 100000000 >> ${DBDIRECTORY}tags${newyear}.count`;

	$permissionSet = `${CHMOD} ${DBDIRECTORY}`;
	addLogMessage("n/a","Added new conference $newyear",$logfile,$sid,
	$userfile,$sessifile);

	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=ceditor&y=$newyear\">";
    }

    else
    {
    	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&pid=ceditor&y=$year\">";
    }
}

sub addModeratorPage()
{
    # UI Module, creates and displays Edit Moderator link

    ($sid,$moder,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $year=param('y');
    @modertable=@$moder;
    print( STDOUT <<HTML );
<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this moderator?"))
    {
	document.forms['editModerator'].moderd.value="Delete";
	document.forms["editModerator"].submit();
    }
}
function SameName()
{
	var x = 0;
	var selBox = document.getElementById('mpbox');
	for (var index = 0; index < selBox.options.length; index++)
	{
		if (selBox.options[index].text == (document.addModer.lname.value+", "+document.addModer.fname.value))
			x = 1;
	}

	if (x == 1)
	{
		if(confirm ("A Moderator with that name exists. Add same name?"))
		{
			document.forms["addModer"].submit();
		}
	}
	else
	{
		document.forms["addModer"].submit();
	}
}
</script>
<div id="content">
<h2>$yearname Moderators Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Moderator List:<br>
<form name="editModerator" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="moderator">
HTML
createModeratorPopupBox(\@modertable,35,"editModerator");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="moderd" value="">
<input type="submit" name="moderform" value="Edit">
<input type="button" name="moderform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form name="addModer" action=cwasys.pl method=GET>
<input type=hidden name=add value=moderator>
<p>First Name: <input class=textfield class=textfield type=text name=fname></p>
<p>Last Name: <input class=textfield class=textfield type=text name=lname></p>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes></textarea></p>
<input type=hidden name=y value=$year>
<input type=hidden name=sid value=$sid>
<input type="button" value="Add" onClick="SameName()">
</form>
</div>
</div>
HTML
}

sub addModerators()
{
    # Formulates moderator entry syntax and appends to database with successful 
    # lock.

    ($sid,$fname,$lname,$notes,$file,$idfile,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $id=fileIDHandler($idfile);
    $notes =~ s/\n/\\n/g;
    $fname=removeRegExp($fname);
    $lname=removeRegExp($lname);
    $notes=removeRegExp($notes);
    $entry="\
	\"LNAME${lname}EMANL\",\
	\"FNAME${fname}EMANF\",\
	\"MODID${id}DIDOM\",\
	\"NOTES${notes}SETON\"\
	";

    $entry =~ s/\n|\t//g;
    # Check that at least one string is not empty, or else someone submitted a 
    # blank entry

    if($fname || $lname)
    {
        addTableObject($entry,$file);
	$table = `${BASENAME} $file`;
	chomp($table);
	addLogMessage($table,"Added $fname $lname",$logfile,$sid,$userfile,
	$sessifile);
    }

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=meditor&y=$year\">";
}

sub addParticipantPage()
{
    # UI Module, creates and displays Edit Participants link

    ($sid,$parti,$dbdir,$userfile,$sessifile) = @_;

    @impyear = `${LS} -1 $dbdir`;
    @impyear = grep { !/backup/ } @impyear;
    @impyear = reverse sort(@impyear);

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2
	&sid=$sid\">";
        exit 1;
    }

    @partitable=@$parti;
    $year=param('y');
    print( STDOUT <<HTML );

<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this participant?"))
    {
	document.forms['editParticipant'].partd.value="Delete";
        document.forms["editParticipant"].submit();
    }
}
function SameName()
{
	var x = 0;
	var selBox = document.getElementById('ppbox');
	for (var index = 0; index < selBox.options.length; index++)
	{
		if (selBox.options[index].text == (document.addParti.lname.value+", "+document.addParti.fname.value))
			x = 1;
	}

	if (x == 1)
	{
		if(confirm ("A Participant with that name exists. Add same name?"))
		{
			document.forms["addParti"].submit();
		}
	}
	else
	{
		document.forms["addParti"].submit();
	}
}
</script>
<div id="content">
<h2>$yearname Participants Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Participant List:<br>
<form name="editParticipant" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="participant">
HTML
createParticipantPopupBox(\@partitable,35,"editParticipant");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="partd" value="">
<input type="submit" name="partform" value="Edit">
<input type="button" name="partform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form name="addParti" action=cwasys.pl method=GET>
<input type=hidden name=add value=participant>
<p>First Name: <input class=textfield class=textfield type=text name=fname></p>
<p>Last Name: <input class=textfield class=textfield type=text name=lname></p>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes></textarea></p>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value="$year">
<input type="button" value="Add" onClick="SameName()">
</form>
<br><br>
<form action=cwasys.pl method=GET>
<input type=hidden name=sid value=$sid>
<input type=hidden name=import value=participant>
<input type=hidden name=y value="$year">
<select name=dbyear>
HTML
    # @impyear controls years that we can import directly from 
    # /htdocs/cwa/cgi-bin/data.  This is a separate entity from this project and
    # the function is implemented in import.pl

    foreach $iyear (@impyear)
    {
	chomp($iyear);
        print "<option value=\"$iyear\">$iyear</option><br>";
    }
print (STDOUT <<HTML);
</select>
<input type=submit value="Import from CWA">
</form>
</div>
</div>
HTML
}

sub addParticipants()
{
    # Formulates participant entry syntax and appends to database with 
    # successful lock.

    ($sid,$fname,$lname,$notes,$partifile,$idfile,$logfile,$year,$userfile,
	$sessifile,$import) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2
	&sid=$sid\">";
        exit 1;
    }

    $id=fileIDHandler($idfile);
    $notes =~ s/\n/\\n/g;
    $fname=removeRegExp($fname);
    $lname=removeRegExp($lname);
    $notes=removeRegExp($notes);
    $entry="
	\"LNAME${lname}EMANL\",
	\"FNAME${fname}EMANF\",
	\"PARTID$id\DITRAP\",
	\"NOTES${notes}SETON\"
	";
    $entry =~ s/\n|\t//g;

    # Check that at least one string is not empty, or else someone submitted a blank entry

    if($fname || $lname)
    {
    	addTableObject($entry,$partifile);
        $table = `${BASENAME} $partifile`;
        chomp($table);
	addLogMessage($table,"Added $fname $lname",$logfile,$sid,$userfile,
	$sessifile);
	$file=$partifile;
    }

    if($import) { return; } 

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=peditor&y=$year\">";
}

sub addProducerPage()
{
    # UI Module, creates and displays Edit Participants link.

    ($sid,$produ,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $year=param('y');
    print( STDOUT <<HTML );

<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this producer?"))
    {
	document.forms['editProducer'].prodd.value="Delete";
        document.forms["editProducer"].submit();
    }
}
function SameName()
{
	var x = 0;
	var selBox = document.getElementById('pubox');
	for (var index = 0; index < selBox.options.length; index++)
	{
		if (selBox.options[index].text == (document.addProdu.lname.value+", "+document.addProdu.fname.value))
			x = 1;
	}

	if (x == 1)
	{
		if(confirm ("A Producer with that name exists. Add same name?"))
		{
			document.forms["addProdu"].submit();
		}
	}
	else
	{
		document.forms["addProdu"].submit();
	}
}
</script>
<div id="content">
<h2>$yearname Producers Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Producer List:<br>
<form name="editProducer" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="producer">
HTML
createProducerPopupBox(\@produtable,35,"editProducer");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="prodd" value="">
<input type="submit" name="prodform" value="Edit">
<input type="button" name="prodform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form name="addProdu" action=cwasys.pl method=GET>
<input type=hidden name=add value=producer>
<p>First Name: <input class=textfield class=textfield type=text name=fname></p>
<p>Last Name: <input class=textfield class=textfield type=text name=lname></p>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes></textarea></p>
<input type=hidden name=y value=$year>
<input type=hidden name=sid value=$sid>
<input type="button" value="Add" onClick="SameName()">
</form>
</div>
</div>
HTML
}

sub addProducers()
{
    # Formulates producer entry syntax and appends to database with 
    # successful lock.

    ($sid,$fname,$lname,$notes,$file,$idfile,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $id=fileIDHandler($idfile);
    $notes =~ s/\n/\\n/g;
    $fname=removeRegExp($fname);
    $lname=removeRegExp($lname);
    $notes=removeRegExp($notes);
    $entry="
	\"LNAME${lname}EMANL\",
	\"FNAME${fname}EMANF\",
	\"PRODID$id\DIDORP\",
	\"NOTES${notes}SETON\"
	";

    $entry =~ s/\n|\t//g;

    # Check that at least one string is not empty, or else someone submitted a 
    # blank entry.

    if($fname || $lname)
    {
        addTableObject($entry,$file);
        $table = `${BASENAME} $file`;
        chomp($table);
	addLogMessage($table,"Added $fname $lname",$logfile,$sid,$userfile,
	$sessifile);
    }

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=proeditor&y=$year\">";
}

sub addVenuePage()
{
    # UI Module, creates and displays Edit Venues link

    ($sid,$venue,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $year=param('y');
    @venuetable=@$venue;
    print( STDOUT <<HTML );

<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this venue?"))
    {
	document.forms['editVenue'].vend.value="Delete";
        document.forms["editVenue"].submit();
    }
}
function SameName()
{
	var x = 0;
	var selBox = document.getElementById('vpbox');
	for (var index = 0; index < selBox.options.length; index++)
	{
		if (selBox.options[index].text == document.addVenue.loc.value)
			x = 1;
	}

	if (x == 1)
	{
		if(confirm ("A Venue with that name exists. Add same name?"))
		{
			document.forms["addVenue"].submit();
		}
	}
	else
	{
		document.forms["addVenue"].submit();
	}
}
</script>

<div id="content">
<h2>$yearname Venues Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Venue List:<br>
<form name="editVenue" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="venue">
HTML
createVenuePopupBox(\@venuetable,35,"editVenue");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="vend" value="">
<input type="submit" name="venform" value="Edit">
<input type="button" name="venform" value="Delete" onClick="Confirm()">
</form>
</div>
<div class="editItems">
<form name="addVenue" action=cwasys.pl method=GET>
<input type=hidden name=add value=venue>
<p>Venue: <input class=textfield class=textfield type=text name=loc></p>
<p>Capacity: <input class=textfield class=textfield type=text name=space></p>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes></textarea></p>
<input type=hidden name=y value=$year>
<input type=hidden name=sid value=$sid>
<input type="button" value="Add" onClick="SameName()">
</form>
</div>
</div>
HTML
}

sub addVenues()
{
    # Formulates venue entry syntax and appends to database with successful lock

    ($sid,$loc,$space,$notes,$file,$idfile,$logfile,$year,$userfile,$sessifile) 	= @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $id=fileIDHandler($idfile);
    $notes =~ s/\n/\\n/g;
    $loc=removeRegExp($loc);
    $space=removeRegExp($space);
    $notes=removeRegExp($notes);
    $entry="
	\"VENLOC${loc}COLNEV\",
	\"SPACE${space}ECAPS\",
	\"VENID${id}DINEV\",
	\"NOTES${notes}SETON\"
	";

    $entry =~ s/\n|\t//g;

    # Check that the string is not empty, or else someone submitted a blank
    # entry.

    if($loc)
    {
        addTableObject($entry,$file);
        $table = `${BASENAME} $file`;
        chomp($table);
	addLogMessage($table,"Added $loc",$logfile,$sid,$userfile,$sessifile);
    }

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=veditor&y=$year\">";
}

sub addPanelPage()
{
    # UI Module, creates and displays Edit Panels link

    ($sid,$panel,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    @paneltable=@$panel;
    print( STDOUT <<HTML );

<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this panel?"))
    {
	document.forms['editPanel'].paneld.value="Delete";
        document.forms['editPanel'].submit();
    }
}
function SameName()
{
	var x = 0;
	var selBox = document.getElementById('panbox');
	for (var index = 0; index < selBox.options.length; index++)
	{
		if (selBox.options[index].text == document.addPanel.panel.value)
			x = 1;
	}

	if (x == 1)
	{
		if(confirm ("A Panel with that name exists. Add same name?"))
		{
			document.forms["addPanel"].submit();
		}
	}
	else
	{
		document.forms["addPanel"].submit();
	}
}
</script>
<div id="content">
<h2>$yearname Panels Editor</h2>
<hr size="1" noshade>
<div class="listItems" style="width:400px;">
Panel List:<br>
<form name="editPanel" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="panel">
HTML
createPanelPopupBox(\@paneltable,35,"editPanel");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="paneld" value="">
<input type="submit" name="panelform" value="Edit">
<input type="button" name="paneldel" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form name="addPanel" action=cwasys.pl method=GET>
<input type=hidden name=add value=panel>
<br><br><br>
<p>Add New Panel: <input class=textfield class=textfield type=text size=40 name=panel></p>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=button value="Add" onClick="SameName()">
</form>
</div>
</div>
HTML
}

sub addPanels()
{
    ($sid,$panel,$file,$idfile,$confile,$condisfile,$pavailfile,$vavailfile,
	$logfile,$year,$userfile,$sessifile,$day,$f,$parti) = @_;

    @partitable=@$parti;
    @indarray=split(/_/,$f);
    shift(@indarray);
    $index+=0;
    $first=0;
    $partic = "";
    @partitable = sort {lc $a cmp lc $b} @partitable;

    foreach $entry (@partitable)
    {
	if(grep(/\b$index\b/,@indarray))
	{
	    $lastentry =~ s/\n//;
	    $lastentry =~ s/"Y[0-9]*Y"//;
            $tableid=$fname=$lname=$lastentry;
	    $lname =~ s/"LNAME//;
	    $lname =~ s/EMANL".*//;
	    $fname =~ s/"LNAME${lname}EMANL","FNAME//;
	    $fname =~ s/EMANF".*//;
	    $tableid =~ s/"LNAME${lname}EMANL","FNAME${fname}EMANF","//;
	    $tableid =~ s/PARTID//;
	    $tableid =~ s/DITRAP.*//g;
	    $partic = "${partic},\"PARTID${tableid}DITRAP\"";
	}
	$index++;
	$lastentry = $entry;
    }

    if(grep(/\b$index\b/,@indarray))
    {
	$lastentry =~ s/\n//;
	$lastentry =~ s/"Y[0-9]*Y"//;
       	$tableid=$fname=$lname=$lastentry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
	$tableid =~ s/"LNAME${lname}EMANL","FNAME${fname}EMANF","//;
	$tableid =~ s/PARTID//;
	$tableid =~ s/DITRAP.*//g;
	$partic = "${partic},\"PARTID${tableid}DITRAP\"";
    }

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    # Check that at least one string is not empty, or else someone submitted a 
    # blank entry.

    if (!$panel && !@indarray)
    {
	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=paneditor&y=$year\">";
	exit 1;
    }

    $id=fileIDHandler($idfile);

    # A non-empty $f implies that users are being added using the Availability 
    # form at panel creation time.  If not, we are using the Add Panel form

    $logpanel = $panel;
    chomp($logpanel);

    if ($f)
    { # Selecting participants from Availability to form a panel
        $entry="
	\"PANELNew PanelLENAP\",
	\"PANID${id}DINAP\",
	\"MODIDDIDOM\",
	\"VENIDDINEV\",
	\"PRODIDDIDORP\",
	\"DAY${day}YAD\",
	\"STIMENoneEMITS\",
	\"FTIMENoneEMITF\",
	\"SESIDDISES\",
	\"ALTPIDDIPTLA\",
	\"NOTESSETON\"
	${partic}";
    }

    else
    { # Using the Add Panel form
    	$panel = removeRegExp($panel);
    	$entry="
	\"PANEL${panel}LENAP\",
	\"PANID${id}DINAP\",
	\"MODIDDIDOM\",
	\"VENIDDINEV\",
	\"PRODIDDIDORP\",
	\"DAYMondayYAD\",
	\"STIMENoneEMITS\",
	\"FTIMENoneEMITF\",
	\"SESIDDISES\",
	\"ALTPIDDIPTLA\",
	\"NOTESSETON\"";
    }

    $entry =~ s/\n|\t//g;
    addTableObject($entry,$file);
    $panelentry = $entry;
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Added New Panel \"$logpanel\"",$logfile,$sid,
	$userfile,$sessifile);

    # if we added participants from the avail form, then update availability

    $eachparticipant=$partic;
    $eachparticipant =~ s/^,//;
    $eachparticipant =~ s/^"PARTID//;
    @allparti = split('DITRAP","PARTID',$eachparticipant);
    foreach $parid (@allparti) { $parid=~s/DITRAP"//; }
    
    if($f)
    {
        @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
			"1130","1200","1230","1300","1330","1400","1430","1500",
			"1530","1600","1700","1730","1800","1830","1900","1930",
			"2000","2030","2100","2130","2200"
			);

        foreach $parid (@allparti) 
	{
	    @partiarr=@dbtimetable;
            foreach $entry (@partiarr)
            {
                chomp($entry);
                # DISABLED
                $entry="
		\"USERID${parid}DIRESU\",
		\"DAYMondayYAD\",
		\"TIME${entry}EMIT\",
		\"DISABLED\",
		\"PANID${id}DINAP\"
		\n";
		$entry =~ s/\n|\t//g;
		$entry .= "\n";
            }

	    push(@finalpartiarray,@partiarr);
	}
	
	$pavailfile = "${pavailfile}Monday.db";
	addTableObjects(\@finalpartiarray,$pavailfile);
    }

    conflictDetect($confile,$condisfile,$panelentry);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?delete=panel&
	panbox=$id&sid=$sid&panelform=Edit&y=$year\">";
}

sub adminUserPage()
{
    # UI Module, creates and displays User Control Panel link

    ($sid,$user,$msg,$userfile,$sessifile)=@_;
    @usertable=@$user;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/(coord)|(planner)/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    print( STDOUT <<HTML );
<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this user?"))
    {
	document.forms['editAdminUsers'].userd.value="Delete";
        document.forms["editAdminUsers"].submit();
    }
}
</script>
<div id="content">
<h2>User Control Panel</h2>
<hr size="1" noshade>
<div class="listItems">
User List:<br>
<form name="editAdminUsers" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="user">
HTML
createUserPopupBox(\@usertable,35,"editAdminUsers");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=userd value="">
<input type="submit" name="userform" value="Edit">
<input type="button" name="userform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
HTML
    if ($msg)
    {
	print (STDOUT <<HTML);
	<table cellpadding=0 class=bettyTable><tr>
	<th> The following errors occurred with your input </th></tr><tr>
	<td><font color="red">
	    $msg
	</td></tr></table>
HTML
    }
    
    print (STDOUT <<HTML);
<form action=cwasys.pl method=GET>
<input type=hidden name=add value=user>
<input type=hidden name=sid value=$sid>
<p>Username: <input class=textfield class=textfield type=text name=username></p>
<p>Password: <input class=textfield type=password name=passwd></p>
<p>Password (confirm): <input class=textfield type=password name=passwdconfirm></p>
<p>E-mail: <input class=textfield class=textfield type=text name=email></textarea></p>
<p>Access Level: <select name=level>
        <option value="planner">Planner</option>
        <option value="coord">Coordinator</option>
        <option value="admin">Administrator</option>
</select></p>
<input type=submit value="Add User">
</form>
<br><br>
<a href="${URL}project-index.html">Project Documentation</a>
</div>
</div>
HTML
}

sub addUsers()
{
    # Formulates user entry syntax and appends to database with successful lock.
    # No lock sends the user to the same page with no updates 
    # (HIGHLY UNLIKELY this happens).

    ($sid,$username,$passwd,$confirm,$email,$ulevel,$idfile,$logfile,$year,
	$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $id=fileIDHandler($idfile);
    $username=removeRegExp($username);
    $email=removeRegExp($email);
    $passwd=md5_hex($passwd);
    $confirm=md5_hex($confirm);

    # Error check the four form elements inside useradd

    $emailgrep = grep { /,"EMAIL${email}LIAME"/ } @usertable;
    $usernamegrep = grep { /"UNAME${username}EMANU"/ } @usertable;

    if ($passwd !~ /$confirm/)
    {
	$passwdproblem = 1;
    }

    # Send message back to the user if error occurred

    if (!$username || $emailgrep || $usernamegrep || $passwdproblem)
    {
	if (!$username)
	{
	    $errormessage .= "No username submitted <br>";
	}

	if ($usernamegrep)
	{
	    $errormessage .= "Username is already registered <br>";
  	}

	if ($passwdproblem)
	{
	    $errormessage .= "Password's don't match <br>";
	}

        if ($emailgrep)
        {
            $errormessage .= "E-mail is already registered <br>";
        }
	
	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=ucpanel&msg=$errormessage&y=$year\">";
	exit;
    }

    $entry="
	\"UNAME${username}EMANU\",
	\"PASSWD${passwd}DWSSAP\",
	\"USERID$id\DIRESU\",
	\"LEVEL${ulevel}LEVEL\",
	\"EMAIL${email}LIAME\"
	";

    $entry =~ s/\n|\t//g;

    addTableObject($entry,$userfile);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Added $username",$logfile,$sid,$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=ucpanel&y=$year\">";
}

sub addTagsPage()
{
    ($sid,$tag,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $year=param('y');
    @tagtable=@$tag;
    print( STDOUT <<HTML );
<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this tag?"))
    {
	document.forms['editTags'].tagd.value="Delete";
        document.forms["editTags"].submit();
    }
}
</script>
<div id="content">
<h2>$yearname Tags Editor</h2>
<hr size="1" noshade>
<div class="listItems">
Tag List:<br>
<form name="editTags" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="tag">
HTML
createTagPopupBox(\@tagtable,35,"editTags");
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="tagd" value="">
<input type="submit" name="tagform" value="Edit">
<input type="button" name="tagform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form action=cwasys.pl method=GET>
<input type=hidden name=add value=tag>
<p>Tag Name: <input class=textfield class=textfield type=text name=tagname></p>
<table cellspacing=0 class=bettyTable width=300>
<tr><td>Affects</td><td>Type</td><td rowspan="5">Must Have <input type=radio name=must value=MUST checked><br>
Can't Have <input type=radio name=must value=CANT checked></td></tr>
<tr><td><input type=checkbox name=tagpar value=PAR></td><td>Participants</td></tr>
<tr><td><input type=checkbox name=tagven value=VEN></td><td>Venues</td></tr>
<tr><td><input type=checkbox name=tagmod value=MOD></td><td>Moderators</td></tr>
<tr><td><input type=checkbox name=tagpro value=PRO></td><td>Producers</td></tr>
</table>
<input type=hidden name=y value=$year>
<input type=hidden name=sid value=$sid>
<input type=submit value="Add">
</form>
</div>
</div>
HTML
}

sub addTags()
{
    ($sid,$tagname,$file,$idfile,$logfile,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $buffer = $ENV{'QUERY_STRING'};
    if ($buffer =~ m/tagpar/) { $affects .= "PAR"; }
    if ($buffer =~ m/tagven/) { $affects .= "VEN"; }
    if ($buffer =~ m/tagpro/) { $affects .= "PRO"; }
    if ($buffer =~ m/tagmod/) { $affects .= "MOD"; }

    if ($buffer =~ m/CANT/) { $needs = "CANT"; }
    else { $needs = "MUST"; }

    $id=fileIDHandler($idfile);
    $tagname=removeRegExp($tagname);
    $entry="
	\"TAGNAME${tagname}EMANGAT\",
	\"TAGID${id}DIGAT\",
	\"AFFECTS${affects}STCEFFA\"
	\"NEEDS${needs}SDEEN\"
	";
    $entry =~ s/\n|\t//g;

    # Check that the string is not empty, or else someone submitted a blank 
    # entry

    if($tagname)
    {
        addTableObject($entry,$file);
        $table = `${BASENAME} $file`;
        chomp($table);
   	addLogMessage($table,"Added $tagname",$logfile,$sid,$userfile,
	$sessifile);
    }

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=teditor&y=$year\">";
}

1;
