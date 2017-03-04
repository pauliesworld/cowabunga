#!/usr/local/bin/perl

# COWAbunga -
# File: edit.pl
# Conference on World Affairs Scheduler
#   This file contains the edit library functions to change
#   existing items in the text database.
#   Status: STABLE

sub editUserAccountPage()
{
    # UI Module that creates and displays the Edit Account page for the user
    ($sid,$msg,$sessiref,$userref)=@_;

    @sessitable=@$sessiref;
    @usertable=@$userref;

    foreach $entry (@sessitable)
    {
	# have to look through the sessions for the current session
	# in order to isolate their userid

        if($entry =~ m/SID${sid}DIS/)
        {
            $uid=$entry;
            $uid =~ s/.*DIS","USERID//;
            $uid =~ s/DIRESU.*//;
            chomp($uid);
        }
    }

    foreach $entry (@usertable)
    {
        if($entry =~ m/USERID$uid/)
        {
	    # once we found their id, parse only their entry and return

            $username=$password=$level=$email=$entry;
            $username =~ s/"UNAME//;
            $username =~ s/EMANU",.*//;
            $level =~ s/.*RESU","LEVEL//;
            $level =~ s/LEVEL",.*//;
            $email =~ s/.*,"EMAIL//;
            $email =~ s/LIAME".*//;
            chomp($username);
            chomp($email);
            chomp($level);
	    $username=addRegExp($username);
	    $level=addRegExp($level);
	    $email=addRegExp($email);
        }
    }

    print (STDOUT <<HTML);
<div id="content">
<h2>Edit Account - $username</h2>
<hr size="1" noshade>
<br>
<div id="listItems">
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
<table cellpadding=0 class=bettyTable width="400"><tr><td>
<form action=cwasys.pl method=GET>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name=pid value=editaccount>
<input type=hidden name=edit value=account>
<input type=hidden name=userid value=$uid>
<input type=hidden name=username value="$username">
<input type=hidden name=level value=$level>
Username: $username<br>
Access Level: $level<br>
E-mail: <input class=textfield type=text name=email value="$email"><br>
Password: <input class=textfield type=password name=passwd value="TEMPPASSWD"><br>
Password (confirm): <input class=textfield type=password name=passwdconfirm value="TEMPPASSWD"><br>
<input type=submit value="Update">
</form>
</td></tr></table>
</div>
<div class="editItems">
</div>
</div>

HTML
}

sub editUserAccount()
{
    # Deletes the $userid from the table, forms a new entry based on input, and 
    # appends to the end.  We MUST keep the same userid throughout all of this 
    # which is why this isn't as simple as calling deleteUser()...  The user 
    # name is also static through this process but is not utilized as the 
    # primary key.

    ($sid,$userid,$username,$passwd,$confirm,$level,$email,$file,$logfile,$year)
	=@_;

    $name="USERID${userid}DIRESU";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @oldpasswd = grep { /$name/ } @contents;
    $oldpasswd = join('',@oldpasswd);
    chomp($oldpasswd);
    @contents = grep { !/$name/ } @contents;
    chomp($username);
    $username=removeRegExp($username);
    $passwd=md5_hex($passwd);
    $confirm=md5_hex($confirm);
    $email=removeRegExp($email);

    $oldpasswd =~ s/.*,"PASSWD//;
    $oldpasswd =~ s/DWSSAP",.*//;
    chomp($oldpasswd);

    $specialhash = md5_hex("TEMPPASSWD");
    #$specialhash = "ef7784b1fa38946fdf69bcd71307431c";

    if ($passwd =~ m/$specialhash/ && $confirm =~ m/$specialhash/)
    {
	$passwd = $confirm = $oldpasswd;
    }

    @emailgrep = grep { /,"EMAIL${email}LIAME"/ } @usertable;
    $emailgrep = grep { !/,"USERID${userid}DIRESU"/ } @emailgrep;

    if ($passwd !~ /$confirm/)
    {
        $passwdproblem = 1;
    }

    if ($emailgrep || $passwdproblem)
    {
        if ($passwdproblem)
        {
            $errormessage .= "Password's don't match <br>";
        }

        if ($emailgrep)
        {
            $errormessage .= "E-mail is already registered <br>";
        }

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=editaccount&y=$year&msg=$errormessage\">";
        exit;
    }

    $entry="
	\"UNAME${username}EMANU\",
	\"PASSWD${passwd}DWSSAP\",
	\"USERID${userid}DIRESU\",
	\"LEVEL${level}LEVEL\",
	\"EMAIL${email}LIAME\"";
    $entry =~ s/\n|\t//g;
 
    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$username password/e-mail changed",$logfile,$sid,$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&pid=editaccount&y=$year\">";
}

