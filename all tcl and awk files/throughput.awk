BEGIN{
	stime=0
	ftime=0
	flag=0
	size=0
	duration=0
	throughput=0
}

{
	#Trace File current destination
	tf_dest=$4;

	if($1=="r" && tf_dest==dest)
	{
		size+=$6
		if(flag==0){
			stime=$2
			flag=1
		}
		ftime=$2
	}
	
}

END{
	duration=ftime-stime
	throughput=(size*8)/duration
	printf("\n Throughput : %f bits/seconds",throughput)
}
