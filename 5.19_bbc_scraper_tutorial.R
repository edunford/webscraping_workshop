####################################################
# ## Eric Dunford, University of Maryland, College Park
# ## May 19, 2016
# ## Topic: ABCs of Web Scraping - Script 2 (The Scraper)
# ## dunforde@umd.edu - Please Feel Free to Contact Me
####################################################

require(rvest);require(xml2);require(rjson)
# Let's use what we learned about the last script to construct a function that
# takes in URLs and spits out formatted data.

# Using the same URL as last time...
url = "http://www.bbc.com/news/world-middle-east-36156865"
httr::BROWSE(url)

# [1] Building the BBC scraper -----------------------
# Rather than gather the whole story (as we did before), let's construct a
# dataset that tells us a slightly different story. 

# Let's grab:
    # (1) The Headline
    # (2) The Date
    # (3) The reporting region
 
      ralph = function(url){
        raw = read_html(url)
        headline = raw %>% 
          html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/h1") %>% 
          html_text(.)
        date = raw %>% 
          html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[1]/ul/li[1]/div") %>% 
          html_text(.) %>% as.Date(.,"%d %b %Y")
        region = raw %>% 
          html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[1]/ul/li[2]/a") %>% html_text(.)
        data.out = data.frame(headline,date,region)
        return(data.out)
      }
      ralph(url) # Great!
      

# Let's now run ralph on a number of URLs that we want information on. 
      
      urls = c("http://www.bbc.com/news/world-middle-east-36156865",
               "http://www.bbc.com/news/world-middle-east-36162701",
               "http://www.bbc.com/news/world-australia-36166803",
               "http://www.bbc.com/news/world-latin-america-36166632")
      urls

      # Run a loop and store the output      
      store = NULL
      for(i in urls){
        store = rbind(store,ralph(i))
      }
      View(store)
      
      # We've officially made a scraper!
      
      
      
# [2] How Relevant are these stories? -------------------------------

      # Now how about we leverage social media to find out how popular a story is. 
      # Here we will "ping" facebook and make it spill its secrets.
      Relevance <- function(url){
        # Chopping up URLs
        queryUrl = paste0('http://graph.facebook.com/fql?q=',
                          'select share_count,comment_count,like_count, total_count from link_stat where url="',
                          url,'"') 
        lookUp <- URLencode(queryUrl) # Translates our code into URL-speak
        rd <- readLines(lookUp, warn="F") # returns JSON that we have to read in
        data <- fromJSON(rd) # And interpret
        output <- data.frame(Shares=data$data[[1]]$share_count,
                             No.of.Comments=data$data[[1]]$comment_count,
                             No.of.Likes=data$data[[1]]$like_count,
                             Total=data$data[[1]]$total_count)
        return(output)
      }
      Relevance(url) # Nice!


# [3] Combine the two ------------------------------
    ralph2.0 = function(url){
      raw = read_html(url)
      queryUrl = paste0('http://graph.facebook.com/fql?q=',
                        'select share_count,comment_count,like_count, total_count from link_stat where url="',
                        url,'"') 
      lookUp <- URLencode(queryUrl) # Translates our code into URL-speak
      rd <- readLines(lookUp, warn="F") # returns JSON that we have to read in
      data <- fromJSON(rd) # And interpret 
      headline = raw %>% 
        html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/h1") %>% 
        html_text(.)
      date = raw %>% 
        html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[1]/ul/li[1]/div") %>% 
        html_text(.) %>% as.Date(.,"%d %b %Y")
      region = raw %>% 
        html_nodes(.,xpath="//*[@id='page']/div[2]/div[2]/div/div[1]/div[1]/div[1]/ul/li[2]/a") %>% html_text(.)
      data.out = data.frame(headline,date,region,Shares=data$data[[1]]$share_count,
                            No.of.Comments=data$data[[1]]$comment_count,
                            No.of.Likes=data$data[[1]]$like_count,
                            Total=data$data[[1]]$total_count)
      return(data.out)
    }
    
    ralph2.0(url) # Looking good!
    
    # Run a loop and store the output      
    store2 = NULL
    for(i in urls){
      store2 = rbind(store2,ralph2.0(i))
    }
    View(store2) # Looks like the Syria story is the most popular. 



