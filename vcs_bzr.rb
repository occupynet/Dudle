############################################################################
# Copyright 2009,2010 Benjamin Kellermann                                  #
#                                                                          #
# This file is part of dudle.                                              #
#                                                                          #
# Dudle is free software: you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by       #
# the Free Software Foundation, either version 3 of the License, or        #
# (at your option) any later version.                                      #
#                                                                          #
# Dudle is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public     #
# License for more details.                                                #
#                                                                          #
# You should have received a copy of the GNU Affero General Public License #
# along with dudle.  If not, see <http://www.gnu.org/licenses/>.           #
############################################################################

require "time"
require "log"

class VCS
	BZRCMD="export LC_ALL=de_DE.UTF-8; bzr"
	def VCS.init
		%x{#{BZRCMD} init}
	end

	def VCS.rm file
		%x{#{BZRCMD} rm #{file}}
	end

	def VCS.add file
		%x{#{BZRCMD} add #{file}}
	end

	def VCS.revno
		%x{#{BZRCMD} revno}.to_i
	end

	def VCS.cat revision, file
		%x{#{BZRCMD} cat -r #{revision.to_i} #{file}}
	end

	def VCS.history
		log = %x{#{BZRCMD} log --forward}.split("-"*60)
		ret = Log.new
		log.shift
		log.each{|s| 
			a = s.scan(/\nrevno:(.*)\ncommitter.*\n.*\ntimestamp: (.*)\nmessage:\n  (.*)/).flatten
			ret.add(a[0].to_i, Time.parse(a[1]), a[2])
		}
		ret
	end

	def VCS.commit comment
		tmpfile = "/tmp/commitcomment.#{rand(10000)}"
		File.open(tmpfile,"w"){|f|
			f<<comment
		}
		ret = %x{#{BZRCMD} commit -q -F #{tmpfile}}
		File.delete(tmpfile)
		ret
	end

	def VCS.branch source, target
		%x{#{BZRCMD} branch #{source} #{target}}
	end
end
