# Create a simulator object
set ns [new Simulator]

# Define different colors
# for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red
$ns color 2 Yellow

# Open the NAM trace file
set nf [open p1_disp.nam w]
$ns namtrace-all $nf

set tracefile [open p1_log.tr w]
$ns trace-all $tracefile

puts " "
puts "---------------------------------------------------------------------------------------------- "
puts " The NAM and Log Trace files have been created. Do run the following commands in order:- "
puts ""
puts " For viewing the simulation : nam p1_disp.nam"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 1.For plotting Packet Delivery Ratio :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f pdr.awk -v src=<src> -v dest=<dest> p1_log.tr>p1_pdr"
puts "   B) Run : xgraph p1_pdr"

puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 2.For plotting Packet Loss Ratio :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f plr.awk -v src=<src> -v dest=<dest>  p1_log.tr>p1_plr"
puts "   B) Run : xgraph p1_plr"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " 3.For plotting End to End Delay :-"
puts "---------------------------------------------------------------------------------------------- "
puts "   A) Run : awk -f e2e_delay.awk -v src=<src> -v dest=<dest> p1_log.tr>p1_e2e_delay"
puts "   B) Run : xgraph p1_e2e_delay"
puts ""
puts "---------------------------------------------------------------------------------------------- "
puts " "

# Define a 'finish' procedure
proc finish {} {
	global ns nf
	$ns flush-trace
	
	# Close the NAM trace file
	close $nf
	
	exec awk -f throughput.awk -v dest=6 p1_log.tr &
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
$ns duplex-link $n1 $n4 5Mb 10ms DropTail
$ns duplex-link $n2 $n4 5Mb 10ms DropTail
$ns duplex-link $n3 $n4 5Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.15Mb 30ms DropTail
$ns duplex-link $n5 $n6 0.15Mb 20ms DropTail
$ns duplex-link $n6 $n7 20Mb 10ms DropTail
$ns duplex-link $n6 $n8 5Mb 10ms DropTail

# Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n4 $n5 10
$ns queue-limit $n5 $n6 10

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
$ftp1 set packet_size_ 5000
$ftp1 set rate_ 8mb
$ftp1 set random_ false

# Setup second TCP connection
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n2 $tcp2

set sink2 [new Agent/TCPSink]
$ns attach-agent $n7 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 2

# Setup second FTP over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP
$ftp2 set packet_size_ 10000
$ftp2 set rate_ 16mb
$ftp2 set random_ false


# Setup third TCP connection
set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
$ns attach-agent $n3 $tcp3

set sink3 [new Agent/TCPSink]
$ns attach-agent $n7 $sink3
$ns connect $tcp3 $sink3
$tcp3 set fid_ 3

# Setup third FTP over TCP connection
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set type_ FTP
$ftp3 set packet_size_ 50000
$ftp3 set rate_ 8mb
$ftp3 set random_ false


# Schedule events for the FTP agents
$ns at 0.1 "$ftp1 start"
$ns at 24 "$ftp1 stop"
$ns at 5 "$ftp2 start"
$ns at 10.0 "$ftp2 stop"
$ns at 5.0 "$ftp3 start"
$ns at 10.0 "$ftp3 stop"



# Call the finish procedure after
# 5 seconds of simulation time
$ns at 25.0 "finish"



# Run the simulation
$ns run

