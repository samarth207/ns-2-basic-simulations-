# End to End delay script
BEGIN{
	pksend=0;
	pkrec=0;
	ctime=0;
	tdelay=0;
}

{
	e=$1;
	#Trace File current destination
	tf_dest=$4;
	
	#Trace File current source 
	tf_src=$3;
	ctime=$2

	if(e =="r" && tf_dest=dest){
		tdelay+= ctime - stime[$11];
	}
	
	if(e =="+" && tf_src=src){
		stime[$11]= ctime;
	}
	printf("%f %f \n", ctime, tdelay);
}

END{

}
