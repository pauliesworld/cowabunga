#!/usr/local/bin/perl

# COWAbunga -
# File: boxes.pl 
# Conference on World Affairs Scheduler
#   This file contains HTML drop down boxes to utilize with forms
#   Status: STABLE

sub createConferencePopupBox()
{
    ($DBDIRECTORY,$conference,$form)=@_;

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select class=textfield name=cpbox size=20 $form>\n";

    ($yearname,$yearid)=getAllYears($DBDIRECTORY,$conference);
    @yearname = @$yearname;
    @yearid = @$yearid;

    $yearcount=0;
    foreach $entry (@yearname)
    {
        if ($entry =~ m/$yearname/)
        {
            $sel="selected";
        }
        print "<option value=\"$yearid[$yearcount]\" $sel>$entry</option>";
        $sel="";
        $yearcount++;
    }

    print "</select>";	
}

sub createUserPopupBox()
{
    ($ref,$sizenum,$form) = @_;
    @usertable = @$ref;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select class=textfield name=upbox size=$sizenum $form>\n";
    @usertable = sort {lc $a cmp lc $b} @usertable;

    foreach $entry (@usertable)
    {
        $entry =~ s/\n//;
        $tableid=$username=$entry;
        $username =~ s/"UNAME//;
        $username =~ s/EMANU".*//;
        $tableid =~ s/.*,"USERID//;
        $tableid =~ s/DIRESU",.*//g;
        $username = addRegExp($username);
        print "\t<option value=\"${tableid}\">$username</option><br>\n";
    }
    print "</select>";
}

sub createModeratorPopupBox()
{
    ($moder,$sizenum,$form) = @_;
    @modertable = @$moder;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
	$form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select id=mpbox class=textfield name=mpbox size=$sizenum $form>\n";
    @modertable = sort {lc $a cmp lc $b} @modertable;

    foreach $entry (@modertable)
    {
        $entry =~ s/\n//;
        $tableid=$fname=$lname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $tableid =~ s/"LNAME${lname}EMANL","FNAME${fname}EMANF","//;
        $tableid =~ s/MODID//;
        $tableid =~ s/DIDOM.*//g;
        $fname = addRegExp($fname);
        $lname = addRegExp($lname);
	
	if ($lname && $fname)
	{
            print "\t<option value=\"${tableid}\">$lname, $fname</option><br>\n";
	}

	else
	{
	    print "\t<option value=\"${tableid}\">$fname $lname</option><br>\n";
	}
    }
    print "</select>";
}

sub createParticipantPopupBox()
{
    ($parti,$sizenum,$form) = @_;
    @partitable = @$parti;

    if(!$sizenum)
    {
	$sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select id=ppbox class=textfield name=ppbox size=$sizenum $form>\n";
    @partitable = sort {lc $a cmp lc $b} @partitable;

    foreach $entry (@partitable)
    {
        $entry =~ s/\n//;
	$entry =~ s/"Y[0-9]*Y"//;
        $tableid=$fname=$lname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
	$tableid =~ s/"LNAME${lname}EMANL","FNAME${fname}EMANF","//;
	$tableid =~ s/PARTID//;
	$tableid =~ s/DITRAP.*//g;
        $fname = addRegExp($fname);
        $lname = addRegExp($lname);

        if ($lname && $fname)
        {
            print "\t<option value=\"${tableid}\">$lname, $fname</option><br>\n";
        }

        else
        {
            print "\t<option value=\"${tableid}\">$fname $lname</option><br>\n";
        }
    }
    print "</select>";
}

sub createProducerPopupBox()
{
    ($produ,$sizenum,$form) = @_;
    @produtable = @$produ;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select id=pubox class=textfield name=pubox size=$sizenum $form>\n";
    @produtable = sort {lc $a cmp lc $b} @produtable;

    foreach $pro (@produtable)
    {
        $pro =~ s/\n//;
        $tableid=$fname=$lname=$pro;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $tableid =~ s/"LNAME${lname}EMANL","FNAME${fname}EMANF","//;
        $tableid =~ s/PRODID//;
        $tableid =~ s/DIDORP.*//g;
        $fname = addRegExp($fname);
        $lname = addRegExp($lname);

        if ($lname && $fname)
        {
            print "\t<option value=\"${tableid}\">$lname, $fname</option><br>\n";
        }

        else
        {
            print "\t<option value=\"${tableid}\">$fname $lname</option><br>\n";
        }
    }

    print "</select>";
}

sub createVenuePopupBox()
{
    ($venue,$sizenum,$form) = @_;
    @venuetable = @$venue;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select id=vpbox class=textfield name=vpbox size=$sizenum $form>\n";
    @venuetable = sort {lc $a cmp lc $b} @venuetable;

    foreach $entry (@venuetable)
    {
        $entry =~ s/\n//;
        $entry =~ s/"Y[0-9]*Y"//;
        $tableid=$loc=$space=$entry;
        $loc =~ s/"VENLOC//;
        $loc =~ s/COLNEV".*//;
        $space =~ s/"VENLOC${loc}COLNEV","SPACE//;
        $space =~ s/ECAPS".*//;
        $tableid =~ s/"VENLOC${loc}COLNEV","SPACE${space}ECAPS","//;
        $tableid =~ s/VENID//;
        $tableid =~ s/DINEV.*//g;
	$loc = addRegExp($loc);
	$space = addRegExp($space);
	print "\t<option value=\"${tableid}\">$loc</option><br>\n";
    }
    print "</select>";
}

sub createPanelPopupBox()
{
    ($panel,$sizenum,$form) = @_;
    @paneltable = @$panel;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    @paneltable = sort {lc $a cmp lc $b} @paneltable;
    print "\n<select id=panbox style=\"width:370\" class=textfield name=panbox size=$sizenum $form>\n";

    foreach $entry (@paneltable)
    {
        $entry =~ s/\n//;
        $tableid=$name=$entry;
        $name =~ s/"PANEL//;
        $name =~ s/LENAP".*//;
        $tableid =~ s/.*,"PANID//;
        $tableid =~ s/DINAP".*//g;
        $name = addRegExp($name);
	print "\t<option value=\"${tableid}\">$name</option><br>\n";
    }

    print "</select>";
}

sub createTagPopupBox()
{
    ($tag,$sizenum,$form) = @_;
    @tagtable = @$tag;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    if($form)
    {
        $form = "ondblclick=\"document.$form.submit();\"";
    }

    print "\n<select class=textfield name=tagbox size=$sizenum $form>\n";
    @tagtable = sort {lc $a cmp lc $b} @tagtable;

    foreach $entry (@tagtable)
    {
        $entry =~ s/\n//;
        $tableid=$name=$entry;
        $name =~ s/"TAGNAME//;
        $name =~ s/EMANGAT".*//;
        $tableid =~ s/.*,"TAGID//;
        $tableid =~ s/DIGAT".*//g;
        $name = addRegExp($name);
        print "\t<option value=\"${tableid}\">$name</option><br>\n";
    }
    print "</select>";
}

sub createSnapshotPopupBox()
{
    ($DBDIRECTORY,$sizenum) = @_;

    if(!$sizenum)
    {
        $sizenum=20;
    }

    @snapshots = `${LS} -1 ${DBDIRECTORY}snapshots`;
    @snapshots = reverse(@snapshots);

    print "\n<select class=textfield name=snapshot size=$sizenum>\n";
    foreach $entry (@snapshots)
    {
	$entry =~ s/\.zip.gz//;
	chomp($entry);
	$time = localtime($entry);
	print "\t<option value=\"$entry\">$time</option><br>\n";
    }
    print "</select>";
}

1;
