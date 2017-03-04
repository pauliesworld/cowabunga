#!/usr/local/bin/perl

# COWAbunga -
# File: schedule.pl
# Conference on World Affairs Scheduler
#   This file contains the primary algorithm to check scheduling within
#   the text database.
#   Status: STABLE

sub createEditScheduleBox()
{
    # Build a participant availability schedule page that has open checkboxes
    # for times available, checked check boxes for times that have been manually
    # marked unavailable, and disabled checkboxes that say that a panel has
    # been scheduled during that time.

    ($parti,$pavailfile,$day,$year,$start,$max,$page,$indarray) = @_;

    $pavailfile = "${pavailfile}${day}.db";
    @partitable = @$parti;
    @indarray = @$indarray;
    @partitable = sort {lc $a cmp lc $b} @partitable;

    open(IN,"<",$pavailfile);
    @partavail = <IN>;
    close IN;

    print (STDOUT <<HTML);
<link href="${URLCSS}COWA.css" rel="stylesheet" type="text/css">
<script src="${URLJS}floater.js" language="JavaScript" type="text/javascript"></script>
HTML
    print "<form action=\"avail\" name=\"selectTimes\" method=\"POST\">\n";
    print "<input type=hidden name=scheduleedit value=participant>\n";
    print "<input type=hidden name=day value=$day>\n";
    print "<input type=hidden name=y value=$year>\n";
    print "<input type=hidden name=start value=$start>\n";
    print "<input type=hidden name=max value=$max>\n";
    print "<input type=hidden name=page value=$page>\n";
    print "<input type=hidden name=sid value=$sid>\n";
    
    $index+=0;
    $size = @indarray;

    if ($size)
    {
	$addselected = "checked";
    }

    $thcount=1;
    @ctimearray=("08:00","09:00","10:00","11:00","12:00","01:00","02:00",
		"03:00","04:00","05:00","06:00","07:00");
    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
		  "1130","1200","1230","1300","1330","1400","1430","1500",
		  "1530","1600","1630","1700","1730","1800","1830","1900",
		  "1930");

    foreach $entry (@partitable)
    {
        if((($index >= $start) && ($index <= $max)) || 
		grep(/\b$index\b/,@indarray))
        {
	    $entry =~ s/\n//;
            $entry =~ s/"Y[0-9]*Y"//;
            $tableid=$fname=$lname=$entry;
            $lname =~ s/"LNAME//;
            $lname =~ s/EMANL".*//;
            $fname =~ s/"LNAME${lname}EMANL","FNAME//;
            $fname =~ s/EMANF".*//;
            $tableid =~ s/.*,"PARTID//;
            $tableid =~ s/DITRAP",.*//;
	    $lname = addRegExp($lname);
	    $fname = addRegExp($fname);

	    print (STDOUT <<HTML);
		<tr onMouseover="this.style.background='#dfffff';" onMouseout="this.style.background='#FFFFFF';">
    		    <script language="JavaScript">
        		function Open(URL) 
        		{
            		    day = new Date();
            		    id = day.getTime();
            		    eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=1,width=475,height=225,left = 540,top = 425');");
        		}
    		    </script>
			<td><input class=\"noprint\" type='checkbox' id='CHECKOUT$index' $addselected></td>
			<td width="300" height="10">
			&nbsp <a href="javascript:Open('notes?sid=$sid&pid=participant&partid=$tableid&y=$year')">$lname, $fname</a>
			</td>
HTML

	    @timearray=("0800","0900","1000","1100",
		    	"1200","1300","1400","1500",
	    	    	"1600","1700","1800","1900");
	
		print "<script language=\"JavaScript\">\n";
		print "function select${tableid}${day}()\n";
		print "{\n";

	# Build the 'select all times' to make an entire row of checkboxes
	# checked or uncheck based on the selection of the final checkbox.
	# While times extend to 10:00pm, we only list up to 7:30pm since 99%
	# of panels end before this (only Jazz goes to 10pm).  This saves a ton
	# of space.

		print(STDOUT <<HTML);
    var frm${tableid}${day} = document.selectTimes;
    var status${tableid}${day} = frm${tableid}${day}.checkStatus${tableid}${day}.value;
    var checkIt${tableid}${day};

    if (status${tableid}${day} == 0)
    {
        checkIt${tableid}${day} = true;
        status${tableid}${day} = 1;
    }
        else if (status${tableid}${day} == 1)
        {
            checkIt${tableid}${day} = false;
            status${tableid}${day} = 0;
        }
HTML
    		foreach $time (@dbtimetable)
    		{
        	    print "var newField${tableid}${day} = 
			('USERID${tableid}DIRESU,DAY${day}YAD,TIME${time}EMIT');
			";
        	    print "var objIt${tableid}${day} = 
			frm${tableid}${day}.elements[newField${tableid}${day}];
			";
        	    print "if (objIt${tableid}${day}) { 
			objIt${tableid}${day}.checked = 
			checkIt${tableid}${day}; }\n";
    		}

    		print "frm${tableid}${day}.checkStatus${tableid}${day}.value =
			 status${tableid}${day};}\n";
    		print "</script>";

            foreach $time (@timearray)
            {
	        $fullhour=$time;
	    	$fullhour+=0;
	    	$halfhour=$fullhour+30;

	    	if ($halfhour =~ m/(^8)|(^9)/)
	    	{
		    $halfhour =~ s/8/08/;
		    $halfhour =~ s/9/09/;
	        }

		$slot = "\"USERID${tableid}DIRESU\",
			\"DAY${day}YAD\"";
	    	$slot1 = "\"USERID${tableid}DIRESU\",
			\"DAY${day}YAD\",
			\"TIME${time}EMIT\"";
	    	$slot2 = "\"USERID${tableid}DIRESU\",
			\"DAY${day}YAD\",
			\"TIME${halfhour}EMIT\"";

		$slot3 = "${slot1},\"DISABLED\"";
		$slot4 = "${slot2},\"DISABLED\"";
		chomp($slot4);
		chomp($slot3);
		$slot =~ s/\t|\n//g;
		$slot1 =~ s/\t|\n//g;
		$slot2 =~ s/\t|\n//g;

		@grep = grep { /$slot/ } @partavail;
		$grep = join('',@grep);

		# Mark off in HTML whether or not the time is available

		if ($grep =~ m/TIME${time}EMIT/) 
		{ 
		    $timecheck = "checked"; 
		}

		if ($grep =~ m/TIME${halfhour}EMIT/) 
		{ 
		    $halfcheck = "checked"; 
		}

		if ($grep =~ m/TIME${time}EMIT","DISABLED/) 
		{ 
		    $timedis = "disabled"; 
		    $floater=1;
		}

		if ($grep =~ m/TIME${halfhour}EMIT","DISABLED/) 
		{ 
		    $halfdis = "disabled"; 
		    $floater=1;
		}

		print(STDOUT <<HTML);
			<td width="60" height="10">
HTML
		print(STDOUT <<HTML);
			    <input type="checkbox" name="USERID${tableid}DIRESU,DAY${day}YAD,TIME${time}EMIT" $timecheck $timedis>
			    <input type="checkbox" name="USERID${tableid}DIRESU,DAY${day}YAD,TIME${halfhour}EMIT" $halfcheck $halfdis>
HTML
		print "</td>";
	    	$timecheck="";
	    	$halfcheck="";
		$timedis="";
		$halfdis="";
            }
	print "<td class=\"noprint\" width=\"60\" height=\"10\">
		<input type=\"checkbox\" onClick=\"select${tableid}${day}();\">
		</td>";
        print "<input type=\"hidden\" name=\"checkStatus${tableid}${day}\" 
		value=\"0\">";
	}
	$index++;
        print "</tr>";

	if ($thcount == 10 && !@indarray)
	{
	    print "<tr><th class=\"noprint\" width=\"30\" height=\"10\">Add</th>
		<th width=\"50\" height=\"10\">Participants ";
	    print "<input class=\"noprint\" type=\"button\" value=\"End\" onClick=\"End()\">";

    	    foreach $index (@ctimearray)
    	    {
        	print "<th width=\"50\" height=\"10\">";
        	print "$index";
        	print "</th>";
    	    }

	    print "<th class=\"noprint\">All</th></tr>";
	    $thcount=0;
	}
	$thcount++;
    }
}

