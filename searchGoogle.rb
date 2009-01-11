# An example of extending Ruby core String class with a method to search google.co.nz
# The returned html is parsed using Hpricot, and the link text and url for each search result item is printed
# install Hpricot with 'gem install hpricot', info: http://github.com/why/hpricot/tree/master
# usage: 'search terms string'.searchGoogle(maximum_number_of_results) - see examples below
# to run this file from command line: ruby searchGoogle.rb


# require several code libraries 
%w[rubygems open-uri cgi hpricot].each { |f| require f }
class String
  # define new String method with 10 search terms as default
  def searchGoogle(num=10)
    # 'self' is the member variable holding the string
	puts 'Searching Google for "' << self << '":'
    # check for empty search string, raise error if zero length
	if self.length == 0
	  puts "ERROR - google needs a string to search with."
	  puts '--------------------------------------------------'
	  return
	end
	# construct search url, escaping the search terms
	url = "http://www.google.co.nz/search?hl=en&q=#{CGI.escape(self)}&num=#{num}&meta="
	# instantiate Hpricot document object, loading in a string (html) returned by the I/O object
	doc = Hpricot(open(url))
	# parse document object, getting all instances of links with class "l" that occur in the html
	# ie <a class="l" href="http://somesite.com">Link title</a>
	items = (doc/"a.l")
	# check if any results
	if items.length == 0
	  puts "No results returned."
	  puts '--------------------------------------------------'
	  return
	end
	i = 1 # counter
	# loop thru items
	items.each do |item|
	  # display result counter and item link title (using inner_text method)
	  puts i.to_s << ' - ' << item.inner_text
	  # display item url using attributes method
	  puts item.attributes['href']
	  i = i + 1
	end
	puts '--------------------------------------------------'
  end
end


# try some example searches
'symfony'.searchGoogle # get 10 results
'ruby language'.searchGoogle(5) # get 5 results
''.searchGoogle # empty search should exit gracefully
'34692y2d3h93'.searchGoogle # no results returned
'site:voomstudio.com'.searchGoogle(100) # all indexed pages, up to 100
"extending ruby core classes".searchGoogle(500) # a maximum of 100 results are returned
