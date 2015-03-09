#!/usr/bin/expect -c

spawn sudo calamari-ctl initialize
expect "Username (leave blank to use 'root'):"
send "admin\n"
expect "Email address:"
send "admin@ceph.example.com\n"
expect "Password:"
send "admin\n"
expect "Password (again):"
send "admin\n"
interact
exit