sub createEditVenueBox()
{
    # Build a venue availability schedule page that has open checkboxes for 
    # times available, checked check boxes for times that have been manually
    # marked unavailable, and disabled checkboxes that say that a panel has
    # been scheduled during that time.

    ($venue,$vavailfile,$day,$year,$start,$max,$page) = @_;
    $vavailfile = "${vavailfile}${day}.db";
    @venuetable = @$venue;
    @venuetable = sort {lc $a cmp lc $b} @venuetable;

    open(IN,"<",$vavailfile);
    @venavail = <IN>;
    close IN;

    print "<form action=\"avail\" name=\"selectTimes\" method=\"POST\">\n";
    print "<input type=hidden name=scheduleedit value=venue>\n";
    print "<input type=hidden name=day value=$day>\n";
    print "<input type=hidden name=y value=$year>\n";
    print "<input type=hidden name=start value=$start>\n";
    print "<input type=hidden name=max value=$max>\n";
    print "<input type=hidden name=page value=$page>\n";
    print "<input type=hidden name=sid value=$sid>\n";
 
    $index+=0;
    $size = @indarray;

    if ($size)
    {
        $addselected = "checked";
    }

    $thcount=1;
    @ctimearray=("08:00","09:00","10:00","11:00","12:00","01:00","02:00",
                "03:00","04:00","05:00","06:00","07:00");
    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
                  "1130","1200","1230","1300","1330","1400","1430","1500",
                  "1600","1630","1700","1730","1800","1830","1900","1930");

    foreach $entry (@venuetable)
    {
        if(($index >= $start) && ($index <= $max))
        {
            $entry =~ s/\n//;
            $entry =~ s/"Y[0-9]*Y"//;
            $tableid=$loc=$entry;
            $loc =~ s/"VENLOC//;
            $loc =~ s/COLNEV".*//;
            $tableid =~ s/.*,"VENID//;
            $tableid =~ s/DINEV",.*//;
            $loc = addRegExp($loc);

            print (STDOUT <<HTML);
                <tr onMouseover="this.style.background='#dfffff';" onMouseout="this.style.background='#FFFFFF';">
                    <script language="JavaScript">
                        function Open(URL)
                        {
                            day = new Date();
                            id = day.getTime();
                            eval("page" + id + " = window.open(URL, '" + id + "','toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=1,width=475,height=225,left = 540,top = 425');");
                        }
                    </script>
                        <td width="300" height="10">
                        &nbsp <a href="javascript:Open('notes?sid=$sid&pid=venue&venid=$tableid&y=$year')">$loc</a>
                        </td>
HTML

            @timearray=("0800","0900","1000","1100",
                        "1200","1300","1400","1500",
                        "1600","1700","1800","1900");

                print "<script language=\"JavaScript\">\n";
                print "function select${tableid}${day}()\n";
                print "{\n";
                print(STDOUT <<HTML);

        # Build the 'select all times' to make an entire row of checkboxes
        # checked or uncheck based on the selection of the final checkbox.
        # While times extend to 10:00pm, we only list up to 7:30pm since 99%
        # of panels end before this (only Jazz goes to 10pm).  This saves a ton
        # of space.

    var frm${tableid}${day} = document.selectTimes;
    var status${tableid}${day} = frm${tableid}${day}.checkStatus${tableid}${day}.value;
    var checkIt${tableid}${day};

    if (status${tableid}${day} == 0)
    {
        checkIt${tableid}${day} = true;
        status${tableid}${day} = 1;
    }
        else if (status${tableid}${day} == 1)
        {
            checkIt${tableid}${day} = false;
            status${tableid}${day} = 0;
        }
HTML
                foreach $time (@dbtimetable)
                {
                    print "var newField${tableid}${day} = 
			('USERID${tableid}DIRESU,DAY${day}YAD,TIME${time}EMIT');
			";
                    print "var objIt${tableid}${day} = 
			frm${tableid}${day}.elements[newField${tableid}${day}];"
			;
                    print "if (objIt${tableid}${day}) { 
			objIt${tableid}${day}.checked = 
			checkIt${tableid}${day}; }\n";
                }

                print "frm${tableid}${day}.checkStatus${tableid}${day}.value = 
			status${tableid}${day};}\n";
                print "</script>";

            foreach $time (@timearray)
            {
                $fullhour=$time;
                $fullhour+=0;
                $halfhour=$fullhour+30;

                if ($halfhour =~ m/(^8)|(^9)/)
                {
                    $halfhour =~ s/8/08/;
                    $halfhour =~ s/9/09/;
                }

                $slot = "\"USERID${tableid}DIRESU\",\"DAY${day}YAD\"";
                @grep = grep { /$slot/ } @venavail;
                $grep = join('',@grep);

                if ($grep =~ m/TIME${time}EMIT/) 
		{ 
		    $timecheck = "checked"; 
		}

                if ($grep =~ m/TIME${halfhour}EMIT/) 
		{ 
		    $halfcheck = "checked"; 
		}

                if ($grep =~ m/TIME${time}EMIT","DISABLED/) 
		{ 
		    $timedis = "disabled"; 
		}

                if ($grep =~ m/TIME${halfhour}EMIT","DISABLED/) 
		{ 
		    $halfdis = "disabled"; 
		}

                print(STDOUT <<HTML);
                        <td width="60" height="10">
                            <input type="checkbox" name="USERID${tableid}DIRESU,DAY${day}YAD,TIME${time}EMIT" $timecheck $timedis>
                            <input type="checkbox" name="USERID${tableid}DIRESU,DAY${day}YAD,TIME${halfhour}EMIT"$halfcheck $halfdis>
                        </td>
HTML
                $timecheck="";
                $halfcheck="";
                $timedis="";
                $halfdis="";
            }
        print "<td class=\"noprint\" width=\"60\" height=\"10\"><input type=\"checkbox\" 
	onClick=\"select${tableid}${day}();\"></td>";
        print "<input type=\"hidden\" name=\"checkStatus${tableid}${day}\" 
	value=\"0\">";
        }
        $index++;
        print "</tr>";

        if ($thcount == 10)
        {
            print "<tr><th width=\"50\" height=\"10\">Venues ";
            print "<input class=\"noprint\" type=\"button\" value=\"End\" onClick=\"End()\">";
            foreach $index (@ctimearray)
            {
                print "<th width=\"50\" height=\"10\">";
                print "$index";
                print "</th>";
            }
            print "<th>All</th></tr>";
            $thcount=0;
        }
        $thcount++;
    }
}