sub editConferencePage()
{
    # UI Module that creates and displays the Edit Conference page for the user
    ($conference,$confid,$year,$userfile,$sessifile)=@_;

    open(IN,$conference);
    @theyear=<IN>;
    close IN;

    foreach $entry (@theyear)
    {
	if ($entry =~ m/"YID${confid}DIY"/)
	{
	    $thisyearname=$entry;
	    $thisyearname =~ s/.*"YNAME//;
	    $thisyearname =~ s/EMANY".*//;
	    chomp($thisyearname);
	    $thisyearname = addRegExp($thisyearname);
	}
    }

    print (STDOUT <<HTML);
<div id="content">
<h2>Edit Conference Name</h2>
<hr size="1" noshade>
<br>
<div id="listItems">
<table cellpadding=0 class=bettyTable width="400"><tr><td>
<form action=cwasys.pl method=GET>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name=edit value=conference>
<input type=hidden name=confid value=$confid>
Conference: <input class=textfield type=text name=confyear value="$thisyearname"><br>
<input type=submit value="Update Conference Name">
</form>
</td></tr></table>
</div>
<div class="editItems">
</div>
</div>

HTML
}

sub editConference()
{
    # Isolates a given year id and replaces it's year name with the new one
    # passed through.  Then we recommit.

    ($confid,$confyear,$conference,$logfile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
        sid=$sid\">";
        exit 1;
    }

    open(IN, "<", $conference);
    @contents = <IN>;
    close(IN);

    $name = "YID${confid}DIY";
    @contents = grep { !/$name/ } @contents;
    $confyear=removeRegExp($confyear);
    $entry="
	\"YID${confid}DIY\",
	\"YNAME${confyear}EMANY\"
	";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$conference);

    # write new entry, keep current id
    addTableObject($entry,$conference);
    $table = `${BASENAME} $conference`;
    chomp($table);
    addLogMessage($table,"$confid $confyear changed",$logfile,$sid,
        $userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=ceditor&y=$year\">";
}

sub editModeratorPage()
{
    # UI Module that displays a given moderator edit page based on $modid and parsed on table lookup

    ($sid,$modid,$moderfile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"MODID${modid}DIDOM",/ } @modertable;

    if (!$exists)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&pid=meditor&y=$year\">";
        exit 1;
    }

    $entry = join('',@sentry);
    chomp($entry);

    $tags=$notes=$fname=$lname=$entry;
    $lname =~ s/"LNAME//;
    $lname =~ s/EMANL".*//;
    $fname =~ s/"LNAME${lname}EMANL","FNAME//;
    $fname =~ s/EMANF".*//;
    $notes =~ s/.*,"NOTES//;
    $notes =~ s/SETON".*//;
    $notes =~ s/\\n/\n/g;
    $lname=addRegExp($lname);
    $fname=addRegExp($fname);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;

    $tags =~ s/.*SETON"//;
    $tags =~ s/"TAGID//g;
    $tags =~ s/(DIGAT",)|(DIGAT")/\ /g;
    $tags =~ s/,//g;

    @ttable = split("\ ",$tags);
    @tagtable;

    foreach $tag (@tagtable)
    {
	$affects=$tag;
	$affects =~ s/.*,"AFFECTS//;
	$affects =~ s/STCEFFA"//;
	foreach $tag2 (@ttable)
	{
	    chomp($tag2);
	    chomp($tag);
	
	    if ($tag =~ m/${tag2}/)
	    {
		$local_table[$count] = $tag;
	        $count++;
		$found=1;
	    }
	}

	if($found == 0 && $affects =~ m/MOD/)
	{
	    push(@avail_tagtable,$tag);
	}
	$found = 0;
    }
	
    print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Moderator: $fname $lname</h2>
<hr size="1" noshade>
<br><br>
<div class="listItems">
<form action=cwasys.pl method=GET>
<input type=hidden name=edit value=moderator>
First Name: <input class=textfield type=text name=fname value="$fname"></p><br>
Last Name: <input class=textfield type=text name=lname value="$lname"></p><br>
Notes: <textarea class=textfield rows=10 cols=40 name=notes>$notes</textarea>
<input type=hidden name=modid value=$modid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
<div class="editItems" style="padding-left: 50px">
Tag Editor<br>
<form action=cwasys.pl method="GET">
<input type="hidden" name="addtag" value="moderator">
<input type="hidden" name="object" value="$modid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createTagPopupBox(\@avail_tagtable,1);
print(STDOUT <<HTML);
<input type="submit" value="Add Tag"><br><br>
</form>
<form action=cwasys.pl method=GET>
Currently Linked Tags<br>
HTML
createTagPopupBox(\@local_table,11);
print(STDOUT <<HTML);
<input type="hidden" name="deltag" value="moderator">
<input type="hidden" name="object" value="$modid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="Remove">
</form>
</div>
</div>
HTML
}

