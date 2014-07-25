#!/usr/bin/ruby
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 
#   
#Author:Przemyslaw Hejmanblindroot.pl
#Copyright: TouK 2013 

#This simple Nagios Plugin checks the status of Puppet Agent


pidfile = '/var/run/puppet/agent.pid'

puppetAgentPID = File.read(pidfile)

begin
        Process.kill(0, Integer(puppetAgentPID))
        puts "OK - Puppet Agent is up and running! (pid=#{puppetAgentPID})"
  exit 0
rescue Errno::EPERM                     # changed uid
        puts "UNKNOWN - No permission to query the PID"
  exit 3
rescue Errno::ESRCH
        puts "CRITICAL - Puppet Agent is NOT running!" # or zombied
        exit 2
rescue
  puts "UNKNOWN - Unable to determine status for the Puppet Agent Process"
  exit 3
end

