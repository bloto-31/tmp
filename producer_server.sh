#! /bin/sh

# CONFIGURATION
DIR=$PWD
EVENTS="create"
FIFO="/tmp/inotify2.fifo"
CSV_DIR=$PWD/csv
LOG_DIR=$PWD/logs

# FUNCTIONS
on_event() {
    local date=$1
    local time=$2
    local file=$3

    sleep 2

    echo "$date $time file created: $file" 2>&1 | tee -a  $LOG_DIR/producer_server.log
    cp $3 $CSV_DIR/$3
}

on_exit() {
    kill $INOTIFY_PID
    rm $FIFO
    exit
}


case "$1" in
     start)

	if [ ! -e "$FIFO" ]
	    then
		mkfifo "$FIFO"
	fi

	if [ ! -e "$CSV_DIR" ]
	    then
		mkdir -p "$CSV_DIR"
	fi    

	if [ ! -e "$LOG_DIR" ]
            then
                mkdir -p "$LOG_DIR"
        fi

	inotifywait -m -e "$EVENTS" --timefmt '%Y-%m-%d %H:%M:%S' --format '%T %f' "$DIR" > "$FIFO" & INOTIFY_PID=$!
      	echo $INOTIFY_PID
	while read date time file
	do
	  on_event $date $time $file &
	done < "$FIFO"			
	;;
     stop)
        #echo '...'
        #INOTIFY_PID=$(ps -ef | grep 'inotify' | grep 'create' | awk '{ printf $2 }')
        SERVER_PID=$(ps -ef | grep 'producer_server.sh' | grep 'start' | awk '{ printf $2 }')
        #echo $SERVER_PID
        #echo '...'
	#kill $INOTIFY_PID
        kill $SERVER_PID        
        rm $FIFO
        exit 0
	;;
     status)
	SERVER_PID=$(ps -ef | grep 'producer_server.sh' | grep 'start' | awk '{ printf $2 }')
        if [ -z "$SERVER_PID" ]
            then echo 'stopped'
            else echo 'started' 
        fi                
        ;;
        *)
          echo 'Usage: producer_server.sh start|stop|status'
          exit 1
          ;;
esac
