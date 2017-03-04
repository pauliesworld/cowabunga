#!/usr/local/bin/perl

# COWAbunga -
# File: snapshot.pl
# Conference on World Affairs Scheduler
#   Create, delete, and revert 'snapshots' of  
#   of the database
#   Status: STABLE

sub snapshotPage()
{
    ($DBDIRECTORY,$year,$sid,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
        sid=$sid\">";
        exit 1;
    }

    print( STDOUT <<HTML );
<script language="Javascript" type="text/javascript">
function Confirm()
{
    if(confirm ("Are you sure you want to delete this snapshot?"))
    {
        document.forms["editSnapshots"].submit();
    }
}

function Restore()
{
    if(confirm ("This will overwrite the current state of the database. For safety reasons, a backup of the current schema will be created in case of mistake.  Click cancel if you do NOT want to restore."))
    {
	document.forms["editSnapshots"].snaprestore.value="Restore";
        document.forms["editSnapshots"].submit();
    }
}
</script>
<div id="content">
<h2>Snapshots</h2>
<hr size="1" noshade>
<div class="listItems">
Snapshot List<br>
<form name="editSnapshots" action="cwasys.pl" method="GET">
<input type="hidden" name="delete" value="snapshot">
HTML
createSnapshotPopupBox($DBDIRECTORY,35);
print(STDOUT <<HTML);
<br><br>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<input type=hidden name="snaprestore" value="">
<input type="button" name="snapform" value="Restore" onClick="Restore();">
<input type="button" name="snapform" value="Delete" onClick="Confirm();">
</form>
</div>
<div class="editItems">
<form action=cwasys.pl method=GET>
<input type=hidden name=add value=snapshot>
<input type=hidden name=sid value=$sid>
<input type=hidden name=y value=$year>
<br><br><input type=submit value="Create New Snapshot">
</form>
</div>
</div>

HTML
}

sub backupSnapshot()
{
    # Check if we need to create a backup or delete old backups based on
    # the snapshot variables inside CONFIGURE.  Generally we want to backup
    # once a week at a minimum, but user's choice.

    ($DBDIRECTORY,$year,$sid,$userfile,$sessifile)=@_;

    @snapshots=`${LS} -1 ${DBDIRECTORY}snapshots/`;

    $snapsize = @snapshots;
    $todaysdate = time;

    if ($snapshots[${snapsize}-1] < ($todaysdate - $NEWSNAPSHOT*86400))
    {
	createSnapshot($DBDIRECTORY,$year,$sid,$userfile,$sessifile,1);
    }
    
    foreach $file (@snapshots)
    {
	chomp($file);
	$file =~ s/zip.gz.*//;
	$file += 0;

	if ($file < ($todaysdate-$KEEPSNAPSHOT*86400))
	{
	    deleteSnapshot($DBDIRECTORY,$file,$year,$sid,$userfile,$sessifile,1);
	}
    }
} 

sub restoreSnapshot()
{
    # Given a snapshot file, copy it into the db directory and extract it
    # inside to overwrite existing files.  It is important to create a new
    # backup before doing this in case it was a mistake.

    ($DBDIRECTORY,$snapshot,$year,$sid,$userfile,$sessifile)=@_;

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner|coord/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl?msg=2&
        sid=$sid\">";
        exit 1;
    }

    if (-r "${DBDIRECTORY}snapshots/${snapshot}.zip.gz")
    {
        # Before we do anything, make a backup of the current state
        createSnapshot($DBDIRECTORY,$year,$sid,$userfile,$sessifile,1);

        # Copy the gzip into the database directory
        $copy=`${CP} ${DBDIRECTORY}snapshots/${snapshot}.zip.gz ${DBDIRECTORY}`;

        # Decompress with gzip, extract the zip
        $convertGzp = `cd ${DBDIRECTORY} && ${GZIP} -d ${snapshot}.zip.gz`;
        $convertTar = `cd ${DBDIRECTORY} && ${UNZIP} -o ${snapshot}.zip`;
        $removeTar = `${RM} ${DBDIRECTORY}${snapshot}.zip`;
    }

    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid
	&pid=snapshots&y=$year\">";
}

sub createSnapshot()
{
    # Zip and gzip the current database minus the sessions, logs, and 
    # user tables.  Store the results in the snapshots folder. Zip is
    # used rather than tar because for whatever reason `which tar` 
    # points to /sbin/tar and is only executable by root.  Why would 
    # anyone set a UNIX server up like this?  Locks are now used to ensure
    # that a snapshot is complete and uncorrupted.

    ($DBDIRECTORY,$year,$sid,$userfile,$sessifile,$restore)=@_;

    # Snapshot file is based on time
    $thisdate=time;
    chomp($thisdate);
    $filename = "${thisdate}.zip";
    chomp($filename);

    # Use zip to create the file
    $createBackup = `cd ${DBDIRECTORY} && ${ZIP} $filename p* m* v* c* t*`;

    # Compress the zip file with gzip
    $comprsBackup = `cd ${DBDIRECTORY} && ${GZIP} -9 $filename`;

    # Put the archive into the snapshots folder
    $moveSS = `${MV} ${DBDIRECTORY}${filename}.gz ${DBDIRECTORY}snapshots`;

    if (!$restore)
    {
    	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid
	&pid=snapshots&y=$year\">";
    }
}

sub deleteSnapshot()
{
    # Given a snapshot file, remove it from the snapshots directory

    ($DBDIRECTORY,$filename,$year,$sid,$userfile,$sessifile,$restore)=@_;

    if (-r "${DBDIRECTORY}snapshots/${filename}.zip.gz")
    {
	$removeSnapshot = `${RM} ${DBDIRECTORY}snapshots/${filename}.zip.gz`;
    } 

    if (!$restore)
    {
    	print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?sid=$sid
	&pid=snapshots&y=$year\">";
    }
}

1;
