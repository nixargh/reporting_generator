#!/usr/bin/env ruby
# (*w)
version = "0.1"
##### SETTINGS #####################################################
content_dir = './content'
index_template = './sys/index.html.template'
##### IMPORTS ######################################################
##### FUNCTIONS ####################################################
def cd_to_program_dir!
	Dir.chdir(File.dirname(__FILE__))
end
##### CLASSES ######################################################
class Transport
	def find_new
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
			htmls.push("#{@content_dir}/#{entry}") if entry.index('.html')
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
content = Content.new(content_dir, index_template)
puts content.build_index!
