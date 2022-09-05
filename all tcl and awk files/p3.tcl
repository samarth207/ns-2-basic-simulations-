# Create a simulator object
set ns [new Simulator]

# Define different colors
# for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Red

# Open the NAM trace file
set nf [open p3_disp.nam w]
$ns namtrace-all $nf

set tracefile [open p3_log.tr w]
$ns trace-all $tracefile

puts " "
puts "---------------------------------------------------------------------------------------------- "
puts " The NAM and Log Trace files have been created. Do run the following commands in order:- "
puts ""
puts " For viewing the simulation : nam p3_disp.nam"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 1.For plotting Packet Delivery Ratio :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f pdr.awk -v src=<src> -v dest=<dest> p3_log.tr>p3_pdr"
puts "   B) Run : xgraph p3_pdr"

puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 2.For plotting Packet Loss Ratio :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f plr.awk -v src=<src> -v dest=<dest>  p3_log.tr>p3_plr"
puts "   B) Run : xgraph p3_plr"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 3.For plotting End to End Delay :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f e2e_delay.awk -v src=<src> -v dest=<dest> p3_log.tr>p3_e2e_delay"
puts "   B) Run : xgraph p3_e2e_delay"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " "

# Define a 'finish' procedure
proc finish {} {
	global ns nf
	$ns flush-trace
	
	# Close the NAM trace file
	close $nf
	
	exec awk -f throughput.awk -v dest=6 p3_log.tr &
	after 300 
	puts "\n" 
	exit 0
}

# Create four nodes

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

# Create links between the nodes
$ns duplex-link $n1 $n4 8Mb 10ms DropTail
$ns duplex-link $n2 $n4 15Mb 10ms DropTail
$ns duplex-link $n3 $n4 20Mb 10ms DropTail
$ns duplex-link $n4 $n5 15Mb 30ms RED
$ns duplex-link $n5 $n6 10Mb 20ms FQ
$ns duplex-link $n6 $n7 20Mb 10ms DropTail
$ns duplex-link $n6 $n8 5Mb 10ms DropTail

# Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n4 $n5 55
$ns queue-limit $n5 $n6 55

# Give node position (for NAM)
$ns duplex-link-op $n1 $n4 orient right-down
$ns duplex-link-op $n2 $n4 orient right
$ns duplex-link-op $n3 $n4 orient right-up
$ns duplex-link-op $n4 $n5 orient right
$ns duplex-link-op $n5 $n6 orient right
$ns duplex-link-op $n6 $n7 orient right-up
$ns duplex-link-op $n6 $n8 orient right-down


# Monitor the queue for link (n4-n5). (for NAM)
#$ns duplex-link-op $n2 $n3 queuePos 0.5


# Setup first TCP connection
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n1 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n7 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 1

# Setup first FTP over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
$ftp1 set packet_size_ 500
$ftp1 set rate_ 8mb
$ftp1 set random_ false

# Setup a UDP connection                                                                            
set udp1 [new Agent/UDP]
$ns attach-agent $n3 $udp1
set null [new Agent/Null]

$ns attach-agent $n7 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

# Setup a CBR over UDP connection                                                                   
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 500
$cbr1 set rate_ 9mb
$cbr1 set random_ false


# Setup a UDP connection                                                                            
set udp2 [new Agent/UDP]
$ns attach-agent $n3 $udp2
set null [new Agent/Null]

$ns attach-agent $n7 $null
$ns connect $udp2 $null
$udp2 set fid_ 3

# Setup a CBR over UDP connection                                                                   
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 500
$cbr2 set rate_ 8mb
$cbr2 set random_ false



# Schedule events for the FTP agents
$ns at 0.1 "$ftp1 start"
$ns at 24 "$ftp1 stop"
$ns at 5 "$cbr1 start"
$ns at 10.0 "$cbr1 stop"
$ns at 5.0 "$cbr2 start"
$ns at 10.0 "$cbr2 stop"



# Call the finish procedure after
# 5 seconds of simulation time
$ns at 24.0 "finish"



# Run the simulation
$ns run

