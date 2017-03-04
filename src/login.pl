#!/usr/local/bin/perl

# COWAbunga -
# File: login
# Conference on World Affairs Scheduler
#   This file controls the password authentication
#   to enter the system.

require "../CONFIGURE";

my $userfile="${DBDIRECTORY}users.db";
my $sessifile="${DBDIRECTORY}sessions.db";
my $idfile="${DBDIRECTORY}sessions.count";
my $logfile="${DBDIRECTORY}logs.db";

handler();

sub handler()
{
    print "Content-type: text/html\r\n\r\n";

    $year = ".";
    backupSnapshot($DBDIRECTORY,$year,$sid,$userfile,$sessifile);

    ($username,$password,$ret)=getUserInfo();
    $pid=param('pid');
    $msg=param('msg');
    $sid=param('sid');

    if($username)
    {
        security($username,$password,$userfile,$sessifile,$idfile,$logfile);
    }

    elsif($pid =~ m/pwforget/)
    {
   	initUI();
    	forgotPassword();
    }

    elsif($ret)
    {
        initUI();
        doesRetrieverExist($ret);
	print "<br><center><font color=blue>Your username and password has been\
		e-mailed to you if it exists in the system.</font></center><br>\	        ";
	authenticateForm();
	finalizeUI();
    }

    else
    {
        initUI();

        if($msg)
        {
            if($msg =~ m/1/)
            {
                print "<br><center><font color=red>Your session has expired.  
		Please login again.</font></center><br>";
            }

            elsif($msg =~ m/2/)
    	    {
        	print "<br><center><font color=red>Your session is invalid.  
		Please login again.</font></center><br>";
            }

	    elsif($msg =~ m/3/)
	    {
	        deleteSession($sid,$sessifile);
	        print "<br><center><font color=blue>You have successfully logged
		out.</font></center><br>";
	    }
    	}
	else
	{
	    print "<br><br><br>";
	}

        authenticateForm();
        finalizeUI();
    }
}

sub getUserInfo()
{
    # We POST to login from previous form so that we can read directly from 
    # STDIN.  This is a secure thing to do rather than sending things over the
    # URL for all to see.
    
    my $query;
    read(STDIN,$query,$ENV{CONTENT_LENGTH});
    my @param = split(/&/,$query);
    my %pairs = ();

    foreach my $item (@param)
    {
        my ($key,$value)=split(/=/,$item);
        $key   =~ tr/+/ /;
        $value =~ tr/+/ /;
        $key   =~ s/%([A-F\d]{2})/chr(hex($1))/ieg;
        $value =~ s/%([A-F\d]{2})/chr(hex($1))/ieg;
        $pairs{$key} = $value;
    }

    my $username = $pairs{user};
    my $password = $pairs{pass};
    my $ret = $pairs{ret};
    return($username,$password,$ret);
}

sub initUI()
{
    print( STDOUT <<HTML );
<html>
    <head>
	<title>Conference on World Affairs Scheduling System</title>
        <link href="${URLCSS}COWA.css" rel="stylesheet" type="text/css">
    </head>

    <body bgcolor="#ffffff" onLoad="focus();login.user.focus()">
        <center><br><br><br><br><br>
	<table class="loginbox" cellpadding="0" cellspacing="0" width="450">
	    <tr>
		<td>
		    <center>
			<br>
			<b>Conference on World Affairs</b><br>
			<b>Scheduling System</b><br>
HTML
}

sub authenticateForm()
{
    if( !defined( $ENV{'HTTP_COOKIE'} ) )
    {
    	#print "Your browser has cookies disabled.  They need to be enabled in order to use the scheduling system.<br><br>";
	#$disabled="disabled";
    }

    print( STDOUT <<HTML );
			<form name="login" action="login.pl" method=POST>
			<table class="logintable" cellpadding=0 cellspacing=0 border=0><tr><td>
			Username:</td>
			<td><input type="text" name=user size="20" $disabled><br></td></tr><tr><td>
			Password:</td><td>
			<input type="password" name=pass size="20" $disabled><br></td></tr>
			</table>
			<input type="submit" value="Login" size="20" $disabled>
			</form>
HTML
}

sub finalizeUI()
{
    print (STDOUT <<HTML );
                    <center>
			<a href="login.pl?pid=pwforget">Forgot your password?</a><br><br>
		    </center>
                </td>
            </tr>
        </table>
	</center>
    </body>
</html>

HTML
}

sub forgotPassword()
{
    print (STDOUT <<HTML );
			<br><br>
			    <form action="login.pl" method=POST>
				Enter your username or e-mail address:<br>
				<input type="text" name=ret size="20"><br><br>
				<input type="submit" value="E-mail my password" size="20"><br>
			    </form>
		    </center>
                </td>
            </tr>
        </table>
    </body>
</html>

HTML
}

sub doesRetrieverExist()
{
    # Check if an inputted username or e-mail address is active in the users
    # table.  If active, e-mail them their password, then send user back to the 
    # login page.

    ($ret)=@_;
    $user=$email=$ret;
    $user=removeRegExp($user);
    $email=removeRegExp($email);
    $user="UNAME${user}EMANU";
    $email="EMAIL${email}LIAME";

    open(USER,"$userfile")||die"User file missing\n";
    @usertable=<USER>;
    close(USER);

    foreach $entry (@usertable)
    { # first check if the specified user/email is in the usertable
	if ($entry =~ m/$user|$email/)
	{
	    $pivot=$entry;
	}
    }
 
    if($pivot)
    { # if a match is found previous, get their information
        $username=$email=$oldpivot=$pivot;
        $username =~ s/"UNAME//;
	$username =~ s/EMANU".*//;
	$email =~ s/.*,"EMAIL//;
	$email =~ s/LIAME".*//;
        $username = addRegExp($username);
	$email = addRegExp($email);

	@chars = split(" ",
	"a b c d e f g h i j k l m n o
	p q r s t u v w x y z
	0 1 2 3 4 5 6 7 8 9");

	srand;

	for ($i=0; $i<=8; $i++) 
	{
	    $_rand = int(rand 36);
	    $password .= $chars[$_rand];
    	}

	$passwd = md5_hex($password);
	chomp($password);
	$pivot =~ s/PASSWD.*DWSSAP/PASSWD${passwd}DWSSAP/;
	chomp($pivot);
   	@notuser = grep { !/$oldpivot/ } @usertable;

	deleteTableObject(\@notuser,$userfile);
	addTableObject($pivot,$userfile);

	mailUserPassword($username,$password,$email);
    }
}

sub mailUserPassword()
{
    # Mailer module - Uses an open call on sendmail to pipe user/pass to a 
    # given e-mail address.  Password is sent in cleartext.

    ($username,$password,$email)=@_;
    $sendmail = "${SENDMAIL} -t";
    chomp($email);
    chomp($username);
    chomp($password);

    open(MAIL, "|-", "$sendmail") || die "Can't make a sendmail pipe\n";
    print MAIL qq(To: ${email}\n);
    print MAIL qq(From: cowabunga@pauliesworld.org\n);
    print MAIL qq(Subject: Your password for the CWA scheduler\n);
    print MAIL qq(
This message is being sent as a reminder for your username and/or password into
the scheduling system.  For security purposes, your password has been randomly
reset.  It is recommended that you login immediately and change your password
to your liking using the Edit Account link located in the navigation bar on the
left side of the page.

Username: $username
Password: $password

~ CWA Scheduler ~
);
    close(MAIL);
}
