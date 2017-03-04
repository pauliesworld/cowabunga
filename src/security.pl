#!/usr/local/bin/perl

# COWAbunga -
# File: security.pl
# Conference on World Affairs Scheduler
#   This file holds the login authentication procedure that checks
#   requests against the user table of the database.
#   Status: STABLE

my $datenow=getEpochSeconds();

sub security()
{
    # Verifies username and password against the users table.
    # Redirects user to main cwasys.pl page afterwords if successful, else
    # they get the boot.  Sessions are also purged in this section to
    # eliminate file size of sessions.db (MAKES THINGS FASTER)

    ($user,$pass,$file,$sessifile,$idfile,$logfile)=@_;

    $password = md5_hex($password);
    $login="\"UNAME${username}EMANU\",\"PASSWD${password}DWSSAP\"";
    $vari=0;

    open(IN,$file)||die("User table currently unavailable");
    @usertable = <IN>;
    close(IN);

    foreach $person (@usertable)
    {
        if($person =~ m/$login/)
        {
            $vari=1;
	    $uid=$person;
	    $uid =~ s/.*DWSSAP","USERID//;
	    $uid =~ s/DIRESU.*//;
	    chomp($uid);
        }
    }

    if($vari =~ m/1/)
    {
	sessionPurge($sessifile);
	$sid=sessionCreate($uid,$sessifile,$idfile);
        $table = `${BASENAME} $file`;
        chomp($table);
 	#addLogMessage($table,"$user logged in",$logfile,$sid,$file,$sessifile);
        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	sid=$sid\">";
    }

    else
    {
        initUI();
        print "<br><center><font color=red>Sorry, your credentials were not
	 recognized by the system</font></center><br>";
        authenticateForm();
        finalizeUI();
    }
}

sub sessionCreate()
{
    # Creates a session after a successful login attempt so that the security 
    # team doesn't kick out our user when it enters cwasys.pl.  We use the userid
    # and cookies to identify each user so that they can have multiple logins
    # under the same username without interference between sessions.

    ($userid,$sessifile,$idfile) = @_;

    open(IN, "<", $idfile)||die("ID file is currently unavailable.");
    $tableid=<IN>;
    close IN;

    $id=$tableid;
    $tableid++;

    sysopen(OUT,$idfile,O_WRONLY|O_TRUNC);
    if(flock(OUT, LOCK_EX)==0)
    {
        printf("A locked state has prevented the database committment");
    }
    
    else
    {
        print OUT $tableid;
        close(OUT);
    }

    chomp($date);
    # screwing with the cookies here
    $ipaddy="$ENV{'REMOTE_ADDR'}";#$ENV{'HTTP_COOKIE'}";
    $entry="
	\"SID${id}DIS\",
	\"USERID${userid}DIRESU\",
	\"COOKIE${ipaddy}EIKOOC\",
	\"LAST${datenow}TSAL\"
	";
    $entry =~ s/\n|\t//g;

    addTableObject($entry,$sessifile);

    return $id;
}

sub sessionCheck()
{
    # After every page access, we check the session to keep the bad guys out.
    # Essentially, we recreate what a person's session should look like and grep
    # for it against the sessions.db file.  If there is no match, we kick them
    # out.  Additionally, after 15 minutes of inactivity, we also remove the 
    # session to ensure that a person leaving the room doesn't allow for 
    # unwanted system access.

    $vari=0;
    ($sessionref,$sid,$sessifile)=@_;
    @sessiontable=@$sessionref;
    # Cookies don't work
    $ipaddy="$ENV{'REMOTE_ADDR'}";#$ENV{'HTTP_COOKIE'}";
    
    foreach $entry (@sessiontable)
    {
	if(($entry =~ m/SID${sid}DIS/) && ($entry =~ m/COOKIE${ipaddy}EIKOOC/))
	{
	    $vari=1;
	    $dateold=$entry;
	    $dateold =~ s/.*EIKOOC","LAST//;
	    $dateold =~ s/TSAL.*//;

	    $datenow+=0;
	    $dateold+=0;

	    if(($datenow-$dateold) > ${SESSIONTIMEOUT}*60)
	    {
		print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?
		msg=1&sid=$sid\">";
		exit 0;
	    }

	    else
	    {
	        $entry =~ s/$dateold/$datenow/;
	    }
	}
    }

    deleteTableObject(\@sessiontable,$sessifile);

    if($vari =~ m/0/)
    {
	print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2\">";
	exit 0;
    }
}

sub sessionPurge()
{
    ($sessifile)=@_;
    # Identifies sessions older than 30 minutes since last access and 
    # deletes them

    open(IN,"<",$sessifile);
    @sessitable=<IN>;
    close IN;

    foreach $entry (@sessitable)
    {
    	$dateold=$entry;
    	$dateold =~ s/.*EIKOOC","LAST//;
    	$dateold =~ s/TSAL.*//;

    	$datenow+=0;
    	$dateold+=0;

	    # purge after 30 minute inactive window
        if(($datenow-$dateold) > 1800)
        {
	    $entry="";
	}
    }

    deleteTableObject(\@sessitable,$sessifile);
}

sub deleteSession()
{
    # When a user logs out, we delete their session to remain secure

    ($sid,$sessifile)=@_;

    open(IN,"<",$sessifile);
    @sessitable=<IN>;
    close IN;

    @sessitable = grep { !/SID${sid}DIS/ } @sessitable;
    deleteTableObject(\@sessitable,$sessifile);
}

sub getUserName()
{
    # Examines a user's session to get their userid and then parses the users 
    # table to find their username.

    ($sid,$userfile,$sessifile)=@_;
    
    open(IN,"<",$userfile);
    @usertable=<IN>;
    close IN;

    open(IN,"<",$sessifile);
    @sessitable=<IN>;
    close IN;

    foreach $entry (@sessitable)
    {
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
	    $username=$entry;
	    $username =~ s/"UNAME//;
	    $username =~ s/EMANU",.*//;
	}
    }
    return($username);
}

sub getAccessLevel()
{
    # Examines a user's session to get their userid and then parses the users 
    # table to find their access level.

    ($sid,$userfile,$sessifile)=@_;

    open(IN,"<",$userfile);
    @usertable=<IN>;
    close IN;

    open(IN,"<",$sessifile);
    @sessitable=<IN>;
    close IN;

    foreach $entry (@sessitable)
    {
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
            $level=$entry;
            $level =~ s/.*,"LEVEL//;
            $level =~ s/LEVEL",.*//;
        }
    }
    return($level);
}

1;