sub editModerators()
{
    # Accepts in the old modid then searches the database for that entry
    # Recommits new changes with a lock by keeping the same primary key modid by deleting
    # the old line and append the new

    ($sid,$modid,$fname,$lname,$notes,$file,$logfile,$year,$userfile,$sessifile)
	 = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="MODID${modid}DIDOM";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @tagsection = grep { /$name/ } @contents;
    $tags = join('',@tagsection);
    chomp($tags);
    $tags =~ s/.*SETON"//;
    @contents = grep { !/$name/ } @contents;
    $notes =~ s/\n/\\n/g;
    $fname=removeRegExp($fname);
    $lname=removeRegExp($lname);
    $notes=removeRegExp($notes);
    $entry="
	\"LNAME${lname}EMANL\",
	\"FNAME${fname}EMANF\",
	\"MODID$modid\DIDOM\",
	\"NOTES${notes}SETON\"
	${tags}";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$fname $lname name/notes changed",$logfile,$sid,
	$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?delete=moderator
	&mpbox=$modid&sid=$sid&y=$year&moderform=Edit\">";
}

sub editParticipantPage()
{
    # UI Module that displays a given participant edit page based on $partid and parsed on table lookup

    ($sid,$partid,$partifile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"PARTID${partid}DITRAP",/ } @partitable;

    if (!$exists)
    {
    	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=peditor&y=$year\">";
        exit 1;
    }

    @sentry = grep { /,"PARTID${partid}DITRAP",/ } @partitable;    
    $entry = join('',@sentry);
    chomp($entry);

    $tags=$notes=$fname=$lname=$entry;
    $lname =~ s/"LNAME//;
    $lname =~ s/EMANL".*//;
    $fname =~ s/"LNAME${lname}EMANL","FNAME//;
    $fname =~ s/EMANF".*//;
    $notes =~ s/.*,"NOTES//;
    $notes =~ s/SETON".*//;
    $notes =~ s/\\n/\n/g;
    $lname=addRegExp($lname);
    $fname=addRegExp($fname);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;

    $tags =~ s/.*SETON"//;
    $tags =~ s/"TAGID//g;
    $tags =~ s/(DIGAT",)|(DIGAT")/\ /g;
    $tags =~ s/,//g;

    @ttable = split("\ ",$tags);
    @tagtable;

    foreach $tag (@tagtable)
    {
	$affects=$tag;
	$affects =~ s/.*,"AFFECTS//;
	$affects =~ s/STCEFFA"//;
        foreach $tag2 (@ttable)
        {
            chomp($tag2);
            chomp($tag);

            if ($tag =~ m/${tag2}/)
            {
                $local_table[$count] = $tag;
                $count++;
                $found=1;
            }
        }

        if($found == 0 && $affects =~ m/PAR/)
        {
            push(@avail_tagtable,$tag);
        }
        $found = 0;
    }

    print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Participant: $fname $lname</h2>
<hr size="1" noshade>
<br><br>
<div class=\"editItems\">
<form action=cwasys.pl method=GET>
<input type=hidden name=edit value=participant>
First Name: <input class=textfield type=text name=fname value="$fname"></p><br>
Last Name: <input class=textfield type=text name=lname value="$lname"></p><br>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes>$notes</textarea></p>
<input type=hidden name=partid value=$partid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
<div class="editItems" style="padding-left: 50px">
Tag Editor<br>
<form action=cwasys.pl method="GET">
<input type="hidden" name="addtag" value="participant">
<input type="hidden" name="object" value="$partid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createTagPopupBox(\@avail_tagtable,1);
print(STDOUT <<HTML);
<input type="submit" value="Add Tag"><br><br>
</form>
<form action=cwasys.pl method=GET>
Currently Linked Tags<br>
HTML
createTagPopupBox(\@local_table,11);
print(STDOUT <<HTML);
<input type="hidden" name="deltag" value="participant">
<input type="hidden" name="object" value="$partid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="Remove">
</form>
</div>
</div>
HTML
}

