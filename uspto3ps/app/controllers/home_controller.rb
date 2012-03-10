class HomeController < ApplicationController
  def index
    # Here we want to display the running board of applications and their popularity
    # first check for voted on apps, and rank. If less than 100, then add in as many non-voted apps to the end
    # of the list
    # Let users vote if they are logged in. If they are not logged in, let them simply see the popularity rankings
    #@toppapps = Papp.plusminus_tally.limit(100).where('created_at > ?', 2.days.ago).having('plusminus > 10')
    toppapps = Papp.plusminus_tally.limit(100).having('vote_count > 0').order('plusminus DESC')
    tahash = toppapps.size
    size = 0
    #puts "NUM OF VOTED PAPPS " + tahash.keys.count.to_s
    if toppapps.empty? {size = 0}
    else size = tahash.keys.count
    end
    if size < 100
      moreapps = Papp.tally.having('vote_count = 0').order('created_at DESC')
    end
    @papps = toppapps + moreapps
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @papps }
    end
  end
end
