module ScrapingError

  # A custom error to signal when scraping has returned no results 
  class NoElementFound < StandardError 
  end

end