sub editParticipants()
{
    # Accepts in the old partid then searches the database for that entry
    # Recommits new changes with a lock by keeping the same primary key partid
    # by deleting the old line and appending the new

    ($sid,$partid,$fname,$lname,$notes,$file,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="PARTID${partid}DITRAP";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @tagsection = grep { /$name/ } @contents;
    $tags = join('',@tagsection);
    chomp($tags);
    $tags =~ s/.*SETON"//;
    @contents = grep { !/$name/ } @contents;
    $notes =~ s/\n/\\n/g;
    $fname=removeRegExp($fname);
    $lname=removeRegExp($lname);
    $notes=removeRegExp($notes);
    $entry="
	\"LNAME${lname}EMANL\",
	\"FNAME${fname}EMANF\",
	\"PARTID$partid\DITRAP\",
	\"NOTES${notes}SETON\"
	${tags}";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);

    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$fname $lname name/notes changed",$logfile,$sid,
	$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=participant&ppbox=$partid&sid=$sid&y=$year&partform=Edit\">"
}

sub editProducerPage()
{
    # UI Module that displays a given producer edit page based on $prodid and parsed on table lookup

    ($sid,$prodid,$produfile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"PRODID${prodid}DIDORP",/ } @produtable;

    if (!$exists)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=proeditor&y=$year\">";
        exit 1;
    }

    $entry = join('',@sentry);
    chomp($entry);

    $tags=$notes=$fname=$lname=$entry;
    $lname =~ s/"LNAME//;
    $lname =~ s/EMANL".*//;
    $fname =~ s/"LNAME${lname}EMANL","FNAME//;
    $fname =~ s/EMANF".*//;
    $notes =~ s/.*,"NOTES//;
    $notes =~ s/SETON".*//;
    $notes =~ s/\\n/\n/g;
    $lname=addRegExp($lname);
    $fname=addRegExp($fname);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;

    $tags =~ s/.*SETON"//;
    $tags =~ s/"TAGID//g;
    $tags =~ s/(DIGAT",)|(DIGAT")/\ /g;
    $tags =~ s/,//g;

    @ttable = split("\ ",$tags);
    @tagtable;

    foreach $tag (@tagtable)
    {
 	$affects=$tag;
	$affects =~ s/.*,"AFFECTS//;
	$affects =~ s/STCEFFA"//;
        foreach $tag2 (@ttable)
        {
            chomp($tag2);
            chomp($tag);

            if ($tag =~ m/${tag2}/)
            {
                $local_table[$count] = $tag;
                $count++;
                $found=1;
            }
        }

        if($found == 0 && $affects =~ m/PRO/)
        {
            push(@avail_tagtable,$tag);
        }
        $found = 0;
    }

    print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Producer: $fname $lname</h2>
<hr size="1" noshade>
<br><br>
<div class=\"editItems\">
<form action=cwasys.pl method=GET>
<input type=hidden name=edit value=producer>
First Name: <input class=textfield type=text name=fname value="$fname"></p><br>
Last Name: <input class=textfield type=text name=lname value="$lname"></p><br>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes>$notes</textarea></p>
<input type=hidden name=prodid value=$prodid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
<div class="editItems" style="padding-left: 50px">
Tag Editor<br>
<form action=cwasys.pl method="GET">
<input type="hidden" name="addtag" value="producer">
<input type="hidden" name="object" value="$prodid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createTagPopupBox(\@avail_tagtable,1);
print(STDOUT <<HTML);
<input type="submit" value="Add Tag"><br><br>
</form>
<form action=cwasys.pl method=GET>
Currently Linked Tags<br>
HTML
createTagPopupBox(\@local_table,11);
print(STDOUT <<HTML);
<input type="hidden" name="deltag" value="producer">
<input type="hidden" name="object" value="$prodid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="Remove">
</form>
</div>
</div>
HTML
}

sub editProducers()
{
    # Accepts in the old prodid then searches the database for that entry
    # Recommits new changes with a lock by keeping the same primary key partid by deleting
    # the old line and append the new

    ($sid,$prodid,$fname,$lname,$notes,$file,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="PRODID${prodid}DIDORP";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @tagsection = grep { /$name/ } @contents;
    $tags = join('',@tagsection);
    chomp($tags);
    $tags =~ s/.*SETON"//;
    @contents = grep { !/$name/ } @contents;
    $lname=addRegExp($lname);
    $fname=addRegExp($fname);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;
    $entry="
	\"LNAME${lname}EMANL\",
	\"FNAME${fname}EMANF\",
	\"PRODID$prodid\DIDORP\",
	\"NOTES${notes}SETON\"
	${tags}";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);

    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$fname $lname name/notes changed",$logfile,$sid,
	$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?delete=producer
	&pubox=$prodid&sid=$sid&y=$year&prodform=Edit\">";
}

sub editVenuePage()
{
    # UI Module that displays a given venue edit page based on $venid and parsed on table lookup

    ($sid,$venid,$venuefile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"VENID${venid}DINEV",/ } @venuetable;

    if (!$exists)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=veditor&y=$year\">";
        exit 1;
    }

    $entry = join('',@sentry);
    chomp($entry);

    $tags=$notes=$space=$venue=$entry;
    $venue =~ s/"VENLOC//;
    $venue =~ s/COLNEV".*//;
    $space =~ s/"VENLOC${venue}COLNEV","SPACE//;
    $space =~ s/ECAPS".*//;
    $notes =~ s/.*,"NOTES//;
    $notes =~ s/SETON".*//;
    $notes =~ s/\\n/\n/g;
    $venue=addRegExp($venue);
    $space=addRegExp($space);
    $notes=addRegExp($notes);
    $notes =~ s/\\n/\n/g;

    $tags =~ s/.*SETON"//;
    $tags =~ s/"TAGID//g;
    $tags =~ s/(DIGAT",)|(DIGAT")/\ /g;
    $tags =~ s/,//g;

    @ttable = split("\ ",$tags);
    @tagtable;

    foreach $tag (@tagtable)
    {
	$affects=$tag;
	$affects =~ s/.*,"AFFECTS//;
	$affects =~ s/STCEFFA"//;
        foreach $tag2 (@ttable)
        {
            chomp($tag2);
            chomp($tag);

            if ($tag =~ m/${tag2}/)
            {
                $local_table[$count] = $tag;
                $count++;
                $found=1;
            }
        }

        if($found == 0 && $affects =~ m/VEN/)
        {
            push(@avail_tagtable,$tag);
        }
        $found = 0;
    }

    print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Venue: $venue</h2>
<hr size="1" noshade>
<br><br>
<div class=\"editItems\">
<form action=cwasys.pl method=GET>
<input type=hidden name=edit value=venue>
Venue: <input class=textfield type=text name=loc value="$venue"></p><br>
Capacity: <input class=textfield type=text name=space value="$space"></p><br>
<p>Notes: <textarea class=textfield rows=10 cols=40 name=notes>$notes</textarea></p>
<input type=hidden name=venid value=$venid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
<div class="editItems" style="padding-left: 50px">
Tag Editor<br>
<form action=cwasys.pl method="GET">
<input type="hidden" name="addtag" value="venue">
<input type="hidden" name="object" value="$venid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
HTML
createTagPopupBox(\@avail_tagtable,1);
print(STDOUT <<HTML);
<input type="submit" value="Add Tag"><br><br>
</form>
<form action=cwasys.pl method=GET>
Currently Linked Tags<br>
HTML
createTagPopupBox(\@local_table,11);
print(STDOUT <<HTML);
<input type="hidden" name="deltag" value="venue">
<input type="hidden" name="object" value="$venid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year">
<input type="submit" value="Remove">
</form>
</div>
</div>
HTML
}

