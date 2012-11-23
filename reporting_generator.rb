#!/usr/bin/env ruby
# script to get html files from samba share and create html page with list of them
# (*w)
$version = "0.2"
##### SETTINGS #####################################################
content_dir = './content'
index_template = './sys/index.html.template'
##### REQUIRE ######################################################
##### FUNCTIONS ####################################################
def cd_to_program_dir!
	Dir.chdir(File.dirname(__FILE__))
end
##### CLASSES ######################################################
class Transport
	def initialize
		@user = 'reporting_bel-web2'
		@password = 'd7FG34r8ds4fajsdk9'
		@domain = 'mec.int'
		@smb_share = '\\bel-vmm01.mec.int\reports'
	end
	def find_new
		if File.exist?(`which smbclient`.chomp)
			files_list = "smbclient -W #{@domain} -U #{@user} -c 'dir' #{@smb_share} #{@password}"
			files_list.split.each{|file|
				puts file
			}
		else
			raise "Can't access smb share. Install \"smbclient\" first."
		end
	end
	def copy
	end
end

class Content
	def initialize(content_dir, index_template)
		@content_dir = content_dir ? content_dir : raise('Content directory not defined')
		@index_template = index_template ? index_template : raise('index.html template file not defined')
	end
	def build_index!
		htmls = get_htmls_list(@content_dir)
		url_list = create_links(htmls)
		index_content = IO.read(@index_template).sub!('%$index_list$%', url_list)
		File.open('./index.html','w'){|file|
			file.puts(index_content)
		}
	end
	def get_htmls_list(dir)
		htmls = Array.new
		Dir.foreach(@content_dir){|entry|
			htmls.push("#{@content_dir}/#{entry}") if (entry.index('.html') || entry.index('.css'))
		}
		htmls
	end
	def create_links(files)
		url_list = String.new
		files.each{|file|
			url_list = "#{url_list}<br><a href=\"#{file}\" target=\"_blank\">#{file}</a>"
		}
		url_list
	end
end
##### BEGIN ########################################################
cd_to_program_dir!
#content = Content.new(content_dir, index_template)
#content.build_index!
transport = Transport.new
transport.find_new
