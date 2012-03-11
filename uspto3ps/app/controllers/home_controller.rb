#PatentBat - A web platform for facilitating the third party submissions of prior art under 37 CFR 1.290
#Copyright (C) 2012 Michelle M. Koeth
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as
#published by the Free Software Foundation, either version 3 of the
#License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.
#
#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
