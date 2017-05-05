#! /bin/bash
namefile=( "sort -nr -t'='  -k2 /tmp/Webservercount.txt" "sort -nr -t'='  -k2 /tmp/DBservercount.txt" "sort -nr -t'='  -k2 /tmp/Springsservercount.txt"  )
sed -i 's/|           / = /g' /tmp/DBCount.txt
sed -i 's/|          / = /g' /tmp/DBCount.txt
sed -i '/^\s*$/d'   /tmp/DBCount.txt
sort -nr -t'='  -k2 /tmp/Webservercount.txt > /tmp/V0.txt
sort -nr -t'='  -k2 /tmp/DBservercount.txt > /tmp/V1.txt 
sort -nr -t'='  -k2 /tmp/Springsservercount.txt > /tmp/V2.txt
sort -nr -t'='  -k2 /tmp/Webservercount8443.txt > /tmp/w43.txt
sort -nr -t'='  -k2 /tmp/Webservercount8080.txt > /tmp/w80.txt
sort -nr -t'='  -k2 /tmp/Springsservercount80443.txt > /tmp/s80.txt
sort -nr -t'='  -k2 /tmp/DBCount.txt > /tmp/V1-1.txt
cat /tmp/V0.txt
    if [ $# -eq 0 ] ; then
       echo "USAGE: $(basename $0) file1 file2 file3 ..."
       exit 1
    fi

    for file in $* ; do
       html=$(echo $file | sed 's/\.txt$/\.html/i')

       echo "<html>" >> $html
       echo "<style type="text/css">
            table, th, td {
            border: 1px solid black;
            }
            </style>" >> $html
       echo "   <body>" >> $html
       echo '<table>' >> $html
       echo '<th>Web Server - DBCP</th>' >> $html
       echo '<th>DB Server - DBCP</th>' >> $html
       echo '<th>DB Count - Per DB</th>' >> $html
       echo '<th>Spring Server</th>' >> $html
       echo '<th>Web Server - HTTP</th>' >> $html
       echo '<th>Web Server - HTTPS</th>' >> $html
       echo '<th>Springs Server - HTTP</th>' >> $html
           echo "<tr>" >> $html
#       for ((i = 0  ; i < "${#namefile[*]}" ; i++)) do
           echo " /tmp/V1.txt";
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/V0.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/V1.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/V1-1.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/V2.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/w80.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/w43.txt`</td>" >> $html
           echo "<td valign="top" >`awk '{print "<br>"$0"</br>"}' /tmp/s80.txt`</td>" >> $html
           #echo "<td>`$i`</td>" >> $html
 #        done 
           echo "</tr>" >> $html
        echo '</table>'
        echo "   </body>" >> $html
        echo "</html>" >> $html
   done

