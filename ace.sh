#!/usr/bin/expect -f
# Set local SUDO and jumpbox passwords from ENV
set local_pass $env(SUDO_PASS)
set jump_pass $env(JUMP_PASS)
# Spawn sshuttle session to ACE jumpbox
spawn sshuttle -r ttaylor@71.85.94.19:51922 10.201.0.0/16 192.168.255.0/24 100.64.2.2/32 172.27.28.77/32 10.10.0.0/16 172.27.28.133/32 172.30.105.132/32
################################################################################

# Helper function to print an informative message to the user.
proc print { MSG } {
    send_user "\n** ${MSG} **\n"
}

# Helper function for printing an error message in red and then exiting.
proc err_print { MSG } {
    send_user "\n\033\[1;31m** ${MSG}\033\[0;0m\n"
    exit 1
}

print "Waiting for sudo prompt"
expect {
    timeout { err_print "Timed out waiting for first password prompt" }
    eof { err_print "Received unexpected EOF" }
    "^\\\[local sudo\\\] Password:" {
        if { "x${local_pass}" == "x" } { err_print "Local sudo password needed but not given" }
        send -- "${local_pass}\r"
    }
    "?assword:" {
        send -- "${jump_pass}\r"
    }
}

print "Waiting for jumphost prompt"
expect {
    timeout { err_print "Timed out waiting for first password prompt" }
    eof { err_print "Received unexpected EOF" }
    "^\\\[local sudo\\\] Password:" {
        if { "x${local_pass}" == "x" } { err_print "Local sudo password needed but not given" }
        send -- "${local_pass}\r"
    }
    "?assword:" {
        send -- "${jump_pass}\r"
    }
}

print "Press CTRL+C to close to disconnect"
interact