sub editVenues()
{
    # Accepts in the old venid then searches the database for that entry
    # Recommits new changes with a lock by keeping the same primary key venid by deleting
    # the old line and append the new

    ($sid,$venid,$venue,$space,$notes,$file,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="VENID${venid}DINEV";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @tagsection = grep { /$name/ } @contents;
    $tags = join('',@tagsection);
    chomp($tags);
    $tags =~ s/.*SETON"//;
    @contents = grep { !/$name/ } @contents;
    $notes =~ s/\n/\\n/g;
    $venue=removeRegExp($venue);
    $space=removeRegExp($space);
    $notes=removeRegExp($notes);
    $entry="
	\"VENLOC${venue}COLNEV\",
	\"SPACE${space}ECAPS\",
	\"VENID$venid\DINEV\",
	\"NOTES${notes}SETON\"
	${tags}";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);

    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$venue name/notes changed",$logfile,$sid,$userfile,
	$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?delete=venue&
	vpbox=$venid&sid=$sid&y=$year&venform=Edit\">";
}

sub editAdminUserPage()
{
    ($sid,$userid,$msg,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/(coord)|(planner)/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $entry = `${GREP} USERID${userid}DIRESU $userfile`;
    chomp($entry);

    $email=$level=$passwdconfirm=$passwd=$username=$entry;
    $username =~ s/"UNAME//;
    $username =~ s/EMANU".*//;
    $email =~ s/.*,"EMAIL//;
    $email =~ s/LIAME".*//;
    $level =~ s/.*,"LEVEL//;
    $level =~ s/LEVEL",.*//;
    $username=addRegExp($username);
    $email=addRegExp($email);

    if($level =~ m/planner/)
    {
        $planner = "selected";
    }

    elsif($level =~ m/coord/)
    {
        $coordinator = "selected";
    }
    
    elsif($level =~ m/admin/)
    {
        $administrator = "selected";
    }

    print(STDOUT <<HTML);
<div id="content">
<h2>Editing User: $username</h2>
<hr size="1" noshade>
<div class=\"editItems\">
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
<input type=hidden name=edit value=user>
Username: $username</p><br>
<input type=hidden name=username value=$username>
Password: <input class=textfield type=password name=passwd value="TEMPPASSWD"></p><br>
Password (confirm): <input class=textfield type=password name=passwdconfirm value="TEMPPASSWD"></p><br>
E-mail: <input type=email name=email value="$email"></p><br>
Level: <select class=textfield name=level>
        <option value="planner" $planner>Planner</option>
        <option value="coord" $coordinator>Coordinator</option>
        <option value="admin" $administrator>Administrator</option>
</select></p><br>
<input type=hidden name=userid value=$userid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
</div>
HTML
}


sub editAdminUsers()
{
    ($sid,$userid,$username,$passwd,$confirm,$email,$ulevel,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="USERID${userid}DIRESU";

    open(IN, "<", $userfile);
    @contents = <IN>;
    close(IN);

    @oldpasswd = grep { /$name/ } @contents;
    $oldpasswd = join('',@oldpasswd);
    chomp($oldpasswd);
    @contents = grep { !/$name/ } @contents;
    $username=removeRegExp($username);
    $passwd=md5_hex($passwd);
    $confirm=md5_hex($confirm);
    $email=removeRegExp($email);

    $oldpasswd =~ s/.*,"PASSWD//;
    $oldpasswd =~ s/DWSSAP",.*//;
    chomp($oldpasswd);

    $specialhash = md5_hex("TEMPPASSWD");
    #$specialhash = "ef7784b1fa38946fdf69bcd71307431c";

    if ($passwd =~ m/$specialhash/ && $confirm =~ m/$specialhash/)
    {
        $passwd = $confirm = $oldpasswd;
    }

    @emailgrep = grep { /,"EMAIL${email}LIAME"/ } @usertable;
    $emailgrep = grep { !/,"USERID${userid}DIRESU"/ } @emailgrep;

    if ($passwd !~ /$confirm/)
    {
        $passwdproblem = 1;
    }

    if ($emailgrep || $passwdproblem)
    {
        if ($passwdproblem)
        {
            $errormessage .= "Password's don't match <br>";
        }

        if ($emailgrep)
        {
            $errormessage .= "E-mail is already registered <br>";
        }

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=user&upbox=$userid&sid=$sid&userform=Edit&msg=$errormessage\"";
        exit;
    }

    if($username =~ /admin/)
    {
	$ulevel = "admin";
    }

    $entry="
	\"UNAME${username}EMANU\",
	\"PASSWD${passwd}DWSSAP\",
	\"USERID$userid\DIRESU\",
	\"LEVEL${ulevel}LEVEL\",
	\"EMAIL${email}LIAME\"
	";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$userfile);

    # write new entry, keep current id
    addTableObject($entry,$userfile);

    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$username password/e-mail changed",$logfile,$sid,
	$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=ucpanel&y=$year\">";
}

sub editSchedulePage()
{
    ($sid,$Selection,$parti,$year,$day,$availfile,$page,$t,$f)=@_;
    @partitable=@$parti;
    $index=1;
    @indarray=split(/_/,$f);
    shift(@indarray);

    if(!$day)
    {
	$day = "Monday";
    }

    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Availability Editor - $day</h2>
<hr size="1" noshade>
<SCRIPT TYPE="text/javascript">
<!--
    function changeElement(selection)
    {
	if(selection=="Participant")
        {
            window.location = 'cwasys.pl?sid=$sid&pid=pseditor&f=$f&day=$day&y=$year'
        }
       
	else
        {
            window.location = 'cwasys.pl?sid=$sid&pid=vseditor&day=$day&y=$year'
        }
    }

    function changeDay(selection)
    {
HTML
    if ($pid =~ m/pseditor/)
    {
print(STDOUT <<HTML);
        window.location = "cwasys.pl?sid=$sid&pid=pseditor&page=$page&t=$t&f=$f&y=$year&day="+selection;
HTML
    }

    elsif ($pid =~ m/vseditor/)
    {
print(STDOUT <<HTML);
        window.location = "cwasys.pl?sid=$sid&pid=vseditor&page=$page&t=$t&y=$year&day="+selection;
HTML
                }
print(STDOUT <<HTML);
    }

    function checkBoxes(ParticipantCheckbox, rowNum)
    {
        if(ParticipantCheckbox.checked)
        {
            rowNum.bgColor="blue"
        }
    
        else
        {
            rowNum.bgColor="white"
        }
    }

    function End()
    {
    	window.location = "#bottom";
    }

//-->
</SCRIPT>

        <table border="0" cellpadding="10">
        <tr>
        <td>
        <form name="Row" action="">
        Row:
        <select name="Row" onChange="changeElement(this.options[this.selectedIndex].value)">
HTML
        if ($Selection =~ m/Participant/)
        {
        print(STDOUT <<HTML);
        <option value="Participant" name="Participant" selected>Participant</option>
        <option value="Venue" name="Venue">Venue</option>
HTML
        }

        else
        {
        print(STDOUT <<HTML);
        <option value="Participant" name="Participant">Participant</option>
        <option value="Venue" name="Venue" selected>Venue</option>
HTML
        }

        print(STDOUT <<HTML);
        </select>
        </form></td>

        <td><form name="Day" action="">
        Day:
        <select name="Day" onChange="changeDay(this.options[this.selectedIndex].value)">
HTML

    if ($day =~ m/Monday/) { $monday = "selected"; }
    if ($day =~ m/Tuesday/) { $tuesday = "selected"; }
    if ($day =~ m/Wednesday/) { $wednesday = "selected"; }
    if ($day =~ m/Thursday/) { $thursday = "selected"; }
    if ($day =~ m/Friday/) { $friday = "selected"; }

print(STDOUT <<HTML);

        <option value="Monday" $monday>Monday</option>
        <option value="Tuesday" $tuesday>Tuesday</option>
        <option value="Wednesday" $wednesday>Wednesday</option>
        <option value="Thursday" $thursday>Thursday</option>
        <option value="Friday" $friday>Friday</option>
        </select>

        </form>
        </td>
        </tr>
        </table>
	<b> Key </b><br>
	<input type=checkbox>Available (open checkbox)
	<br><input type=checkbox checked>Not available (checked checkbox)
	<br><input type=checkbox checked disabled>Scheduled in a panel (disabled checkbox)
        <table class="bettyTable" name="bettyTable" width="853" cellpadding=0>
HTML

    $size = @partitable;
    $sizeind = @indarray;
    if ($sizeind == 0)
    {
    	if (!$page)
     	{ # starting point
            $page=1;
        }

        if ((!$t) || ($t==10))
        { # number per page
            $t=$size; #t = 10 for paging, = size for no page
            #$num_pages=$size/$t;
            $num_pages=roundUp($num_pages);
            $page+=0;
            $t+=0;
            $i++;

            #print "Pages - ";

    	    while ($i <= $num_pages)
    	    {
            	if ($i == $page)
            	{
            	    print "[$i]";
                }

                else
                {
		    if ($Selection =~ m/Participant/)
		    {
                	print "<a href=\"cwasys.pl?sid=$sid&pid=pseditor&page=$i
			&t=$t&y=$year&day=$day\">[$i]</a>";
		    }

		    else
		    {
			print "<a href=\"cwasys.pl?sid=$sid&pid=vseditor&page=$i
			&t=$t&y=$year&day=$day\">[$i]</a>";
		    }
                }

            	$i++;
            }

            $start=($page-1)*$t+1;
            $max=$page*$t;
        } 
    }

    else
    {
	print "<a href=\"cwasys.pl?sid=$sid&pid=pseditor&page=$i&t=10&y=$year&day=$day\">[Page View]</a>";
	$start = 0;
        # BUG !!!!! 
	# If max isn't zero, we can't filter properly
	# However, max needs to be the max to check for dechecks
	$max = 0;
    }

    @timearray=("08:00","09:00","10:00","11:00","12:00","01:00","02:00","03:00",
		"04:00","05:00","06:00","07:00");

    print (STDOUT <<HTML);
			</tr>
			<input type="hidden" name="paneledit" value="notes">
<input type="hidden" name="panelid" value="$panelid">
<input type="hidden" name="sid" value="$sid">
<input type="hidden" name="y" value="$year"><tr>
HTML
	if ($Selection =~ m/Participant/)
	{
	    print (STDOUT <<HTML);
			        <th class=\"noprint\" width="30" height="10">
				    Add
				</th>
HTML
	}
	print (STDOUT <<HTML);
				<th width="40" height="10">
HTML
    if($Selection =~ m/Participant/)
    {
	print "Participants ";
    }
	else
	{
	    print "Venues ";
	}

    print "<input class=\"noprint\" type=\"button\" value=\"End\" onClick=\"End()\">";

    foreach $index (@timearray)
    {
        print "<th width=\"50\" height=\"10\">";
        print "$index";
        print "</th>";
    }

    print "<th width=\"10\" height=\"10\">";
    print "All";
    print "</th>";

print (STDOUT <<HTML);
                                </td>
                        </tr>
                        <form action="avail" name="selectTimes" method=POST>
HTML
        if ($Selection =~ m/Participant/)
        {
            createEditScheduleBox(\@partitable,$availfile,$day,$year,$start,$max,$page,\@indarray);
        }

        else
        {
            createEditVenueBox(\@venuetable,$availfile,$day,$year,$start,$max,$page);
        }
        print(STDOUT <<HTML);
                </table>

	        <SCRIPT TYPE="text/javascript">
       		<!--
        	function filterParts()
        	{
			var i=$start;
			var x = "";
HTML
	if ($start == 0)
	{}
	else
	{
	print(STDOUT <<HTML);
			for(i=$start;i<=$max;i++)
			{
				if(document.getElementById("CHECKOUT"+i).checked)
				{
					x = x + "_" + i;
				}
			}
HTML
	}
	foreach $entry (@indarray)
	{
	print(STDOUT <<HTML);
		if(document.getElementById("CHECKOUT$entry").checked)
		{
			x = x + \"_\" + $entry;
		}
HTML
	}	
	print(STDOUT <<HTML);
			window.location = "cwasys.pl?sid=$sid&pid=pseditor&page=$page&f="+x+"&t=10&y=$year&day=$day";
        	}
		function addPanel()
		{
			var i=$start;
			var x = "";
HTML
	if ($start == 0)
	{}
	else
	{
	print(STDOUT <<HTML);
			for(i=$start;i<=$max;i++)
			{
				if(document.getElementById("CHECKOUT"+i).checked)
				{
					x = x + "_" + i;
				}
			}
HTML
	}
	foreach $entry (@indarray)
	{
	print(STDOUT <<HTML);
		if(document.getElementById("CHECKOUT$entry").checked)
		{
			x = x + \"_\" + $entry;
		}
HTML
	}	
	print(STDOUT <<HTML);

			window.location = "cwasys.pl?sid=$sid&add=panel&pid=pseditor&page=$page&f="+x+"&t=10&y=$year&day=$day";
		}

	function saveChanges()
	{
	    window.location = "";
	}
		//-->
       		</SCRIPT>
HTML
    if ($Selection =~ m/Participant/)
    {
	print (STDOUT <<HTML);
		<input type="button" value="Add Panel" onClick="addPanel()">
		<input type="button" value="Filter Participants" onClick="filterParts()">
                <input type="submit" value="Save Changes">
                <input type="button" value="Print Schedule" onClick="window.print()">
HTML
    }
	else
	{
	    print (STDOUT <<HTML);
                <input type="submit" value="Save Changes">
                <input type="button" value="Print Schedule" onClick="window.print()">
HTML
	}
    print (STDOUT <<HTML);
		</form>
	    <h1 id="bottom"></h1>
        </div>
</td>
</tr>
</table>
HTML
}

sub editTagPage()
{
    ($sid,$tagid,$tagfile,$year,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $exists=@sentry=grep { /,"TAGID${tagid}DIGAT",/ } @tagtable;

    if (!$exists)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=teditor&y=$year\">";
        exit 1;
    }

    $entry = join('',@sentry);
    chomp($entry);

    $buffer=$needs=$tagname=$tagid=$entry;
    $tagid =~ s/.*,"TAGID//;
    $tagid =~ s/DIGAT",.*//;
    $tagname =~ s/"TAGNAME//;
    $tagname =~ s/EMANGAT",.*//;
    $buffer =~ s/.*,"AFFECTS//;
    $buffer =~ s/STCEFFA",.*//;
    $needs =~ s/.*,"NEEDS//;
    $needs =~ s/SDEEN",.*//;

    if ($buffer =~ m/PAR/) { $parcheck = "checked"; }
    if ($buffer =~ m/VEN/) { $vencheck = "checked"; }
    if ($buffer =~ m/PRO/) { $procheck = "checked"; }
    if ($buffer =~ m/MOD/) { $modcheck = "checked"; }

    if ($needs =~ m/CANT/) { $cantcheck = "checked"; }
    else { $mustcheck = "checked"; }

    $tagname=addRegExp($tagname);

    print(STDOUT <<HTML);
<div id="content">
<h2>Editing $yearname Tag $tagname</h2>
<hr size="1" noshade>
<br><br>
<div class="editItems">
<form action=cwasys.pl method=GET>
<input type=hidden name=edit value=tag>
<p>Tag Name: <input class=textfield class=textfield type=text name=tagname value="$tagname"></p>
<table cellspacing=0 class=bettyTable width=300>
<tr><td>Affects</td><td>Type</td><td rowspan="5">Must Have <input type=radio name=must value=MUST $mustcheck><br>
Can't Have <input type=radio name=must value=CANT $cantcheck></td></tr>
<tr><td><input type=checkbox name=tagpar value=PAR $parcheck></td><td>Participants</td></tr>
<tr><td><input type=checkbox name=tagven value=VEN $vencheck></td><td>Venues</td></tr>
<tr><td><input type=checkbox name=tagmod value=MOD $modcheck></td><td>Moderators</td></tr>
<tr><td><input type=checkbox name=tagpro value=PRO $procheck></td><td>Producers</td></tr>
</table>
<input type=hidden name=tagid value=$tagid>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=submit value="Update">
</form>
</div>
</div>
HTML
}

sub editTags()
{
    ($sid,$tagid,$tagname,$file,$logfile,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $name="TAGID${tagid}DIGAT";

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    $buffer = $ENV{'QUERY_STRING'};
    if ($buffer =~ m/tagpar/) { $affects .= "PAR"; }
    if ($buffer =~ m/tagven/) { $affects .= "VEN"; }
    if ($buffer =~ m/tagpro/) { $affects .= "PRO"; }
    if ($buffer =~ m/tagmod/) { $affects .= "MOD"; }

    if ($buffer =~ m/CANT/) { $needs = "CANT"; }
    else { $needs = "MUST"; }

    @contents = grep { !/$name/ } @contents;
    $tagname=removeRegExp($tagname);
    $entry="
	\"TAGNAME${tagname}EMANGAT\",
	\"TAGID${tagid}DIGAT\",
	\"AFFECTS${affects}STCEFFA\"
	\"NEEDS${needs}SDEEN\"
	";
    $entry =~ s/\n|\t//g;

    # delete old entry
    deleteTableObject(\@contents,$file);

    # write new entry, keep current id
    addTableObject($entry,$file);

    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"$tagname updated",$logfile,$sid,$userfile,$sessifile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=teditor&y=$year\">";
}

1;
