#!/usr/local/bin/perl

# COWAbunga -
# File: filehandler.pl
# Conference on World Affairs Scheduler
#   This file contains opens the main tables and inserts
#   them into arrays for the library to use
#   Status: STABLE

sub fileHandler()
{
    # Inserts the primary db files into arrays and then returns a reference back
    # Allows each subsequent subroutine to access the array rather accepting in
    # a new file parameter and then file->array dump

    ($HOME,$DBDIRECTORY,$moderfile,$partifile,$venuefile,$panelfile,
	$produfile,$tagsfile,$sessifile,$usertfile) = @_;

    $message="table is currently unavailable.  Please contact your local 
	system administrator.";
    open(IN,$moderfile)||die("Moderator $moderfile $message");
    @modertable=<IN>;
    close IN;

    open(IN,$partifile)||die("Participant $message");
    @partitable=<IN>;
    close IN;

    open(IN,$venuefile)||die("Venue $message");
    @venuetable=<IN>;
    close IN;

    open(IN,$panelfile)||die("Panel $message");
    @paneltable=<IN>;
    close IN;

    open(IN,$produfile)||die("Producer $message");
    @produtable=<IN>;
    close IN;

    open(IN,$tagsfile)||die("Tags $message");
    @tagtable=<IN>;
    close IN;

    open(IN,$sessifile)||die("Session $message");
    @sessitable=<IN>;
    close IN;

    open(IN,$usertfile)||die("User $message");
    @usertable=<IN>;
    close IN;

    return (\@modertable, \@partitable, \@venuetable, \@paneltable,
	 \@produtable, \@tagtable, \@sessitable, \@usertable);
}

sub fileIDHandler()
{
    # Generates primary keys for adding new entries to any table in the database
    # Accepts an idfile, *.count, extracts the current value, and then
    # increments.  Returns the id.

    ($idfile) = @_;
    
    open(IN, "<", $idfile)||die("ID file is currently unavailable.  
	Please contact your local system administrator.");
    $tableid=<IN>;
    close IN;

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

    return ($tableid);
}

1;
