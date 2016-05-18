####################################################
# ## Eric Dunford, University of Maryland, College Park
# ## May 19, 2016
# ## Topic: ABCs of Web Scraping - Script 1 (The Basics)
# ## dunforde@umd.edu - Please Feel Free to Contact Me
####################################################


# Dependencies ---------------------------
sapply(c("rvest","RCurl","XML","httr","xml2","RCurl"),install.packages)
        # Though not all these packages will be used in this tutorial, keep in
        # mind that there is a wide array of packages that effectively work at
        # mining online internet data.
require(rvest);require(httr);require(RCurl);require(XML);require(xml2)

# Basics ---------------------------------

# For this exercise, we will use a news story from the BBC as a motivating
# example.

# Save URL as an object
url = "http://www.bbc.com/news/world-middle-east-36156865"

BROWSE(url) # examine the website. 

# USE THE PIPE
# Given how "nested" the extraction code can get, it's important that to use the
# pipe when constructing your code. The pipe "passes" tasks between functions
# seemlessly.
    # for example...
    round(sd(rnorm(100,5,6)),3) # Nested
    rnorm(100,5,6) %>% sd(.) %>% round(.,3) # Piped
    
    # Piping always leads to more readable code.


# Basics of the process: 
    # (A) identify what information you want;
    # (B) examine the structure and elements;
    # (C) download website;
    # (D) extract element;
    # (E) clean element;
    # (F) store outcome.
 
# Here let's shoot to extract three pieces of information.
    # (1) Headline
    # (2) Date
    # (3) Story

# Assuming we've already knocked out A and B

# C. download the website
site = read_html(url)
# Here the entire website is now retained in the "site" object. 

    # QUESTION: Why is it useful to get the whole thing in one go?

# D. extract element
# Two choices in extraction: xml and css ... what is the difference?  

headline.path = "//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/h1"
site %>% html_node(.,xpath = headline.path) 
# Slightly meaningless...still in raw HTML form, let's translate

# E. clean element
site %>% html_node(.,xpath = headline.path) %>% html_text(.)

# F. store outcome
headline = site %>% html_node(.,xpath = headline.path) %>% html_text(.)
headline

# [1] KEEP IN MIND: Often the unstructured text requires cleaning to provide it with
# a useable structure. What we have here is pretty clean, but keep in mind that
# all those text manipulation skills will be of prime importance when processing
# more complex sources.

# Let's rinse wash and repeat -- this time using the css path (which is the
# default for RVest)
date.path = "#page > div:nth-child(2) > div.container > div > div.column--primary > div.story-body > div.story-body__mini-info-list-and-share > ul > li:nth-child(1) > div"
date = site %>% html_node(.,date.path) %>% html_text(.)
# format date into a usable "R format"
date = as.Date(date,"%d %b %Y")

# To get ALL of the body text, we really need to think about what it is we are
# grabbing. Here comprehending the structure of the website can be really useful.

body.path = "//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[2]/p[1]"
site %>% html_node(.,xpath=body.path) %>% html_text(.)
  
# This is only part of the picture. We want the WHOLE story. We can do this by
# not just taking an individual element, but rather all tags within that div. 
body.path = "//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[2]/p"
body = site %>% html_nodes(.,xpath=body.path) %>% html_text(.) # Note the plural on the function
body = paste(body,collapse=" ") # Clean

# Storage ---------- Data frames aren't always your friend when it comes to 
# storing unstructured data. Given the multi-"entry" nature of the data, let's
# store this information into a list. 

output = list()
output$headline = headline
output$date = date
output$story = body
str(output) # Stored!
