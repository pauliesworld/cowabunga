#!/usr/local/bin/perl

# COWAbunga -
# File: planner.pl
# Conference on World Affairs Scheduler
#   UI modules for the planner view
#   Status: STABLE

sub schedulePage()
{
    # Given a day and a year, display all panels matching all those parameters
    # using bettyTable.  Every object (day, time, people, places) is clickable
    # to their own individual pages.

    ($sid,$moder,$parti,$venue,$panel,$page,$t,$year,$day)=@_;

    @partitable=@$parti;
    @venuetable=@$venue;
    @modertable=@$moder;
    @paneltable=@$panel;

    if(!$day) { $day = "Monday"; }

    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Schedule - $day</h2>
<hr size="1" noshade>
<ul>
HTML
    
    if ($day =~ /Monday/)
    {
 	print "Monday -";
    }

    else
    {
	print " <a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&day=Monday\">Monday</a> -";
    }

    if ($day =~ /Tuesday/)
    {
        print " Tuesday -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&day=Tuesday\">Tuesday</a> -";
    }

    if ($day =~ /Wednesday/)
    {
        print " Wednesday -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&day=Wednesday\">Wednesday</a> -";
    }

    if ($day =~ /Thursday/)
    {
        print " Thursday -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&day=Thursday\">Thursday</a> -";
    }

    if ($day =~ /Friday/)
    {
        print " Friday";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&day=Friday\">Friday</a>";
    }

print (STDOUT <<HTML);
</ul>
<table cellpadding=0 cellspacing=0 border=0 class=bettyTable width="600">
    <th> $day Panel Details </th>
HTML
    chomp($day);
    @paneltable = grep { /,"DAY${day}YAD",/ } @paneltable;

    # Sort by session id
    @paneltable = sort sessionIDSort @paneltable;

    foreach $entry (@paneltable)
    {
        $altpartid=$partid=$day=$stime=$ftime=$sessinum=
	$prodid=$venueid=$moderid=$panelname=$entry;

        $panelname =~ s/"PANEL//;
        $panelname =~ s/LENAP",.*//;
	$panelname = addRegExp($panelname);
        $sessinum =~ s/.*,"SESID//;
	$sessinum =~ s/DISES",.*//;
        $venueid =~ s/.*"VENID//;
        $venueid =~ s/DINEV",.*//;
        $moderid =~ s/.*"MODID//;
        $moderid =~ s/DIDOM",.*//;
	$prodid =~ s/.*"PRODID//;
	$prodid =~ s/DIDORP",.*//;
	$day =~ s/.*"DAY//;
	$day =~ s/YAD",.*//;
	$stime =~ s/.*"STIME//;
	$stime =~ s/EMITS",.*//;
	$ftime =~ s/.*"FTIME//;
	$ftime =~ s/EMITF".*//;
	$calmagic = convertDaytoDate($day,$year);
	$sessinum=addRegExp($sessinum);

        @usertimetable=("None","8:00","8:30","9:00","9:30","10:00","10:30",
			"11:00","11:30","12:00","12:30","1:00","1:30","2:00",
			"2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00",
			"6:30","7:00","7:30","8:00","8:30","9:00","9:30","10:00");
        @fusertimetable=("None","7:50am","8:20am","8:50am","9:20am","9:50am",
			"10:20am","10:50am","11:20am","11:50am","12:20pm",
			"12:50pm","1:20pm","1:50pm","2:20pm","2:50pm","3:20pm",
			"3:50pm","4:20pm","4:50pm","5:20pm","5:50pm","6:20pm",
			"6:50pm","7:20pm","7:50pm","8:20pm","8:50pm","9:20pm",
			"9:50pm");
        @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
			"1130","1200","1230","1300","1330","1400","1430","1500",
			"1530","1600","1630","1700","1730","1800","1830","1900",
			"1930","2000","2030","2100","2130","2200");

	$stimecount=0;
	$ftimecount=0;

	foreach $time (@dbtimetable)
	{
	    if ($stime =~ m/$time/)
	    {
		$stime = $usertimetable[$stimecount];
	    }

	    if ($ftime =~ m/$time/)
	    {
		$ftime = $fusertimetable[$ftimecount];
	    }
	    $stimecount++;
	    $ftimecount++;
	}

	$partcount=0;

        while ($partid =~ /"PARTID/g) { $partcount++ }

        $partid =~ s/.*SETON","PARTID//;
        @part = split("DITRAP\",\"PARTID",$partid);
        $part[$partcount-1] =~ s/DITRAP"//;
        chomp($part[$partcount-1]);

        $localcount=0;

        foreach $mark (@part)
        {
            foreach $place (@partitable)
            {
                if($place =~ m/PARTID${mark}DITRAP/)
                {
                    $partfinal[$localcount]=$place;
                    $localcount++;
                }
            }
        }

        $altpartcount=0;

        while ($altpartid =~ /"ALTPID/g) { $altpartcount++ }

        $altpartid =~ s/.*DISES","ALTPID//;
        @altpart = split("DIPTLA\",\"ALTPID",$altpartid);
	chomp($altpart[$altpartcount-1]);
        $altpart[$altpartcount-1] =~ s/DIPTLA.*//g;

	$localcount=0;

        foreach $mark (@altpart)
        {
            foreach $place (@partitable)
            {
                if($place =~ m/PARTID${mark}DITRAP/)
                {
                    $altpartfinal[$localcount]=$place;
                    $localcount++;
                }
            }
        }

        # ok so we have all the ids and table entries
        # lets parse for the real values
        # $modgrep
        # $vengrep
        # @partfinal

	foreach $mark (@partfinal)
	{
	    chomp($mark);
	    $fname=$lname=$partid=$mark;
	    $fname =~ s/.*"FNAME//;
	    $fname =~ s/EMANF",.*//;
	    $lname =~ s/.*"LNAME//;
	    $lname =~ s/EMANL",.*//;
	    $partid =~ s/.*"PARTID//;
	    $partid =~ s/DITRAP".*//;
            $lname=addRegExp($lname);
            $fname=addRegExp($fname);	    
	    $mark = "$fname $lname";
	    chomp($mark);
	    $mark="<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$partid&y=$year>$mark</a>";
	}

        foreach $mark (@altpartfinal)
        {
	    chomp($mark);
            $fname=$lname=$partid=$mark;
            $fname =~ s/.*"FNAME//;
            $fname =~ s/EMANF",.*//;
            $lname =~ s/.*"LNAME//;
            $lname =~ s/EMANL",.*//;
	    $partid =~ s/.*"PARTID//;
	    $partid =~ s/DITRAP".*//;
            $lname=addRegExp($lname);
            $fname=addRegExp($fname);
            $mark = "$fname $lname";
            chomp($mark);
	    $mark="<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$partid&y=$year>$mark</a>";
        }

	chomp($venueid);

        foreach $mark (@venuetable)
	{
	    if ($mark =~ m/VENID${venueid}DINEV/)
	    {
		$venloc=$venid=$mark;
		$venloc =~ s/"VENLOC//;
		$venloc =~ s/COLNEV",.*//;
		$venloc=addRegExp($venloc);
		$venloc="<a href=cwasys.pl?sid=$sid&pid=readonly&object=venue&venid=$venueid&y=$year>$venloc</a>"
	    }
	}

	foreach $mark (@modertable)
	{
	    chomp($moderid);
	    if ($mark =~ m/MODID${moderid}DIDOM/)
	    {
		$fname=$lname=$mark;
	   	$fname =~ s/.*"FNAME//;
		$fname =~ s/EMANF",.*//;
		$lname =~ s/.*"LNAME//;
		$lname =~ s/EMANL",.*//;
                $lname=addRegExp($lname);
                $fname=addRegExp($fname);
		$modername="$fname $lname";
		chomp($modername);
		$modername="<a href=cwasys.pl?sid=$sid&pid=readonly&object=moderator&modid=$moderid&y=$year>$modername</a>"
	    }
	}

        foreach $mark (@produtable)
        {
            chomp($prodid);
            if ($mark =~ m/PRODID${prodid}DIDORP/)
            {
                $fname=$lname=$mark;
                $fname =~ s/.*"FNAME//;
                $fname =~ s/EMANF",.*//;
                $lname =~ s/.*"LNAME//;
                $lname =~ s/EMANL",.*//;
            	$lname=addRegExp($lname);
            	$fname=addRegExp($fname);
                $prodname="$fname $lname";
                chomp($prodname);
		$prodname="<a href=cwasys.pl?sid=$sid&pid=readonly&object=producer&prodid=$prodid&y=$year>$prodname</a>"
            }
        } 

        # Hooray, finished parsing... lets display results
        print(STDOUT <<HTML);
        <tr><td>
<b class="smtitle"><b>$sessinum $panelname</b></b>
<ul>
        $stime-$ftime on <a href="cwasys.pl?sid=$sid&pid=schedule&y=$year&day=$day">$day $calmagic</a><br>
        $venloc<br><br>
        <b>Panelists:</b>

        <ul>
HTML
    foreach $person (@partfinal)
    {
	print "<li>$person</li>";
    }

    if (@altpartfinal)
    {
        foreach $person (@altpartfinal)
        {
	    print "<li><i>$person</i></li>";
        }
    }

    print "<br>";

    @partfinal=();
    @altpartfinal=();

    print "\n<br>\n";

    if($modername)
    {
	print "<li><b>Moderator:</b> $modername</li>\n";
    }

    if($prodname)
    {
	print "<li><b>Producer:</b> $prodname</li>\n";
    }
  
    print (STDOUT <<HTML);
        </ul>
</ul>
</td></tr>
HTML
    }
print(STDOUT <<HTML);
</ul>
</table>
</div>
HTML
}

sub participantPage()
{
    ($sid,$partifile,$page,$t,$year)=@_;
    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Participants</h2>
<hr size="1" noshade>
HTML
    
    @partitable= sort {lc $a cmp lc $b} @partitable;
    $sizeofparti=@partitable;
    
    $colsize = ($sizeofparti/3);
    $colsize = roundUp($colsize);
    print "<br><table cellpadding=0 cellspacing=0 border=0 width=\"700\"><tr>
	<td valign=top>";

    foreach $entry (@partitable)
    {
        chomp($entry);
        $fname=$lname=$userid=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
	$userid =~ s/.*,"PARTID//;
	$userid =~ s/DITRAP",.*//;
	$lname=addRegExp($lname);
	$fname=addRegExp($fname);
	   
	$grepit = grep { /PARTID${userid}DITRAP"/ } @paneltable;
	if($grepit)
	{
	    if ($fname && $lname)
	    {
            	print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=participant
		&partid=$userid&y=$year\"><font face=verdana size=2><b>
		$lname, $fname</b></font></a> ($grepit)<br>\n";
	    }

	    else
            {
                print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=participant
                &partid=$userid&y=$year\"><font face=verdana size=2><b>
                $fname $lname</b></font></a> ($grepit)<br>\n";
            }
	}

	else
	{
	    print "<font color=#000000 face=verdana size=2><b>$fname $lname</b>
		</font><br>\n";	
	}
	    $tablecount++;

	if ($tablecount == $colsize)
	{
	    print "</td><td valign=top>";
	    $tablecount=0;
	}
    }

    print "</td></tr></table><br><br>";
    print(STDOUT <<HTML);
</div>
HTML
}

sub producerPage()
{
    ($sid,$partifile,$page,$t,$year)=@_;
    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Producers</h2>
<hr size="1" noshade>
HTML

    @produtable=sort {lc $a cmp lc $b} @produtable;
    $sizeofprodu=@produtable;
    $colsize = ($sizeofprodu/3);
    $colsize = roundUp($colsize);
    print "<br><table cellpadding=0 cellspacing=0 border=0 width=\"700\"><tr>
	<td valign=top>";

    foreach $entry (@produtable)
    {
        chomp($entry);
        $fname=$lname=$userid=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $userid =~ s/.*,"PRODID//;
        $userid =~ s/DIDORP",.*//;
        $lname=addRegExp($lname);
        $fname=addRegExp($fname);

        $grepit = grep { /PRODID${userid}DIDORP"/ } @paneltable;
        if($grepit)
        {
	    if ($fname && $lname)
	    {
            	print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=producer&
		prodid=$userid&y=$year\"><font face=verdana size=2><b>
		$lname, $fname</b></font></a> ($grepit)<br>\n";
	    }

	    else
            {
                print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=producer&
                prodid=$userid&y=$year\"><font face=verdana size=2><b>
                $fname $lname</b></font></a> ($grepit)<br>\n";
            }
        }

        else
        {
            print "<font color=#000000 face=verdana size=2><b>$fname $lname
		</b></font><br>\n";
        }

        $tablecount++;

        if ($tablecount == $colsize)
        {
            print "</td><td valign=top>";
            $tablecount=0;
        }
        $index++;
    }

    print "</td></tr></table>";
    print(STDOUT <<HTML);
</div>
HTML
}

sub moderatorPage()
{
    ($sid,$moderfile,$page,$t,$year)=@_;
    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Moderators</h2>
<hr size="1" noshade>
HTML

    @modertable=sort {lc $a cmp lc $b} @modertable;
    $sizeofmoder=@modertable;
    $colsize = ($sizeofmoder/3);
    $colsize = roundUp($colsize);
    print "<br><table cellpadding=0 cellspacing=0 border=0 width=\"700\">
	<tr><td valign=top>";

    foreach $entry (@modertable)
    {
        chomp($entry);
        $fname=$lname=$userid=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $userid =~ s/.*,"MODID//;
        $userid =~ s/DIDOM",.*//;
        $lname=addRegExp($lname);
        $fname=addRegExp($fname);

        $grepit = grep { /MODID${userid}DIDOM"/ } @paneltable;
        if($grepit)
        {
	    if ($lname && $fname)
	    {
            	print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=moderator&
		modid=$userid&y=$year\"><font face=verdana size=2><b>
		$lname, $fname</b></font></a> ($grepit)<br>\n";
	    }

	    else
	    {
                print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=moderator&
                modid=$userid&y=$year\"><font face=verdana size=2><b>
                $fname $lname</b></font></a> ($grepit)<br>\n";
	    }
        }

        else
        {
            print "<font color=#000000 face=verdana size=2><b>$fname $lname</b>
		</font><br>\n";
        }

        $tablecount++;

        if ($tablecount == $colsize)
        {
            print "</td><td valign=top>";
            $tablecount=0;
        }
    }

    print "</td></tr></table>";
    print(STDOUT <<HTML);
</div>
HTML
}

sub venuePage()
{
    ($sid,$venuefile,$page,$t,$year)=@_;
    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Venues</h2>
<hr size="1" noshade>
HTML

    @venuetable= sort {lc $a cmp lc $b} @venuetable;
    $sizeofvenue=@venuetable;
    $colsize = ($sizeofvenue/3);
    $colsize = roundUp($colsize);
    print "<br><table cellpadding=0 cellspacing=0 border=0 width=\"700\">
	<tr><td valign=top>";

    foreach $entry (@venuetable)
    {
        chomp($entry);
        $venloc=$userid=$entry;
        $venloc =~ s/"VENLOC//;
        $venloc =~ s/COLNEV",.*//;
        $userid =~ s/.*,"VENID//;
        $userid =~ s/DINEV",.*//;
        $venloc=addRegExp($venloc);
        
	$grepit = grep { /VENID${userid}DINEV"/ } @paneltable;
        if($grepit)
        {
            print "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=venue&
		venid=$userid&y=$year\"><font face=verdana size=2><b>
		$venloc</b></font></a> ($grepit)<br>\n";
        }

        else
        {
            print "<font color=#000000 face=verdana size=2><b>$venloc</b></font><br>\n";
        }

        $tablecount++;

        if ($tablecount == $colsize)
        {
            print "</td><td valign=top>";
            $tablecount=0;
        }
    }

    print "</td></tr></table>";
    print(STDOUT <<HTML);
</div>
HTML
}

sub userPlannerPage()
{
    # Participants, producers, moderators, and venues all have the same 
    # requirements for a planner page, so they share relatively the same code.
    # This allows things to be more adaptable to change.
    
    ($sid,$this,$panelid,$partid,$prodid,$modid,$venid,$year)=@_;

    if ($this =~ m/participant/)
    {
        @participant=grep { /PARTID${partid}DITRAP/ } @partitable;
    	$participant=join('',@participant);
    	$fname=$lname=$participant;
    	$fname =~ s/.*,"FNAME//;
    	$fname =~ s/EMANF",.*//;
    	$lname =~ s/"LNAME//;
    	$lname =~ s/EMANL",.*//;
	$fname=addRegExp($fname);
	$lname=addRegExp($lname);
    	$objectname = "$fname $lname";
    	@local_panels = grep { /,"PARTID${partid}DITRAP"/ } @paneltable;
	$title = "Panels that $objectname is participating in";
    }

    elsif ($this =~ m/producer/)
    {
        chomp($prodid);
        @producer=grep { /PRODID${prodid}DIDORP/ } @produtable;
        $producer=join('',@producer);
        $fname=$lname=$producer;
        $fname =~ s/.*,"FNAME//;
        $fname =~ s/EMANF",.*//;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL",.*//;
        $fname=addRegExp($fname);
        $lname=addRegExp($lname);
        $objectname = "$fname $lname";
        @local_panels = grep { /,"PRODID${prodid}DIDORP"/ } @paneltable;
        $title = "Panels that $objectname is producing";
    }

    elsif ($this =~ m/moderator/)
    {
       	chomp($modid);
       	@moderator=grep { /MODID${modid}DIDOM/ } @modertable;
       	$moderator=join('',@moderator);
       	$fname=$lname=$moderator;
       	$fname =~ s/.*,"FNAME//;
       	$fname =~ s/EMANF",.*//;
       	$lname =~ s/"LNAME//;
       	$lname =~ s/EMANL",.*//;
   	$fname=addRegExp($fname);
      	$lname=addRegExp($lname);
      	$objectname = "$fname $lname";
      	@local_panels = grep { /,"MODID${modid}DIDOM"/ } @paneltable;
	$title = "Panels that $objectname is moderating";
    }

    elsif ($this =~ m/venue/)
    {
    	chomp($venid);
    	@venue=grep { /VENID${venid}DINEV/ } @venuetable;
    	$venue=join('',@venue);
    	$venue =~ s/.*"VENLOC//;
    	$venue =~ s/COLNEV",.*//;
  	$venue=addRegExp($venue);
   	$objectname = $venue;
   	@local_panels = grep { /"VENID${venid}DINEV"/ } @paneltable;
   	$title = "Panels held at $objectname";
    }

    $objectname = addRegExp($objectname);
    @this_panel = sort sessionIDSort @local_panels;
    $objecttitle = $this;
    $objecttitle =~ s/\b(\w)/\U$1/;

    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Schedule for $objecttitle $objectname</h2>
<hr size="1" noshade>
<table cellpadding=0 cellspacing=0 border=0 class=bettyTable width="600">
    <th> $title </th>
HTML
    $amountofpanels=@this_panel;
    foreach $entry (@this_panel)
    {
        $partid=$day=$stime=$ftime=$sessinum=$prodid=
	$venueid=$moderid=$panelname=$entry;
        $panelname =~ s/"PANEL//;
        $panelname =~ s/LENAP",.*//;
        $sessinum =~ s/.*,"SESID//;
        $sessinum =~ s/DISES",.*//;
        $day =~ s/.*"DAY//;
        $day =~ s/YAD",.*//;
        $stime =~ s/.*"STIME//;
        $stime =~ s/EMITS",.*//;
        $ftime =~ s/.*"FTIME//;
        $ftime =~ s/EMITF".*//;
        $venueid =~ s/.*"VENID//;
        $venueid =~ s/DINEV",.*//;
        $calmagic = convertDaytoDate($day,$year);
	$panelname=addRegExp($panelname);
        $sessinum=addRegExp($sessinum);

        @usertimetable=("None","8:00","8:30","9:00","9:30","10:00","10:30",
                        "11:00","11:30","12:00","12:30","1:00","1:30","2:00",
                        "2:30","3:00","3:30","4:00","4:30","5:00","5:30","6:00",
                        "6:30","7:00","7:30","8:00","8:30","9:00","9:30",
			"10:00");
        @fusertimetable=("None","7:50am","8:20am","8:50am","9:20am","9:50am",
                        "10:20am","10:50am","11:20am","11:50am","12:20pm",
                        "12:50pm","1:20pm","1:50pm","2:20pm","2:50pm","3:20pm",
                        "3:50pm","4:20pm","4:50pm","5:20pm","5:50pm","6:20pm",
                        "6:50pm","7:20pm","7:50pm","8:20pm","8:50pm","9:20pm",
                        "9:50pm");
        @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
                        "1130","1200","1230","1300","1330","1400","1430","1500",
                        "1530","1600","1630","1700","1730","1800","1830","1900",
                        "1930","2000","2030","2100","2130","2200");

        $stimecount=0;
        $ftimecount=0;

        foreach $time (@dbtimetable)
        {
            if ($stime =~ m/$time/)
            {
                $stime = $usertimetable[$stimecount];
            }

            if ($ftime =~ m/$time/)
            {
                $ftime = $fusertimetable[$ftimecount];
            }
            $stimecount++;
            $ftimecount++;
        }

        chomp($venueid);

        foreach $mark (@venuetable)
        {
            if ($mark =~ m/VENID${venueid}DINEV/)
            {
                $venloc=$venid=$mark;
                $venloc =~ s/"VENLOC//;
                $venloc =~ s/COLNEV",.*//;
		$venid =~ s/.*,"VENID//;
		$venid =~ s/DINEV",.*//;
                $venloc=addRegExp($venloc);
		$venloc = "<a href=\"cwasys.pl?sid=$sid&pid=readonly&object=venue&venid=$venid&y=$year\">$venloc</a>";
            }
        }

        $partcount=0;

        while ($partid =~ /"PARTID/g) { $partcount++ }

        $partid =~ s/.*SETON","PARTID//;
        @part = split("DITRAP\",\"PARTID",$partid);
        $part[$partcount-1] =~ s/DITRAP"//;
        chomp($part[$partcount-1]);

        $localcount=0;

        foreach $mark (@part)
        {
            foreach $place (@partitable)
            {
                if($place =~ m/PARTID${mark}DITRAP/)
                {
                    $partfinal[$localcount]=$place;
                    $localcount++;
                }
            }
        }

	if ($venloc !~ m/[a-zA-Z0-9]/) 
	{ 
	    $venloc="TBD*"; 
	    $tbdwarning="*TBD To be determined at a later date";
	}

        $partcount=0;
        $localcount=0;

        print(STDOUT <<HTML);
<tr><td><ul>
<b class="smtitle">$sessinum $panelname</b><br>
        $stime-$ftime on <a href="cwasys.pl?sid=$sid&pid=schedule&y=$year&day=$day">$day $calmagic</a> located in $venloc<br></ul><ul>
HTML
        foreach $mark (@partfinal)
        {
	    chomp($mark);
            $partid=$fname=$lname=$mark;
            $fname =~ s/.*"FNAME//;
            $fname =~ s/EMANF",.*//;
            $lname =~ s/.*"LNAME//;
            $lname =~ s/EMANL",.*//;
	    $partid =~ s/.*,"PARTID//;
	    $partid =~ s/DITRAP",.*//;
            $fname = addRegExp($fname);
            $lname = addRegExp($lname);
            print "<li><a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$partid&y=$year>$fname $lname</a></li>";
        }

	@partfinal = ();
	@part = ();

	print (STDOUT <<HTML);
</ul></td></tr>
HTML

    }

    if ($amountofpanels == 0)
    {
	print "<tr><td><ul>No scheduled panels</ul></td></tr>";
    }
print(STDOUT <<HTML);
</ul>
</table>
<br><br><br>
<font><i>$tbdwarning</i></font>
</div>
HTML

}

sub sessionIDSort
{
    ($field1a,$field2a)=split(/"SESID/, $a);
    ($field1b,$field2b)=split(/"SESID/, $b);

    $field2a cmp $field2b;
}

1;
