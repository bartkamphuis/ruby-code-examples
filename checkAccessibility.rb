# An example of extending Ruby core String class with a method to do a "site:" search using google.co.nz
# The returned html is parsed using Hpricot, and the link text and url for each search result item is shown
# Each returned url is then checked for measurable accessibility problems
# install Hpricot with 'gem install hpricot', info: http://github.com/why/hpricot/tree/master
# install Raakt and Mechanize with 'gem install raakt', 'gem install mechanize'
# usage: 'somesite.com'.checkAccessibility(maximum_number_of_pages) - see examples below
# to run this file from command line: ruby checkAccessibility.rb somesite.com


# require several code libraries 
%w[rubygems open-uri cgi hpricot mechanize raakt].each { |f| require f }
class String
  # define new String method with 10 search results as default
  def checkAccessibility(num=10)
    # 'self' is the member variable holding the url string
	puts 'Checking Accessibility for "' << self << '":'
    # check for empty search string, raise error if zero length
	if self.empty?
	  puts "ERROR: empty string. Please enter Url."
	  puts '--------------------------------------------------'
	  return
	end
	sitecheck = 'site:' << self
	# construct search url, escaping the search terms
	url = "http://www.google.co.nz/search?hl=en&q=#{CGI.escape(sitecheck)}&num=#{num}&meta="
	# instantiate Hpricot document object, loading in a string (html) returned by the I/O object
	doc = Hpricot(open(url))
	# parse document object, getting all instances of links with class "l" that occur in the html
	# ie <a class="l" href="http://somesite.com">Link title</a>
	items = (doc/"a.l")
	# check if any results
	if items.empty?
	  puts "No results returned."
	  puts '--------------------------------------------------'
	  return
	end
	i = 1 # initialise result counter
	# loop thru items
	items.each do |item|
	  # display result counter and item link title (using inner_text method)
	  puts i.to_s << ' - ' << item.inner_text
	  # display item url using attributes method
	  puts item.attributes['href']
		# instantiate a new mechanize object
		agent = WWW::Mechanize.new
		# fetch a page
		page = agent.get(item.attributes['href'])
		# instantiate a new accessibility check object
		raakttest = Raakt::Test.new(page.body)
		# get accessibility check results
		result = raakttest.all
		# check result and print to screen
		if result.length > 0
		  puts "# Accessibility problems detected:"
		  puts result
		else
		  puts "# No measurable accessibility problems were detected."
		end
	  i = i + 1
	end
	puts '--------------------------------------------------'
  end
end

# check if command line url argument exists
if ARGV[0].empty?
  # try some example site accessibility checks
  'http://google.com'.checkAccessibility(2)
  'voomstudio.com'.checkAccessibility(20)
else 
  ARGV[0].checkAccessibility
end


