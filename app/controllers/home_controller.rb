class HomeController < ApplicationController

  def about
  end

  def delivery
  end

  def news
    @news = News.all
  end

  def site_map
  end

  def services
  end

  def contacts
  end

end
