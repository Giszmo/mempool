#!/usr/bin/perl

my $SQLITE="sqlite3";
my $MEMPOOLLOG="mempool.log";
my $MEMPOOLDB="mempool.s3db";

my @feelimit=(0.0001,5,10,20,30,40,50,60,70,80,90,100,120,140,160,180,200,220,240,260,280,300,350,400,450,500);
my @total=();
my @count=();
my $totalfee = 0;
my $time = time();
for ($i = 0; $i< @feelimit; $i++) {
    $total[$i] = 0;
    $count[$i] = 0;
}
while(<>) {
    /"size": (\d+)/ and $size = $1;
    /"fee": (\d*\.\d+)/ and $fee = int($1*1e8 + .5);

    if (/},/) {
	$totalfee += $fee;
	$feeperbyte = $fee / $size;
	for ($i = 0; $i< @feelimit; $i++) {
	    if ($feeperbyte >= $feelimit[$i]) {
		$total[$i] += $size;
		$count[$i]++;
	    }
	}
    }
}
if ($count[0]) {
    my $cnt  = join(",", @count);
    my $size = join(",", @total); 
    open(LOG, ">>$MEMPOOLLOG");
    print LOG "[$time,[$cnt],[$size],$totalfee],\n";
    close(LOG);
    open(SQL, "|$SQLITE $MEMPOOLDB");
    print SQL ".timeout 20000\n";
    $line = "INSERT INTO mempool VALUES($time,$cnt,$size,$totalfee);\n";
    print SQL $line;
    close SQL;
}
