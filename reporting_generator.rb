#!/usr/bin/env ruby
# encoding: utf-8
# script to get html files from samba share and create html page with list of them
# (*w)
$version = "1.1"
##### SETTINGS #####################################################
$site_dir = '/var/www/reporting'
content_dir = './content'
$content_owner = 33
$content_group = 33
##### REQUIRE ######################################################
##### FUNCTIONS ####################################################
def get_program_dir!
	$prog_dir = File.expand_path(File.dirname(__FILE__))
end

def cd_to_site_dir!
	$site_dir ? Dir.chdir($site_dir)  : Dir.chdir($prog_dir)
end
##### CLASSES ######################################################
class Transport
	def initialize(content_dir)
		@content_dir = content_dir ? content_dir : raise('Content directory not defined')
		@user = 'reporting_bel-web2'
		@password = 'd7FG34r8ds4fajsdk9'
		@domain = 'mec.int'
		@smb_share = "\'//bel-vmm01.mec.int/reports\'"
		@content_owner = $content_owner
		@content_group = $content_group
	end
	def get_new_files!
		puts "Finding new files at \"#{@smb_share}\"..."
		if File.exist?(`which smbclient`.chomp)
			files_list = `smbclient -W #{@domain} -U #{@user} -c 'dir' #{@smb_share} #{@password} 2>/dev/null`
			files_list_array = files_list.split("\n")
			files_list_array[0..files_list_array.length-3].each{|file|
				file = file.split(' ')
				if (file[0] != '.' && file[0] != '..') && (file[0].index('.html') || file[0].index('.css') )
					time = file[-2].split(':')
					remote_time = Time.local(file.last.to_i, file[-4].to_s, file[-3].to_i, time[0].to_i, time[1].to_i, time[2].to_i)
					#puts "file #{file[0]} modified at #{Time.local(file.last.to_i, file[-4].to_s, file[-3].to_i, time[0].to_i, time[1].to_i, time[2].to_i)}"
					local_file = "#{@content_dir}/#{file[0]}"
					if File.exist?(local_file)
						if (remote_time <=> File.ctime(local_file)) > 0
							puts "\tRemote file \"#{file[0]}\" newer than local."
							smb_copy_file!(file[0], local_file)
						else
							puts "\tLocal file \"#{file[0]}\" is actual."
						end
					else
						puts "\tLocal file #{file[0]} doesn't exist."
						smb_copy_file!(file[0], local_file)
					end
				end
			}
		else
			raise "Can't access smb share. Install \"smbclient\" first."
		end
	end
private
	def smb_copy_file!(from_d, to_d)
		puts "\t\tCopy remote file \"#{from_d}\" to local \"#{to_d}\""	
		`smbclient -W #{@domain} -U #{@user} -c 'get #{from_d} #{to_d}' #{@smb_share} #{@password} 2>/dev/null`
		File.chown(@content_owner, @content_group, to_d)
	end
end

class Content
	def initialize(content_dir)
		@content_dir = content_dir ? content_dir : raise('Content directory not defined')
		@index_template = "#{$prog_dir}/sys/index.html.template"
		@index_file = './index.html'
		@content_owner = $content_owner
		@content_group = $content_group
		@title = "Список отчётов"
	end
	def build_index!
		puts "Building \"index.html\" file.."
		htmls = get_htmls_list(@content_dir)
		url_list = create_links(htmls)
		index_content = IO.read(@index_template).gsub!('%$index_list$%', url_list).gsub!('%$title$%', @title)
		File.open(@index_file,'w'){|file|
			file.puts(index_content)
		}
		File.chown(@content_owner, @content_group, @index_file)
	end
private
	def get_htmls_list(dir)
		htmls = Array.new
		Dir.foreach(@content_dir){|entry|
			htmls.push("#{@content_dir}/#{entry}") if entry.index('.html')
		}
		htmls
	end
	def create_links(files)
		url_list = String.new
		files.each{|file|
			url_list = "#{url_list}<li><a href=\"#{file}\" target=\"_blank\">#{File.basename(file).gsub!('.html', '')}</a></li>"

		}
		url_list = "<ul>#{url_list}</ul>"
	end
end
##### BEGIN ########################################################
get_program_dir!
cd_to_site_dir!

transport = Transport.new(content_dir)
transport.get_new_files!
content = Content.new(content_dir)
content.build_index!