sub addParticipantAvailability()
{
    # Given a buffer read in through standard-in from the avail page, parse
    # through it to find all the selected times.  This comes from all the
    # checkboxes on the Schedule page.  Disabled checkboxes are not send through
    # and must be manually inspected.

    ($pavailfile,$partfile,$year,$day,$start,$max,$page,$sid,$buffer)=@_;

    open(IN,"<",$pavailfile);
    @oldpartavail = <IN>;
    close IN;

    open(IN,"<",$partfile);
    @partitable=<IN>;
    close IN;

    @partitable = sort {lc $a cmp lc $b} @partitable;
    $place=0;

    foreach $entry (@partitable)
    {
	$entry =~ s/.*,"PARTID//;
	$entry =~ s/DITRAP",.*//;
    }

    $process = $buffer;
    $process =~ s/.*sid//g;
    $process =~ s/=[0-9]+&//;
    $process =~ s/%2C/","/g;
    $process =~ s/(=on&)|(=on)/\n/g;
    $process =~ s/\&checkStatus[0-9]+[a-zA-Z]+\=(0|1)//g;
    $process =~ s/checkStatus[0-9]+[a-zA-Z]+\=(0|1)//g;
    #$process =~ s/.*&//;
    $process =~ s/&//g;
    $process =~ s/day=//;

    @newpartavail = split("\n",$process);

    foreach $entry (@newpartavail)
    {
	$entry = "\"${entry}\"\n";
    }

    @dayoldpartavail = @oldpartavail; 

    foreach $entry (@dayoldpartavail)
    { # if user unchecks a box (makes available)
	$uid = $entry;
	$uid =~ s/"USERID//;
	$uid =~ s/DIRESU",.*//;
        chomp($uid);
	$idx=0;
	$found=0;

	foreach $id (@partitable)
	{
	    chomp($id);
	    if ($id =~ m/${uid}/)
	    {
		$found = $idx;
	    }
	    $idx++;
	}

	#if (($found >= ($start-1)) && ($found < ($max-1)))
	#{ # unchecked
	    if ($entry !~ m/DISABLED/)
	    { 
		# in case this bug happens again, DISABLED checkboxes are
		# never sent across as form variables, so we need to check
		# against it to make sure that disabled (scheduled in a panel)
		# boxes are NEVER removed without first removing the panel or
		# changing the time

		chomp($entry);
	        $findel = grep { /$entry/ } @newpartavail;
	        if (($findel == 0))
	        {
	    	    @oldpartavail = grep { !/$entry/ } @oldpartavail;
		    deleteTableObject(\@oldpartavail,$pavailfile);	
	        }
	    }
	#}
    }

    addTableObjects(\@newpartavail,$pavailfile);

    # We append the entire box then remove identical entries
    # much faster than doing a box by box comparison to see if
    # it is or used to be checked.
    removeDuplicates($pavailfile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=pseditor&y=$year&day=$day&page=$page\">";        
}

sub addVenueAvailability()
{
    # Given a buffer read in through standard-in from the avail page, parse
    # through it to find all the selected times.  This comes from all the 
    # checkboxes on the Schedule page.  Disabled checkboxes are not send through
    # and must be manually inspected.

    ($vavailfile,$venuefile,$year,$day,$start,$max,$page,$sid,$buffer)=@_;

    open(IN,"<",$vavailfile);
    @oldvenavail = <IN>;
    close IN;

    open(IN,"<",$venuefile);
    @venuetable=<IN>;
    close IN;

    @venuetable = sort {lc $a cmp lc $b} @venuetable;
    $place=0;

    foreach $entry (@venuetable)
    {
        $entry =~ s/.*,"VENID//;
        $entry =~ s/DINEV",.*//;
    }

    $process = $buffer;
    $process =~ s/.*sid//g;
    $process =~ s/=[0-9]+&//;
    $process =~ s/%2C/","/g;
    $process =~ s/(=on&)|(=on)/\n/g;
    $process =~ s/\&checkStatus[0-9]+[a-zA-Z]+\=(0|1)//g;
    $process =~ s/checkStatus[0-9]+[a-zA-Z]+\=(0|1)//g;
    #$process =~ s/.*&//;
    $process =~ s/&//g;
    $process =~ s/day=//;

    @newvenavail = split("\n",$process);

    foreach $entry (@newvenavail)
    {
        $entry = "\"${entry}\"\n";
    }

    @dayoldvenavail = grep { /$day/ } @oldvenavail;

    foreach $entry (@dayoldvenavail)
    { # if user unchecks a box (makes available)
        $uid = $entry;
        $uid =~ s/"USERID//;
        $uid =~ s/DIRESU",.*//;
        chomp($uid);
        $idx=0;
        $found=0;

        foreach $id (@venuetable)
        {
            chomp($id);
            if ($id =~ m/${uid}/)
            {
                $found = $idx;
            }
            $idx++;
        }

        #if (($found >= ($start-1)) && ($found < ($max-1)))
        #{
	    if($entry !~ m/DISABLED/)
	    {
		chomp($entry);
                $findel = grep { /$entry/ } @newvenavail;

                if ($findel == 0)
                {
                    @oldvenavail = grep { !/$entry/ } @oldvenavail;
		    deleteTableObject(\@oldvenavail,$vavailfile);
                }
            }
        #}
    }

    addTableObjects(\@newvenavail,$vavailfile);
    removeDuplicates($vavailfile);

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid&
	pid=vseditor&y=$year&day=$day&page=$page\">";
}

sub removeDuplicates()
{
    # Invoke a seen strategy to efficiently look through a given file to 
    # delete duplicates.  Recommit changes once finished.

    ($file)=@_;

    open(IN,"<",$file);
    @filearray = <IN>;
    close IN;

    foreach $entry (@filearray)
    {
	next if $seen{ $entry }++;

	if ($entry !~ m/USERIDDIRESU/)
	{
	    push @unique, $entry;
	}
    }

    deleteTableObject(\@unique,$file);
}

1;
