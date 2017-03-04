#!/usr/local/bin/perl

# COWAbunga -
# File: delete.pl
# Conference on World Affairs Scheduler
#   This file contains the delete library functions to remove
#   entries in the text database.
#   Status: STABLE

sub deleteConference()
{
    # Deletes a panel by year along with its part/ven availability.
    # This is more of a cleanup utility in case the database gets larger than 
    # an allowed quota.

    ($sid,$cpbox,$conference,$logfile,$year,$DBDIRECTORY,$userfile,$sessifile)
	=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

      # obtain numer of conferences and convert string to integer
    $num = `${LS} ${DBDIRECTORY}panels*db | wc -l`;
    $num =~ s/ //g;
    chomp($num);
    $num+=0;

    if($num > 1)
    {
	open(IN,"<",$conference);
	@conference = <IN>;
	close IN;

	@contents = grep { !/"YID${cpbox}DIY"/ } @conference;
	deleteTableObject(\@contents,$conference);

	$delConf = `${RM} ${DBDIRECTORY}participants${cpbox}.db \\
			${DBDIRECTORY}participants${cpbox}.count \\
			${DBDIRECTORY}producers${cpbox}.db \\
			${DBDIRECTORY}producers${cpbox}.count \\
			${DBDIRECTORY}moderators${cpbox}.db \\
			${DBDIRECTORY}moderators${cpbox}.count \\
			${DBDIRECTORY}venues${cpbox}.db \\
			${DBDIRECTORY}venues${cpbox}.count \\
			${DBDIRECTORY}panels${cpbox}.db \\
			${DBDIRECTORY}panels${cpbox}.count \\
			${DBDIRECTORY}conflicts${cpbox}.db \\
			${DBDIRECTORY}conflictsquiet${cpbox}.db \\
			${DBDIRECTORY}tags${cpbox}.db \\
			${DBDIRECTORY}tags${cpbox}.count`;
	$delAvail = `${RM} ${DBDIRECTORY}venavail${cpbox}Monday.db \\
			${DBDIRECTORY}venavail${cpbox}Tuesday.db \\
			${DBDIRECTORY}venavail${cpbox}Wednesday.db \\
			${DBDIRECTORY}venavail${cpbox}Thursday.db \\
			${DBDIRECTORY}venavail${cpbox}Friday.db `;
	$delAvail = `${RM} ${DBDIRECTORY}partavail${cpbox}Monday.db \\
			${DBDIRECTORY}partavail${cpbox}Tuesday.db \\
			${DBDIRECTORY}partavail${cpbox}Wednesday.db \\
			${DBDIRECTORY}partavail${cpbox}Thursday.db \\
			${DBDIRECTORY}partavail${cpbox}Friday.db `;
        addLogMessage("n/a","Deleted conference $cpbox",$logfile,$sid,
	$userfile,$sessifile);
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=ceditor">
HTML
}

sub deleteModerators()
{
    # Greps for a specified table UID ($mpbox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$mpbox,$file,$confile,$condisfile,$pavailfile,$vavailfile,
	$logfile,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$mpbox;
    $moderatorname = getModeratorNamefromID($mpbox);
    $name="MODID${tableid}DIDOM";

    # Delete the moderator from the moderator table
    @contents = grep { !/$name/ } @modertable;
    deleteTableObject(\@contents,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Deleted $moderatorname",$logfile,$sid,$userfile,
	$sessifile);

    # Delete the moderator from any corresponding panels
    foreach $pan (@paneltable)
    {
	if ($pan =~ m/MODID${tableid}DIDOM/)
	{
	    $pan =~ s/$name/MODIDDIDOM/;
            deleteTableObject(\@paneltable,$panelfile);
            $chompedpan = $pan;
            chomp($chompedpan);
            conflictDetect($confile,$condisfile,$chompedpan);
	}
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=meditor&y=$year">
HTML
}

sub deleteParticipants()
{
    # Greps for a specified table UID ($ppbox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$ppbox,$file,$confile,$condisfile,$pavailfile,$vavailfile,$logfile,
	$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$ppbox;
    $participantname=getParticipantNamefromID($ppbox);
    $name=",\"PARTID${tableid}DITRAP\"";
    chomp($name);
    $aname=",\"ALTPID${tableid}DIPTLA\"";
    chomp($aname);

    @contents = grep { !/$name/ } @partitable;
    deleteTableObject(\@contents,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Deleted $participantname",$logfile,$sid,$userfile,
	$sessifile);

    # Delete the participant from any corresponding panels
    foreach $pan (@paneltable)
    {
        if ($pan =~ m/$name/)
        {
            $pan =~ s/$name//;
            deleteTableObject(\@paneltable,$panelfile);
            $chompedpan = $pan;
            chomp($chompedpan);
	    $tempfile = $pavailfile;

	    @daytable = ("Monday","Tuesday","Wednesday","Thursday","Friday");

            # Remove participant availability to keep parti table small
	    foreach $day (@daytable)
	    {
		$pavailfile = "${pavailfile}${day}.db";
            	open(IN,"<",$pavailfile);
            	@pavailtable=<IN>;
            	close(IN);
            	@contents = grep { !/USERID${tableid}DIRESU/ } @pavailtable;
            	deleteTableObject(\@contents,$pavailfile);
		@pavailtable = ();
		$pavailfile = $tempfile;
	    }

            # Run conflict detection to see if we caused any problems
            conflictDetect($confile,$condisfile,$chompedpan);
        }

	if ($pan =~ m/$aname/)
	{ # Delete alternate correspondence on panels
	    $pan =~ s/$aname//;
            deleteTableObject(\@paneltable,$panelfile);
	}
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=peditor&y=$year">
HTML
}

sub deleteProducers()
{
    # Greps for a specified table UID ($pubox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$pubox,$file,$confile,$condisfile,$pavailfile,$vavailfile,$logfile,
	$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$pubox;
    $producername=getProducerNamefromID($pubox);
    $name="PRODID${tableid}DIDORP";

    @contents = grep { !/$name/ } @produtable;
    deleteTableObject(\@contents,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Deleted $producername",$logfile,$sid,$userfile,
	$sessifile);

    # Delete the producer from any corresponding panels
    foreach $pan (@paneltable)
    {
        if ($pan =~ m/PRODID${tableid}DIDORP/)
        {
            $pan =~ s/$name/PRODIDDIDORP/;
	    deleteTableObject(\@paneltable,$panelfile);
	    $chompedpan = $pan;
	    chomp($chompedpan);
	    conflictDetect($confile,$condisfile,$chompedpan);
        }
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=proeditor&y=$year">
HTML
}

sub deleteVenues()
{
    # Greps for a specified table UID ($vpbox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$vpbox,$file,$confile,$condisfile,$pavailfile,$vavailfile,$logfile,
	$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$vpbox;
    $venuename = getVenueNamefromID($vpbox);
    $name="VENID${tableid}DINEV";

    @contents = grep { !/$name/ } @venuetable;
    deleteTableObject(\@contents,$file);
    $table = `${BASENAME} $file`;
    chomp($table);
    addLogMessage($table,"Deleted $venuename",$logfile,$sid,$userfile,
	$sessifile);

    # Delete the moderator from any corresponding panels
    foreach $pan (@paneltable)
    {
        if ($pan =~ m/VENID${tableid}DINEV/)
        {
	    $pan =~ s/$name/VENIDDINEV/;
            deleteTableObject(\@paneltable,$panelfile);
            $chompedpan = $pan;
            chomp($chompedpan);

            $tempfile = $vavailfile;
            @daytable = ("Monday","Tuesday","Wednesday","Thursday","Friday");

            foreach $day (@daytable)
            {
	        # Remove venue availability to keep venue table small
		$vavailfile = "${vavailfile}${day}.db";
	        open(IN,"<",$vavailfile);
	        @vavailtable=<IN>;
	        close(IN);
	        @contents = grep { !/USERID${tableid}DIRESU/ } @vavailtable;
	        deleteTableObject(\@contents,$vavailfile);
		$vavailfile = $tempfile;
	    }
            # Run conflict detection to see if we caused any problems
            conflictDetect($confile,$condisfile,$chompedpan);
        }
    }
    
    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=veditor&y=$year">
HTML
}

sub deletePanels()
{
    # Greps for a specified table UID ($panbox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$panbox,$file,$confile,$condisfile,$pavailfile,$vavailfile,$logfile,
	$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$panbox;
    $name="PANID${tableid}DINAP";

    @day = grep { /$name/ } @paneltable;
    $day = join('',@day);
    $day =~ s/.*,"DAY//;
    $day =~ s/YAD",.*//;
    chomp($day);

    open(IN, "<", $file);
    @contents = <IN>;
    close(IN);

    @contents = grep { !/$name/ } @contents;

    # Delete the panel
    deleteTableObject(\@contents,$file);

    # Delete conflicts attached to that panel
    open(IN,"<",$confile);
    @global_conflicts=<IN>;
    close(IN);
    
    @global_conflicts = grep { !/${name}/ } @global_conflicts;
    deleteTableObject(\@global_conflicts,$confile);

    # Delete disabled conflicts attached to that panel
    open(IN,"<",$condisfile);
    @disabled_conflicts=<IN>;
    close(IN);

    @disabled_conflicts = grep { !/${name}/ } @disabled_conflicts;
    deleteTableObject(\@disabled_conflicts,$condisfile);

    # Delete participant availability attached to that panel
    $pavailfile = "${pavailfile}${day}.db";
    open(IN,"<",$pavailfile);
    @partavail=<IN>;
    close(IN);

    @partavail = grep { !/PANID${tableid}DINAP/ } @partavail;
    deleteTableObject(\@partavail,$pavailfile);

    # Delete venue availability attached to that panel
    $vavailfile = "${vavailfile}${day}.db";
    open(IN,"<",$vavailfile);
    @venavail=<IN>;
    close(IN);

    @venavail = grep { !/PANID${tableid}DINAP/ } @venavail;
    deleteTableObject(\@venavail,$vavailfile);

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=paneditor&y=$year">
HTML
}

sub deleteUsers()
{
    # Greps for a specified table UID ($upbox) and deletes the line from the 
    # file with successful lock.  Without one, no change are made.

    ($sid,$upbox,$logfile,$year,$userfile,$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/(planner)|(coord)/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$upbox;
    $name="USERID${tableid}DIRESU";

    open(IN, "<", $userfile);
    @contents = <IN>;
    close(IN);

    @username = grep { /$name/ } @contents;
    $username = join('',@username);
    chomp($username);
    $username =~ s/.*"UNAME//;
    $username =~ s/EMANU",.*//;

    if ($username !~ m/admin/)
    { # The main admin account can NEVER be deleted
        @contents = grep { !/$name/ } @contents;
        deleteTableObject(\@contents,$userfile);
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=ucpanel&y=$year">
HTML
}

sub deleteTags()
{
    # Greps for a specified table UID ($pubox) and deletes the line from the 
    # file with successful lock.  Without one, no changes are made.

    ($sid,$tagbox,$file,$confile,$condisfile,$logfile,$year,$userfile,
	$sessifile) = @_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
	sid=$sid\">";
        exit 1;
    }

    $tableid=$tagbox;
    $name=",\"TAGID${tableid}DIGAT\"";

    @contents = grep { !/$name/ } @tagtable;
    deleteTableObject(\@contents,$file);

    # Delete the tag from all people and places

    @tags_participants = grep { /$name/ } @partitable;
    @tags_producers = grep { /$name/ } @produtable;
    @tags_moderators = grep { /$name/ } @modertable;
    @tags_venues = grep { /$name/ } @venuetable;

    @tags_par = grep { !/$name/ } @partitable;
    @tags_pro = grep { !/$name/ } @produtable;
    @tags_mod = grep { !/$name/ } @modertable;
    @tags_ven = grep { !/$name/ } @venuetable;

    if (@tags_participants)
    {
        foreach $tag (@tags_participants)
	{
	    $tag =~ s/$name//g;
	    $userid = $tag;
	    $userid =~ s/.*,"PARTID//;
	    $userid =~ s/DITRAP",.*//;
	    chomp($userid);
	    @local_panels = grep { /,"PARTID${userid}DITRAP"/ } @paneltable;

	    foreach $panel (@local_panels)
	    {
		chomp($panel);
		conflictDetect($confile,$condisfile,$panel);
	    }
	}
	
	deleteTableObject(\@tags_par,$partifile);
	addTableObjects(\@tags_participants,$partifile);
    }

    if (@tags_producers)
    {
        foreach $tag (@tags_producers)
        {
            $tag =~ s/$name//g;
            $userid = $tag;
            $userid =~ s/.*,"PRODID//;
            $userid =~ s/DIDORP",.*//;
            chomp($userid);
            @local_panels = grep { /,"PRODID${userid}DIDORP"/ } @paneltable;

            foreach $panel (@local_panels)
            {
		chomp($panel);
                conflictDetect($confile,$condisfile,$panel);
            }
        }

        deleteTableObject(\@tags_pro,$produfile);
        addTableObjects(\@tags_producers,$produfile);
    }

    if (@tags_moderators)
    {
        foreach $tag (@tags_moderators)
        {
            $tag =~ s/$name//g;
            $userid = $tag;
            $userid =~ s/.*,"MODID//;
            $userid =~ s/DIDOM",.*//;
            chomp($userid);
            @local_panels = grep { /,"MODID${userid}DIDOM"/ } @paneltable;

            foreach $panel (@local_panels)
            {
		chomp($panel);
                conflictDetect($confile,$condisfile,$panel);
            }
        }

        deleteTableObject(\@tags_mod,$moderfile);
        addTableObjects(\@tags_moderators,$moderfile);
    }

    if (@tags_venues)
    {
        foreach $tag (@tags_venues)
        {
            $tag =~ s/$name//g;
            $userid = $tag;
            $userid =~ s/.*,"VENID//;
            $userid =~ s/DINEV",.*//;
            chomp($userid);
            @local_panels = grep { /,"VENID${userid}DINEV"/ } @paneltable;

            foreach $panel (@local_panels)
            {
		chomp($panel);
                conflictDetect($confile,$condisfile,$panel);
            }
        }

        deleteTableObject(\@tags_ven,$venuefile);
        addTableObjects(\@tags_venues,$venuefile);
    }

    print( STDOUT <<HTML );
<meta http-equiv="refresh" content="0; url=cwasys.pl?sid=$sid&pid=teditor&y=$year">
HTML
}

1;
